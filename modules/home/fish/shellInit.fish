# Remove the greeting message.
set -g fish_greeting

# Manpager
set -x MANPAGER "nvim +Man!"

# Vi mode.
set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore

# Source rex bin dir
if set -q REX_BIN_DIR
    fish_add_path --path --prepend --move $REX_BIN_DIR
end
