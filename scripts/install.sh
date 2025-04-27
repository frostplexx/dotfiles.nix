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

# Function to clone the repository
clone_repo() {
    print_status "Cloning repository..."
    
    # Get repo URL and destination from arguments
    local repo_url="https://github.com/frostplexx/dotfiles.nix"
    local dest_dir="$HOME/dotfiles.nix"
    
    if [ -d "$dest_dir" ]; then
        read -p "Directory $dest_dir already exists. Override? [y/N] " -n 1 -r < /dev/tty
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "INFO" "Using existing directory"
            return 0
        else
            rm -rf "$dest_dir"
        fi
    fi
    
    git clone "$repo_url" "$dest_dir"
    
    if [ $? -eq 0 ]; then
        print_success "Repository cloned to $dest_dir"
        return 0
    else
        print_error "Failed to clone repository"
        return 1
    fi
}

# macOS installation function
mac_install() {
    print_header "MACOS INSTALLATION"
    
    # Step 1: Install Git
    if command_exists git; then
        print_success "Git is already installed"
    else
        print_warning "Installing git with xcode-select. Please follow the instruction of the window that will open!"
        sleep 2
        xcode-select  --install
    fi

    
    # Step 2: Clone the repository
    clone_repo || exit 1
    
    # Step 3: Install Nix
    print_status "Installing Nix and deploying..."
    "$HOME/dotfiles.nix/scripts/system-bootstrap.sh"
    
    print_header "INSTALLATION COMPLETE"
    print_success "Your macOS system has been configured with Nix"
    echo -e "  You may need to restart your computer for all changes to take effect"
}

# NixOS installation function
nixos_install() {
    print_header "NIXOS INSTALLATION"
    
    clone_repo || exit 1
    
    # Step 2: Deploy configuration
    local NIXOS_CONFIGS
    local config
    NIXOS_CONFIGS=$(nix eval --impure --json "$HOME/dotfiles.nix"#nixosConfigurations --apply builtins.attrNames 2>/dev/null || echo "[]")
    config=$(echo "$NIXOS_CONFIGS" |nix run nixpkgs#jq -- -r '.[]' | nix run nixpkgs#fzf)

    print_status "Rebuilding NixOS configuration..."
    # sudo nixos-rebuild switch --flake .#"$config"
    nix run nixpkgs#nh -- os switch --hostname "$config" "$HOME/dotfiles.nix"
    
    print_header "INSTALLATION COMPLETE"
    print_success "Your NixOS system has been configured"
}

# Welcome message
echo -e "${BLUE}${BOLD}
╭───────────────────────────────────────────────────────╮
│                                                       │
│       ${GREEN}❄️  Welcome to Nix Bootstrap Installer${BLUE}          │
│                                                       │
╰───────────────────────────────────────────────────────╯${RESET}"

# Detect OS
OS_TYPE=$(uname)
if [ "$OS_TYPE" = "Darwin" ]; then
    OS_NAME="macOS"
    STEPS="
  ${GREEN}✓${RESET} Install git (if not already installed)
  ${GREEN}✓${RESET} Clone the repository
  ${GREEN}✓${RESET} Bootstrap Nix
  ${GREEN}✓${RESET} Deploy configuration"
elif [ -f /etc/os-release ] && grep -q "ID=nixos" /etc/os-release; then
    OS_NAME="NixOS"
    STEPS="
  ${GREEN}✓${RESET} Clone the repository
  ${GREEN}✓${RESET} Deploy configuration"
else
    OS_NAME="Unsupported OS"
fi

if [ "$OS_NAME" != "Unsupported OS" ]; then
    echo -e "${YELLOW}This script will help you set up your ${OS_NAME} environment with Nix${RESET}"
    echo -e "${YELLOW}It will:${RESET}${STEPS}"
    echo
    echo -e "${YELLOW}Starting installation...${RESET}"
    echo

    echo
    read -p "Do you want to continue? [Y/n] " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        # Run installation based on OS type
        if [ "$OS_TYPE" = "Darwin" ]; then
            mac_install
        elif [ -f /etc/os-release ] && grep -q "ID=nixos" /etc/os-release; then
            nixos_install
        fi
    else
        print_status "INFO" "Installation cancelled by user"
        exit 0
    fi
else
    print_error "Installation is only supported on macOS and NixOS"
    exit 1
fi
