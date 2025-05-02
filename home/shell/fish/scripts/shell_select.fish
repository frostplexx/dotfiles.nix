#!/usr/bin/env fish

function shinit
    # Configuration
    set DOTFILES_DIR "$HOME/dotfiles.nix"
    set SHELLS_DIR "$DOTFILES_DIR/templates"
    set ENVRC_FILE ".envrc"

    # List available shells
    function list_shells
        find "$SHELLS_DIR" -maxdepth 1 -name '*.nix' -not -name 'default.nix' -exec basename {} .nix \;
    end

    # Generate .envrc for the selected shell
    function generate_envrc
        set shell_name $argv[1]
        echo "use flake \"$DOTFILES_DIR#$shell_name\"" > "$ENVRC_FILE"
        echo "export SHELL_TYPE=\"$shell_name\"" >> "$ENVRC_FILE"
        
        # Allow direnv
        direnv allow
    end

    # Main logic
    if test -f "$ENVRC_FILE"
        set current_shell (grep 'SHELL_TYPE' "$ENVRC_FILE" | string split -f2 '"')
        echo "Shell '$current_shell' is already activated."
    else
        set selected_shell (list_shells | fzf --prompt="Select a shell: ")
        if test -n "$selected_shell"
            generate_envrc "$selected_shell"
            echo "Shell '$selected_shell' activated."
        else
            echo "No shell selected."
        end
    end
end
