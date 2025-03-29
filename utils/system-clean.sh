#!/usr/bin/env bash

# system-clean.sh - Clean up old generations and optimize nix store

set -e
source "$(dirname "$0")/colors.sh"

function clean_generations() {
  
nix run github:viperml/nh -- clean all
  
}

# Main script
clean_generations
