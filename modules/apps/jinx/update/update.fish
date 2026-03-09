#!/usr/bin/env fish

# ── Colors ──────────────────────────────────────────────────────────
set -g RED    (set_color red)
set -g GREEN  (set_color green)
set -g YELLOW (set_color yellow)
set -g BLUE   (set_color blue)
set -g MAGENTA (set_color magenta)
set -g CYAN   (set_color cyan)
set -g BOLD   (set_color --bold)
set -g DIM    (set_color --dim)
set -g RESET  (set_color normal)

# ── Helpers ─────────────────────────────────────────────────────────
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

# ── Spinner ─────────────────────────────────────────────────────────
function spin_start --argument-names msg
    set -g SPIN_STOP (mktemp)
    rm -f $SPIN_STOP
    set -l escaped_msg (string escape -- $msg)
    fish -c "
        set msg $escaped_msg
        set frames ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
        set i 1
        while not test -f $SPIN_STOP
            printf \"\\r  \\033[36m%s\\033[0m %s\" \$frames[\$i] \$msg
            set i (math \"(\$i % 10) + 1\")
            sleep 0.08
        end
    " &
    set -g SPIN_PID $last_pid
end

function spin_stop --argument-names symbol color msg
    touch $SPIN_STOP
    wait $SPIN_PID 2>/dev/null
    printf "\r\033[2K  %s%s%s %s" "$color$BOLD" "$symbol" "$RESET" "$msg"
    rm -f $SPIN_STOP
end

function spin_done
    echo
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

# ── Pull & analyze ──────────────────────────────────────────────────
echo
cd "$DOTFILES"

# Save pre-pull HEAD so we can diff against it (not just HEAD~1)
set -l pre_pull_ref (git rev-parse HEAD)

spin_start "Pulling latest changes..."
if git pull --rebase --autostash &>/dev/null
    spin_stop "" "$GREEN" "Pulled with rebase"
else if git pull --no-rebase --autostash &>/dev/null
    spin_stop "" "$YELLOW" "Pulled with merge (rebase failed)"
else
    spin_stop "" "$YELLOW" "Pull failed — continuing with local state"
end

# Check diff against pre-pull state
spin_start "Checking for changes in flake.lock..."
sleep 0.3
if git diff $pre_pull_ref --quiet -- flake.lock 2>/dev/null
    spin_stop "" "$GREEN" "No changes in flake.lock — nothing to do"
    spin_done
    exit 0
end
spin_stop "" "$BLUE" "Changes detected in flake.lock"

# Compute diff with jq
spin_start "Comparing flake inputs..."

set -l diff_output (jq -n \
    --slurpfile old (git show "$pre_pull_ref":flake.lock 2>/dev/null | psub) \
    --slurpfile new (cat flake.lock | psub) '
    ($old[0].nodes | to_entries | map(select(.key != "root" and .value.locked.rev)) | map({key: .key, value: .value.locked.rev}) | from_entries) as $old_revs |
    ($new[0].nodes | to_entries | map(select(.key != "root" and .value.locked.rev)) | map({key: .key, value: .value.locked.rev}) | from_entries) as $new_revs |
    ($new_revs | keys[]) as $input |
    $old_revs[$input] as $old_rev |
    $new_revs[$input] as $new_rev |
    select($old_rev and $new_rev and $old_rev != $new_rev) |
    "\($input) \($old_rev[0:12]) \($new_rev[0:12])"
' -r)

set -l change_count (count $diff_output)

# Stop spinner and clear the line
touch $SPIN_STOP
wait $SPIN_PID 2>/dev/null
printf "\r\033[2K"
rm -f $SPIN_STOP

# ── Display summary table ──────────────────────────────────────────
printf "  %s%s  %-23s %-12s    %-12s%s\n" "$CYAN" "$BOLD" INPUT "OLD REV" "NEW REV" "$RESET"
printf "  %s┌─────────────────────────┬──────────────┬──────────────┐%s\n" "$DIM" "$RESET"

for line in $diff_output
    set -l parts (string split " " $line)
    set -l input $parts[1]
    set -l old_rev $parts[2]
    set -l new_rev $parts[3]
    printf "  %s│%s %s%-23s%s %s│%s %s%-12s%s %s│%s %s%-12s%s %s│%s\n" \
        "$DIM" "$RESET" \
        "$YELLOW$BOLD" "$input" "$RESET" \
        "$DIM" "$RESET" \
        "$RED" "$old_rev" "$RESET" \
        "$DIM" "$RESET" \
        "$GREEN" "$new_rev" "$RESET" \
        "$DIM" "$RESET"
end

printf "  %s└─────────────────────────┴──────────────┴──────────────┘%s\n" "$DIM" "$RESET"
echo

# ── Deploy ──────────────────────────────────────────────────────────

# Set the environment NH_FLAKE to dotfiles path so nh can find the flake if it doesnt exist
set -gx NH_FLAKE "$DOTFILES"


if NIX_CONFIG="$NIX_CONFIG" nh $NH_CMD switch
    echo
    ok "Deploy successful"
else
    echo
    err "Deploy failed"
    exit 1
end
