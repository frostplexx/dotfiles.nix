#!/usr/bin/env fish

# ── Colors ──────────────────────────────────────────────────────────
set -l RED    (set_color red)
set -l GREEN  (set_color green)
set -l YELLOW (set_color yellow)
set -l BLUE   (set_color blue)
set -l MAGENTA (set_color magenta)
set -l CYAN   (set_color cyan)
set -l BOLD   (set_color --bold)
set -l DIM    (set_color --dim)
set -l RESET  (set_color normal)

# ── Helpers ─────────────────────────────────────────────────────────
function info
    echo "$BLUE$BOLD  $argv$RESET"
end

function ok
    echo "$GREEN$BOLD  $argv$RESET"
end

function warn
    echo "$YELLOW$BOLD  $argv$RESET"
end

function err
    echo "$RED$BOLD  $argv$RESET"
end

function step
    echo
    echo "$MAGENTA$BOLD▸ $argv$RESET"
end

function dim
    echo "$DIM  $argv$RESET"
end

# ── Usage ───────────────────────────────────────────────────────────
function usage
    echo "$BOLD""Usage:$RESET "(status basename)" [OPTIONS]"
    echo
    echo "$BOLD""Options:$RESET"
    echo "  -d, --dotfiles DIR     Path to dotfiles repo $DIM(required)$RESET"
    echo "  -c, --nix-config STR   NIX_CONFIG value $DIM(default: \"\")$RESET"
    echo "  -n, --nh-cmd CMD       nh subcommand $DIM(default: \"os\")$RESET"
    echo "  -h, --help             Show this help"
    exit 0
end

# ── Parse args ──────────────────────────────────────────────────────
set -l DOTFILES ""
set -l NIX_CONFIG ""
set -l NH_CMD "os"

argparse 'd/dotfiles=' 'c/nix-config=' 'n/nh-cmd=' 'h/help' -- $argv
or begin
    err "Invalid arguments"
    usage
end

set -q _flag_help; and usage
set -q _flag_dotfiles; and set DOTFILES $_flag_dotfiles
set -q _flag_nix_config; and set NIX_CONFIG $_flag_nix_config
set -q _flag_nh_cmd; and set NH_CMD $_flag_nh_cmd

if test -z "$DOTFILES"
    err "Missing required --dotfiles path"
    usage
end

if not test -d "$DOTFILES"
    err "Dotfiles path does not exist: $DOTFILES"
    exit 1
end

# ── Pull ────────────────────────────────────────────────────────────
step "Pulling latest changes"
cd "$DOTFILES"
if git pull --rebase --autostash 2>/dev/null
    ok "Pulled with rebase"
else if git pull --no-rebase --autostash 2>/dev/null
    warn "Pulled with merge (rebase failed)"
else
    warn "Pull failed — continuing with local state"
end

# ── Check diff ──────────────────────────────────────────────────────
step "Checking for changes in flake.lock"
if git diff HEAD~1 --quiet -- flake.lock 2>/dev/null
    ok "No changes in flake.lock — nothing to do"
    exit 0
end

# ── Show what changed ───────────────────────────────────────────────
step "Changes detected in flake.lock"
printf "%s%s  %-25s %-12s → %s%s\n" "$CYAN" "$BOLD" INPUT "OLD REV" "NEW REV" "$RESET"
printf "%s  %-25s %-12s   %s%s\n" "$DIM" "─────────────────────────" "────────────" "────────────" "$RESET"

set -l current_input ""
set -l old_rev ""
set -l new_rev ""

git diff HEAD~1 -U5 -- flake.lock | while read -l line
    # Grab input name from context lines like:   "nixpkgs": {
    if string match -rq '^\s*"([a-zA-Z0-9_-]+)":\s*\{' -- "$line"
        set current_input (string match -r '^\s*"([a-zA-Z0-9_-]+)":\s*\{' -- "$line")[2]
        set old_rev ""
        set new_rev ""
    end

    # Old rev (removed line)
    if string match -rq '^-.*"rev":\s*"([a-f0-9]+)"' -- "$line"
        set old_rev (string sub -l 12 (string match -r '^-.*"rev":\s*"([a-f0-9]+)"' -- "$line")[2])
    end

    # New rev (added line)
    if string match -rq '^\+.*"rev":\s*"([a-f0-9]+)"' -- "$line"
        set new_rev (string sub -l 12 (string match -r '^\+.*"rev":\s*"([a-f0-9]+)"' -- "$line")[2])
    end

    # Print when we have a complete pair
    if test -n "$current_input" -a -n "$old_rev" -a -n "$new_rev"
        printf "  %s%-25s%s %s%-12s%s → %s%s%s\n" \
            "$YELLOW" "$current_input" "$RESET" \
            "$RED" "$old_rev" "$RESET" \
            "$GREEN" "$new_rev" "$RESET"
        set current_input ""
        set old_rev ""
        set new_rev ""
    end
end

echo

# ── Deploy ──────────────────────────────────────────────────────────
step "Deploying with nh $NH_CMD switch"
if NIX_CONFIG="$NIX_CONFIG" nh $NH_CMD switch
    ok "Deploy successful"
else
    err "Deploy failed"
    exit 1
end

ok "Done!"
