#!/usr/bin/env bash

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'
# Formatted output prefixes
SUCCESS="${GREEN}${BOLD}[SUCCESS]${RESET}"
ERROR="${RED}${BOLD}[ERROR]${RESET}"
WARN="${YELLOW}${BOLD}[WARN]${RESET}"
INFO="${BLUE}${BOLD}[INFO]${RESET}"
NC='\033[0m'  # No Color / reset

OS_TYPE=$(uname)
# Get repo URL and destination from arguments
REPO_URL="https://github.com/frostplexx/dotfiles.nix"
DEST_DIR="$HOME/dotfiles.nix"

# Function to display status messages
print_status() {
    echo -e "${BLUE}${BOLD}[INFO]${RESET} $1"
}

# Function to display success messages
print_success() {
    echo -e "${GREEN}${BOLD}✓${RESET} $1"
}

# Function to display error messages
print_error() {
    echo -e "${RED}${BOLD}[ERROR]✗${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}[WARN]${RESET} $1"
}

# Function to display section headers
print_header() {
    echo
    echo -e "${CYAN}${BOLD}$1${RESET}"
    echo -e "${CYAN}${BOLD}$(printf '%.s─' $(seq 1 ${#1}))${RESET}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


check_tools() {
    if ! command -v git > /dev/null; then return 1; fi # check for git
    if ! command -v curl > /dev/null; then return 1; fi # check for curl
    if ! command -v jq > /dev/null; then return 1; fi # this exists on mac always

    if [ "$OS_TYPE" = "Darwin" ]; then
        if ! xcode-select --install 2>&1 | grep -q "already installed"; then
            return 1
        fi
    fi

    return 0;
}

# Installs git, curl and command line utilities
install_tools() {
    if [ "$OS_TYPE" = "Darwin" ]; then
        
        # install command line tools on macos because it contains git
        if ! xcode-select -p >/dev/null 2>&1; then
            print_status "Installing Xcode Command Line Tools..."
            xcode-select --install
        
            print_status "Waiting for Xcode Command Line Tools installation to complete..."
            until xcode-select -p >/dev/null 2>&1; do
                sleep 5
            done

            print_success "Xcode Command Line Tools installed."
        else
            print_success "Xcode Command Line Tools already installed."
        fi
    elif [ -f /etc/os-release ] && grep -q "ID=nixos" /etc/os-release; then
        print_status "Installig Git..."
        nix-env -i git > /dev/null
        print_status "Installig cUrl..."
        nix-env -i curl > /dev/null
        print_status "Installig jq..."
        nix-env -i jq > /dev/null
    fi
}

check_nix() {
    if ! command -v nix > /dev/null; then return 1; fi
    return 0  # Add this missing return
}

install_nix(){
    if [ "$OS_TYPE" = "Darwin" ]; then
        if ! command -v nix >/dev/null 2>&1; then
	    curl -L https://install.determinate.systems/determinate-pkg/stable/Universal --output /tmp/detnix-installer.pkg
        	sudo installer -verbose -pkg /tmp/detnix-installer.pkg -target /
	    rm /tmp/detnix-installer.pkg
 	    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
                source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
                print_success "Nix installed and environment loaded!"
            else
                print_error "Failed to find nix-daemon.sh to source environment"
                exit 1
            fi
        else
            echo -e "${WARN} Nix already installed"
        fi
    elif [ -f /etc/os-release ] && grep -q "ID=nixos" /etc/os-release; then
        print_error "Couldnt find nix on NixOS...this is a big problem, arborting"
    fi
}

check_flake(){
    if [ -d "$DEST_DIR" ]; then
        return 0
    fi

    return 1
}

install_flake(){
    # Get repo URL and destination from arguments
    print_status "Cloning repository..."
    
    if [ -d "$DEST_DIR" ]; then
        read -p "Directory $DEST_DIR already exists. Override? [y/N] " -n 1 -r < /dev/tty
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "INFO" "Using existing directory"
            return 0
        else
            rm -rf "$DEST_DIR"
        fi
    fi
    
    git clone "$REPO_URL" "$DEST_DIR"
    
    if [ $? -eq 0 ]; then
        print_success "Repository cloned to $DEST_DIR"
        return 0
    else
        print_error "Failed to clone repository"
        return 1
    fi
}


deploy_flake() {
    if [ "$OS_TYPE" = "Darwin" ]; then
        print_status "Installing nix-darwin and deploying first generation..."

        local DARWIN_CONFIGS
        local config
        DARWIN_CONFIGS=$(nix eval --impure --json "$HOME/dotfiles.nix"#darwinConfigurations --apply builtins.attrNames 2>/dev/null || echo "[]")
        
        # Create the list of available configurations
        configs=("$(echo "$DARWIN_CONFIGS" | jq -r '.[]')")
        
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
                print_error "Invalid choice, please try again."
            fi
        done < /dev/tty

        # Deploy the chosen configuration
	sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "$HOME/dotfiles.nix#""$config"
    elif [ -f /etc/os-release ] && grep -q "ID=nixos" /etc/os-release; then

        local NIXOS_CONFIGS
        local config
        NIXOS_CONFIGS=$(nix --extra-experimental-features nix-command --extra-experimental-features flakes eval --impure --json "$HOME/dotfiles.nix"#nixosConfigurations --apply builtins.attrNames 2>/dev/null || echo "[]")
        
	configs=("$(echo "$NIXOS_CONFIGS" | jq -r '.[]')")

  	echo "Please select a configuration:"
        select config in "${configs[@]}"; do
            if [ -n "$config" ]; then
                break
            else
                print_error "Invalid choice, please try again."
            fi
        done < /dev/tty       
	
 	print_status "Rebuilding NixOS configuration..."
        nixos-rebuild switch --flake "$HOME/dotfiles.nix#""$config" 
        print_success "Your NixOS system has been configured"
    else
    	echo -e "${RED} Couldn't determine OS"
    fi

}


if [ "$OS_TYPE" = "Darwin" ] || ([ -f /etc/os-release ] && grep -q "ID=nixos" /etc/os-release); then
    echo
    print_header "❄️ Nix Bootstrap Installer ❄️"
    echo
    echo
    
    # Check what needs to be done (store exit codes)
    check_tools; tools_installed=$?
    check_nix; nix_installed=$?
    check_flake; flake_exists=$?
    
    echo -e "${YELLOW}This script will help you set up your ${OS_TYPE}. It will:"
    echo -e "${YELLOW}"
    # Check exit codes (0 = success, 1 = failure)
    if [ $tools_installed -ne 0 ]; then echo -e "• Install git and curl"; fi
    if [ $nix_installed -ne 0 ]; then echo -e "• Install determinate nix"; fi
    if [ $flake_exists -ne 0 ]; then echo -e "• Clone the flake"; fi
    echo -e "• Deploy the flake"
    echo -e "${RESET}"

    echo
    
    read -p "Do you want to continue? [Y/n] " -n 1 -r < /dev/tty

    echo 
    echo
    if [ $tools_installed -ne 0 ]; then install_tools ; fi
    if [ $nix_installed -ne 0 ]; then install_nix ; fi
    if [ $flake_exists -ne 0 ]; then install_flake ; fi

    deploy_flake


    echo
    print_header " == INSTALLATION COMPLETE =="

else
    print_error "Installation is only supported on macOS and NixOS"
    exit 1
fi
