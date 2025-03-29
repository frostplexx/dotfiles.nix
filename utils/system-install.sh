#!/usr/bin/env bash
# system-install.sh - First-time setup for macOS systems

set -e
source "$(dirname "$0")/colors.sh"

function check_platform() {
  if [ "$(uname)" != "Darwin" ]; then
    echo "${ERROR} Install is only supported on macOS"
    exit 1
  fi
}

function install_nix() {
  if ! command -v nix >/dev/null 2>&1; then
    echo "${INFO} Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    echo "${SUCCESS} Nix installed successfully!"
    echo "${WARN} Please restart your terminal and run '$0' again."
    exit 0
  else
    echo "${INFO} Nix already installed"
  fi
}


function install_homebrew() {
  echo "${INFO} Checking for Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "${INFO} Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "${SUCCESS} Homebrew installed successfully!"
  else
    echo "${INFO} Homebrew already installed"
  fi
}

function setup_nix_darwin() {
  echo "${INFO} Setting up nix-darwin..."
  if ! command -v darwin-rebuild > /dev/null 2>&1; then
    echo "${INFO} Installing nix-darwin..."
    nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
    ./result/bin/darwin-installer
    echo "${SUCCESS} nix-darwin installed successfully!"
  else
    echo "${INFO} nix-darwin already installed"
  fi
}

function setup_home_manager() {
  echo "${INFO} Setting up home-manager..."
  nix-shell '<home-manager>' -A install
  echo "${SUCCESS} home-manager installed successfully!"
}

function init_darwin() {
  echo "${INFO} Initializing nix-darwin configuration..."
  # Add any additional Darwin-specific initialization here
}

# Main script
echo "${HEADER}Starting macOS Setup${RESET}"

check_platform
install_nix
install_homebrew
setup_nix_darwin
setup_home_manager
init_darwin

echo "${SUCCESS} Installation complete!"
echo "${WARN} Please restart your shell and run './system-deploy.sh'\n"
