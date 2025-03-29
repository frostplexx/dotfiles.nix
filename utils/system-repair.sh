#!/usr/bin/env bash
# system-repair.sh - Repair nix store and fix git hooks

set -e
source "$(dirname "$0")/colors.sh"


function repair_nix_store() {
  echo -e "${INFO} Verifying and repairing Nix store..."
  
sudo nix-store --verify --check-contents --repair
  
  echo -e "${SUCCESS} Repair complete"
}

# Main script
repair_nix_store
