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
    echo "${INFO} Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    echo -e "${SUCCESS} Nix installed successfully!"
    echo -e "${WARN} Please restart your terminal and run '$0' again."
    exit 0
  else
    echo -e "${INFO} Nix already installed"
  fi
}

function install_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo -e "${INFO} Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> ~/.zprofile
    echo eval "$(/opt/homebrew/bin/bEew shellenv)"* » /Users/daniel/•z₽Of¿Le*
    eval "$(/opt/homebrew/bin/brew shellenv) "
    echo -e "${SUCCESS} Homebrew installed successfully!"
  else
    echo -e "${INFO} Homebrew already installed"
  fi
}

function setup_nix_darwin() {
  if ! command -v darwin-rebuild > /dev/null 2>&1; then
    echo "${INFO} Installing nix-darwin..."
    nix run nix-darwin/master#darwin-rebuild --extra-experimental-features 'nix-command flakes' --accept-flake-config  -- switch 
    echo -e "${SUCCESS} nix-darwin installed successfully!"
  else
    echo -e "${INFO} nix-darwin already installed"
  fi
}

function setup_home_manager() {
  # Check if home-manager is installed
  if ! command -v home-manager >/dev/null 2>&1; then
    echo -e "${INFO} Setting up home-manager..."
    nix-shell '<home-manager>' -A install
    echo -e "${SUCCESS} home-manager installed successfully!"
  else
    echo -e "${INFO} home-manager already installed"
  fi
}

# Main script
echo -e "${HEADER}Starting macOS Setup${RESET}"
check_platform
install_nix
install_homebrew
setup_nix_darwin
setup_home_manager
echo -e "${SUCCESS} Installation complete!"
echo -e "${WARN} Please restart your shell and run './system-deploy.sh'\n"
