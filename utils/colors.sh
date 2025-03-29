#!/usr/bin/env bash
# colors.sh - Terminal color definitions
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'
# Formatted output prefixes
SUCCESS="${GREEN}${BOLD}[SUCCESS]${RESET}"
ERROR="${RED}${BOLD}[ERROR]${RESET}"
WARN="${YELLOW}${BOLD}[WARN]${RESET}"
INFO="${BLUE}${BOLD}[INFO]${RESET}"
