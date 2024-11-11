
# bin/shell-select
#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles.nix"  # Updated to match your vars.location
SHELLS_DIR="$DOTFILES_DIR/shells"
DIRENV_FILE=".envrc"
SHELL_CACHE_FILE="$HOME/.local/share/shell-select/last-shell"

# Create cache directory if it doesn't exist
mkdir -p "$(dirname "$SHELL_CACHE_FILE")"

# Function to generate .envrc file
generate_envrc() {
  local shell_name="$1"
  echo "use flake \"$DOTFILES_DIR#$shell_name\"" > "$DIRENV_FILE"
  echo "$shell_name" > "$SHELL_CACHE_FILE"
}

# Function to get last used shell for this directory
get_last_shell() {
  if [ -f "$SHELL_CACHE_FILE" ]; then
    cat "$SHELL_CACHE_FILE"
  fi
}

# Get list of available shells
shells=$(ls "$SHELLS_DIR" | grep '\.nix$' | sed 's/\.nix$//' | grep -v '^default$')

# If no shell specified and .envrc exists, use the last shell
if [ -f "$DIRENV_FILE" ]; then
  last_shell=$(get_last_shell)
  if [ -n "$last_shell" ]; then
    selected_shell="$last_shell"
  fi
else
  # Use fzf to select shell with a preview window showing the shell contents
  selected_shell=$(echo "$shells" | fzf \
    --prompt="Select development shell: " \
    --preview="cat $SHELLS_DIR/{}.nix" \
    --preview-window=right:50%:wrap)
fi

if [ -n "$selected_shell" ]; then
  # Generate .envrc file
  generate_envrc "$selected_shell"

  # Allow direnv
  direnv allow

  echo "🚀 Development shell '$selected_shell' activated for this directory!"
fi
