
# Nothing to do if not inside an interactive shell.
if not status is-interactive
    return 0
end

# Set up Ghostty's shell integration.
if test -n "$GHOSTTY_RESOURCES_DIR"
    source $GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
end


# Figure out which operating system we're in.
set -l os (uname)

# Remove the gretting message.
set -U fish_greeting

# Vi mode.
set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore


# Color theme.
fish_config theme choose "Catppuccin Mocha"
