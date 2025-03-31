#!/usr/bin/env bash
# system-deploy.sh - Deploy system configuration
set -e
source "$(dirname "$0")/colors.sh"

function switch_system() {
    git --no-pager diff --no-prefix --minimal --unified=0 .
    git add .
    # Check if nh is available
    if [ "$(uname)" = "Darwin" ]; then
        NIX_CMD="darwin"
    else
        NIX_CMD="os"
    fi
    
    # Add --update flag only if arguments are passed
    if [ $# -gt 0 ]; then
        ./utils/update-flake-revs.sh
        nix run github:viperml/nh -- $NIX_CMD switch --update
    else
        nix run github:viperml/nh -- $NIX_CMD switch
    fi
}

function deploy_system() {
    local action="$1"
    
    case "$action" in
        "update")
            echo -e "${GREEN}Deploying system configuration with update...${NC}"
            switch_system "update"
            ;;
        "deploy")
            echo -e "${GREEN}Deploying system configuration without update...${NC}"
            switch_system
            ;;
        *)
            echo -e "${YELLOW}Invalid argument: $action${NC}"
            show_usage
            exit 1
            ;;
    esac
}

function show_usage() {
    echo -e "${YELLOW}Usage: $0 [deploy|update]${NC}"
    echo -e "${YELLOW}  deploy - Deploy system configuration without updating${NC}"
    echo -e "${YELLOW}  update - Deploy system configuration with update${NC}"
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    show_usage
    exit 0
else
    deploy_system "$1"
fi
