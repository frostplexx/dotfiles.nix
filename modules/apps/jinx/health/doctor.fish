#!/usr/bin/env fish

# Check that everything `jinx deploy` and `jinx update` rely on is in place.

set -g dotfiles $argv[1]
set -g failures 0

function row --argument-names name ok detail
    printf "  \033[2m%-22s\033[0m" "$name"
    if test "$ok" = 1
        echo -e "\033[32m \033[0m  \033[2m$detail\033[0m"
    else
        echo -e "\033[31m \033[0m  \033[31m$detail\033[0m"
        set -g failures (math $failures + 1)
    end
end

# Run a command quietly; report pass/fail with a hint on failure.
function probe --argument-names name hint
    if $argv[3..] >/dev/null 2>&1
        row $name 1 ok
    else
        row $name 0 $hint
    end
end

echo -e "\n\033[1m  jinx doctor\033[0m\n"

# ── Tools ────────────────────────────────────────────────────────────
for tool in nix nh just git jq fzf gh op alejandra statix deadnix
    if command -q $tool
        row $tool 1 (command -v $tool)
    else
        row $tool 0 "not found"
    end
end

echo ""

# ── Repo and keys ────────────────────────────────────────────────────
if test -f "$dotfiles/flake.nix"
    row dotfiles 1 $dotfiles
else
    row dotfiles 0 "no flake.nix in $dotfiles"
end

if test -f ~/.config/sops/age/keys.txt
    row "sops age key" 1 "~/.config/sops/age/keys.txt"
else
    row "sops age key" 0 "missing ~/.config/sops/age/keys.txt"
end

# ── Logins and services ──────────────────────────────────────────────
# With desktop-app integration `op whoami` says "not signed in" until a
# command triggers Touch ID, so only check that an account is configured.
if test -n "$(op account list 2>/dev/null)"
    row "1Password CLI" 1 "account configured"
else
    row "1Password CLI" 0 "no account (op account add, or enable app integration)"
end
probe "GitHub CLI" "not logged in (gh auth login)" gh auth status
probe "determinate-nixd" "not running" determinate-nixd status
probe "frostplexx cachix" "unreachable" curl -sf --max-time 5 https://frostplexx.cachix.org/nix-cache-info

echo ""
echo -e "  \033[2m─────────────────────────────────\033[0m"
if test $failures -eq 0
    echo -e "   \033[32mReady to deploy\033[0m\n"
else
    echo -e "   \033[31m$failures problem(s) found\033[0m\n"
    exit 1
end
