#!/usr/bin/env bash

# Configuration
DOTFILES_DIR="$HOME/dotfiles.nix"
SHELLS_DIR="$DOTFILES_DIR/templates"
ENVRC_FILE=".envrc"

# List available shells
list_shells() {
    find "$SHELLS_DIR" -maxdepth 1 -name '*.nix' -not -name 'default.nix' -exec basename {} .nix \;
}

# Generate .envrc for the selected shell
generate_envrc() {
    local shell_name="$1"
    cat > "$ENVRC_FILE" << EOF
use flake "$DOTFILES_DIR#$shell_name"
export SHELL_TYPE="$shell_name"
EOF
    # Allow direnv
    direnv allow
}

# Main logic
if [ -f "$ENVRC_FILE" ]; then
    current_shell=$(grep 'SHELL_TYPE' "$ENVRC_FILE" | cut -d'"' -f2)
    echo "Shell '\$current_shell' is already activated."
else
    selected_shell=$(list_shells | fzf --prompt="Select a shell: ")
    if [ -n "$selected_shell" ]; then
        generate_envrc "$selected_shell"
        echo "Shell '\$selected_shell' activated."
    else
        echo "No shell selected."
    fi
fi