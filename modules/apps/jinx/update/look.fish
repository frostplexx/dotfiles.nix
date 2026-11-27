#!/usr/bin/env fish

# Report flake inputs that have upstream updates.
# This script never writes flake.lock.

set -g RED (set_color red)
set -g GREEN (set_color green)
set -g YELLOW (set_color yellow)
set -g CYAN (set_color cyan)
set -g BOLD (set_color --bold)
set -g DIM (set_color --dim)
set -g RESET (set_color normal)

set -g REV_LEN 7
set -g TIMEOUT 20

# ── GitHub auth ─────────────────────────────────────────────────────
if not set -q GITHUB_TOKEN; or test -z "$GITHUB_TOKEN"
    if command -q gh
        set -gx GITHUB_TOKEN (gh auth token 2>/dev/null)
    end
end

# ── Upstream lookup ─────────────────────────────────────────────────
function api_get --argument-names path
    set -l auth
    test -n "$GITHUB_TOKEN"; and set auth -H "Authorization: Bearer $GITHUB_TOKEN"
    curl -fsSL --max-time $TIMEOUT $auth \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com$path" 2>/dev/null
end

function latest_github_rev --argument-names owner repo ref
    set -l path "/repos/$owner/$repo/commits"
    if test -n "$ref"
        set path "$path/"(string escape --style=url -- $ref)
    else
        set path "$path?per_page=1"
    end
    api_get $path | jq -r 'if type == "array" then .[0].sha else .sha end // empty' 2>/dev/null
end

# Compare locked rev against upstream head. Returns the GitHub compare status.
function github_relation --argument-names owner repo base head
    set -l json (api_get "/repos/$owner/$repo/compare/$base...$head")
    test -z "$json"; and return
    echo $json | jq -r '.status // empty' 2>/dev/null
end

# Resolve a non-GitHub flake reference through Nix itself.
function latest_nix_rev --argument-names flakeref
    nix flake metadata --json $flakeref 2>/dev/null | jq -r '.locked.rev // empty'
end

# ── Single input probe ──────────────────────────────────────────────
# Child process mode: look.fish --probe 'NAME|LOCKED|TYPE|OWNER|REPO|REF|URL'
if test "$argv[1]" = --probe
    set -l f (string split '|' -- $argv[2])
    set -l name $f[1]
    set -l locked $f[2]
    set -l type $f[3]
    set -l owner $f[4]
    set -l repo $f[5]
    set -l ref $f[6]
    set -l url $f[7]

    set -l latest ""
    set -l github 0
    if test "$type" = github -a -n "$owner" -a -n "$repo"
        set latest (latest_github_rev $owner $repo $ref)
        set github 1
    else if test -n "$url"
        set latest (latest_nix_rev $url)
    end

    set -l rel unknown
    if test -z "$latest"
        set rel unknown
    else if test "$latest" = "$locked"
        set rel unchanged
    else if test $github -eq 1
        set rel (github_relation $owner $repo $locked $latest)
        test -z "$rel"; and set rel unverified
    else
        set rel unverified
    end

    echo (string join '|' $name $locked $latest $rel)
    exit 0
end

function usage
    echo "$BOLD""Usage:$RESET "(status basename)" [DIRECTORY]"
    echo
    echo "List flake inputs and mark the ones with upstream updates."
    echo "The lock file stays unchanged."
    echo
    echo "$BOLD""Arguments:$RESET"
    echo "  DIRECTORY   Path to the flake $DIM(default: current directory)$RESET"
end

argparse h/help -- $argv
or begin
    usage
    exit 1
end

set -q _flag_help; and begin
    usage
    exit 0
end

set -l DOTFILES (pwd)
if test (count $argv) -gt 0
    set DOTFILES $argv[1]
end

set -l LOCK "$DOTFILES/flake.lock"
if not test -f "$LOCK"
    echo "$RED error $RESET flake.lock not found in $DOTFILES" >&2
    exit 1
end

for cmd in jq curl nix
    if not command -q $cmd
        echo "$RED error $RESET $cmd is required" >&2
        exit 1
    end
end

# ── Collect lock data ───────────────────────────────────────────────
set -l inputs (jq -r '
    .nodes as $n
    | $n.root.inputs | to_entries[]
    | .key as $name | .value as $id
    | $n[$id]
    | [$name,
       (.locked.rev // "-"),
       (.original.type // "-"),
       (.original.owner // ""),
       (.original.repo // ""),
       (.original.ref // ""),
       (.original.url // "")]
    | join("|")
' $LOCK)

# ── Check every input in parallel ───────────────────────────────────
set -l self (realpath (status filename))
set -l jobs 16

printf "  %schecking %d inputs%s\r" "$DIM" (count $inputs) "$RESET" >&2
set -l probes (printf '%s\n' $inputs | xargs -P $jobs -I{} $self --probe {} 2>/dev/null)
printf "\r\033[2K" >&2

set -l results
for line in $inputs
    set -l name (string split '|' -- $line)[1]
    set -l probe ""
    for p in $probes
        if string match -q -- "$name|*" $p
            set probe $p
            break
        end
    end
    test -z "$probe"; and set probe (string join '|' $name (string split '|' -- $line)[2] "" unknown)
    set -a results $probe
end

# ── Print report ────────────────────────────────────────────────────
set -l width 0
for line in $results
    set -l name (string split '|' -- $line)[1]
    set width (math "max($width, "(string length -- $name)")")
end
set width (math "$width + 2")

set -l updates 0
echo
for line in $results
    set -l f (string split '|' -- $line)
    set -l name $f[1]
    set -l locked $f[2]
    set -l latest $f[3]
    set -l rel $f[4]

    set -l padded (string pad --right --width $width -- $name)
    switch $rel
        case unchanged
            printf "  %s %s\n" "$GREEN✓$RESET" "$padded"
        case unknown
            set updates (math $updates + 1)
            printf "  %s %s %s %s\n" "$YELLOW*$RESET" "$padded" \
                "$DIM?$RESET" "$DIM(unknown)$RESET"
        case '*'
            set updates (math $updates + 1)
            set -l old "$DIM"(string sub --length $REV_LEN -- $locked)"$RESET"
            set -l new "$CYAN"(string sub --length $REV_LEN -- $latest)"$RESET"
            printf "  %s %s%s -> %s %s\n" "$YELLOW*$RESET" "$padded" "$old" "$new" \
                "$DIM($rel)$RESET"
    end
end

# ── Summary ─────────────────────────────────────────────────────────
set -l total (count $results)
if test $updates -eq 0
    echo "$GREEN  All $total inputs are up to date$RESET"
else
    echo "$YELLOW $updates of $total inputs need an update$RESET"
end
