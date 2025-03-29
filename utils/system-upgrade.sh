#!/usr/bin/env bash
# system-upgrade.sh - Update flakes and deploy

set -e
source "$(dirname "$0")/colors.sh"

function upgrade_flakes() {
  git add .
  
  # Update flake revisions and hashes
  ./utils/update-flake-revs.sh
  ./utils/update-hashes.py
  
  print "${INFO} Upgrading flakes..."
  
  nix --extra-experimental-features 'nix-command flakes' --accept-flake-config flake update
  
  echo "${SUCCESS} Flakes updated successfully"
}

function prompt_for_deployment() {
  echo -n "Would you like to deploy now? Y/n/c(leanup after) - Auto-continues in 5s: "
  read -t 5 -n 1 response
  echo
  
  if [ -n "$response" ] && [ "$response" != "Y" ] && [ "$response" != "y" ] && [ "$response" != "c" ]; then
    print "${INFO} Deployment skipped"
    exit 0
  fi
  
  ./utils/system-deploy.sh
  
  if [ "$response" = "c" ]; then
    ./utils/system-clean.sh
  fi
}

# Main script
upgrade_flakes
prompt_for_deployment
