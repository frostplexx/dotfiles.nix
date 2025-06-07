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
	curl -L https://install.determinate.systems/determinate-pkg/stable/Universal --output /tmp/detnix-installer.pkg
    	sudo installer -verbose -pkg /tmp/detnix-installer.pkg -target /
	rm /tmp/detnix-installer.pkg
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
        
        # Create the list of available configurations
        configs=($(echo "$DARWIN_CONFIGS" | nix run nixpkgs#jq -- -r '.[]'))
        
        if [ ${#configs[@]} -eq 0 ]; then
            echo -e "${ERROR} No configurations found."
            exit 1
        fi

        # Display a numbered list and allow the user to choose
        echo "Please select a configuration:"
        select config in "${configs[@]}"; do
            if [ -n "$config" ]; then
                break
            else
                echo "Invalid choice, please try again."
            fi
        done < /dev/tty

        # Deploy the chosen configuration
        #nix run --extra-experimental-features "nix-command flakes" nixpkgs#nh -- darwin switch -H "$config" "$HOME/dotfiles.nix"
	sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake /Users/daniel/dotfiles.nix#"$config"


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
