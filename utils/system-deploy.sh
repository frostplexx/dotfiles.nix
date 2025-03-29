#!/usr/bin/env bash
# system-deploy.sh - Deploy system configuration

set -e
source "$(dirname "$0")/colors.sh"

function select_config() {
    HOSTNAME=$(hostname | sed -E 's/([a-z]*-)([a-z]*-)([a-z]*)/\3/')
    CONFIGS=$(awk '/= \{/{name=$1} /system =/{if(name) print name}' hosts/default.nix | sed 's/=//' | tr -d ' ')

    if echo "$CONFIGS" | grep -q "$HOSTNAME"; then
        CONFIG=$HOSTNAME
        echo -e "${INFO} Using configuration for $CONFIG"
    else
        echo -e "${INFO} Hostname not found in configs. Select a configuration:"
        CONFIG=$(echo "$CONFIGS" | fzf)
        if [ -z "$CONFIG" ]; then
            echo -e "${ERROR} No configuration selected"
            exit 1
        fi
    fi

    echo -e "${INFO} Selected configuration: $CONFIG"
    return 0
}

function deploy_system() {
    local config=$1

    ./utils/lint.sh || { echo -e "${ERROR} Linting failed"; exit 1; }

    # Show changes
    git --no-pager diff --no-prefix --minimal --unified=0 .
    git add .

    # Check if nh is available
        if [ "$(uname)" = "Darwin" ]; then
            NIX_CMD="darwin"
        else
            NIX_CMD="os"
        fi

        nix run github:viperml/nh -- $NIX_CMD switch -H $config .
}

# Main script
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 [CONFIG]"
    echo "Deploys the system configuration. If CONFIG is not provided, it auto-selects based on hostname."
    exit 0
fi

if [ -n "$1" ]; then
    CONFIG=$1
else
    select_config
fi

deploy_system $CONFIG
