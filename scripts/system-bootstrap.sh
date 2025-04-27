#!/usr/bin/env bash
# system-install.sh - First-time setup for macOS systems
set -e
source "$(dirname "$0")/colors.sh"

function check_platform() {
    if [ "$(uname)" != "Darwin" ]; then
        echo -e "${ERROR} Bootstrap is only supported on macOS"
        exit 1
    fi
}

function install_nix() {
    if ! command -v nix >/dev/null 2>&1; then
        echo -e "${INFO} Installing Nix..."
        yes | curl -sSf -L https://install.lix.systems/lix | sh -s -- install
        # Source Nix immediately
        if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            echo -e "${SUCCESS} Nix installed and environment loaded!"
        else
            echo -e "${ERROR} Failed to find nix-daemon.sh to source environment"
            exit 1
        fi
    else
        echo -e "${WARN} Nix already installed"
    fi
}


function setup_nix_darwin() {
    if ! command -v darwin-rebuild > /dev/null 2>&1; then
        echo -e "${INFO} Installing nix-darwin and deploying first generation..."

        local DARWIN_CONFIGS
        local config
        DARWIN_CONFIGS=$(nix eval --impure --json "$HOME/dotfiles.nix"#darwinConfigurations --apply builtins.attrNames 2>/dev/null || echo "[]")
        config=$(echo "$DARWIN_CONFIGS" |nix run nixpkgs#jq -- -r '.[]' | nix run nixpkgs#fzf)

        nix run --extra-experimental-features "nix-command flakes" github:viperml/nh -- darwin switch -H "$config" "$HOME/dotfiles.nix"


        echo -e "${SUCCESS} deployed successfully!"
    else
        echo -e "${WARN} nix-darwin already installed"
    fi
}

# Main script
echo -e "${INFO} Starting macOS Setup${RESET}"
check_platform
install_nix
setup_nix_darwin
echo -e "${INFO} Installation complete!"
