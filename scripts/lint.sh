#!/usr/bin/env bash
# lint.sh - Format and lint nix files

set -e
source "$(dirname "$0")/colors.sh"

function format_nix_files() {
  echo -e "${INFO} Formatting nix files...\a\n"
  
  if command -v nh >/dev/null 2>&1; then
    nix fmt .
  else
    nix --extra-experimental-features 'nix-command flakes' --accept-flake-config fmt .
  fi
}

function run_statix() {
  echo -e "${INFO} Running statix..."
  
  if command -v statix >/dev/null 2>&1; then
    statix check .
  else
    nix run --extra-experimental-features 'nix-command flakes' --accept-flake-config nixpkgs#statix -- check .
  fi
}

function run_deadnix() {
  echo -e "${INFO} Running deadnix..."
  
  if command -v deadnix >/dev/null 2>&1; then
    deadnix -eq .
  else
    nix run --extra-experimental-features 'nix-command flakes' --accept-flake-config nixpkgs#deadnix -- -eq .
  fi
}

# Main script
format_nix_files
run_statix
run_deadnix

echo -e "${SUCCESS} Linting complete"
