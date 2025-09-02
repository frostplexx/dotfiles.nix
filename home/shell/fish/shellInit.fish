# Nothing to do if not inside an interactive shell.
if not status is-interactive
    return 0
end

# Remove the gretting message.
set -U fish_greeting

# Manpager
set -U MANPAGER "nvim +Man!"

# Vi mode.
set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore

# Source additional scripts
if test -d $HOME/.fish_scripts
    for file in $HOME/.fish_scripts/*.fish
        source $file &
    end
end

# Color theme.
fish_config theme choose "Catppuccin Mocha"

if test (uname) = Linux -a (tty) = /dev/tty2
    /home/daniel/dotfiles.nix/machines/pc-nixos/gh.sh &
end
