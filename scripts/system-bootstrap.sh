#!/usr/bin/env bash
# system-install.sh - First-time setup for macOS systems
set -e
source "$(dirname "$0")/colors.sh"

function check_platform() {
    if [ "$(uname)" != "Darwin" ]; then
        echo -e "${ERROR} Install is only supported on macOS"
        exit 1
    fi
}

function install_nix() {
    if ! command -v nix >/dev/null 2>&1; then
        echo -e "${INFO} Installing Nix..."
        #curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        curl -sSf -L https://install.lix.systems/lix | sh -s -- install
        echo -e "${SUCCESS} Nix installed successfully!"
        echo -e "${WARN} Please restart your terminal and run 'make install' again."
        exit 0
    else
        echo -e "${INFO} Nix already installed"
    fi
}


function setup_nix_darwin() {
    if ! command -v darwin-rebuild > /dev/null 2>&1; then
        echo -e "${INFO} Installing nix-darwin..."

        local DARWIN_CONFIGS
        local config
        DARWIN_CONFIGS=$(nix eval --impure --json .#darwinConfigurations --apply builtins.attrNames 2>/dev/null || echo "[]")
        config=$(echo "$DARWIN_CONFIGS" |nix run nixpkgs#jq -- -r '.[]' | nix run nixpkgs#fzf)

        nix run --extra-experimental-features "nix-command flakes" nixpkgs#nh -- darwin switch -H "$config" .


        echo -e "${SUCCESS} nix-darwin installed successfully!"
    else
        echo -e "${INFO} nix-darwin already installed"
    fi
}

# Main script
echo -e "${HEADER}Starting macOS Setup${RESET}"
check_platform
install_nix
setup_nix_darwin
echo -e "${SUCCESS} Installation complete!"
echo -e "${WARN} Please restart your shell and run './system-deploy.sh'\n"
