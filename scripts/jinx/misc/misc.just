
[macos]
[group('utility')]
[doc('Sets the current screen to HiDPI mode')]
set_screen_hidpi:
    @"$HOME/dotfiles.nix/scripts/jinx/misc/highres_display.sh"

[group('utility')]
[doc('Generates an SSH config file from hosts inside 1Password')]
[working-directory("./")]
generate_ssh_hosts:
    @"$HOME/dotfiles.nix/scripts/jinx/misc/ssh.fish"


[group('utility')]
[doc('Edit the system config')]
edit:
    nvim "$HOME/dotfiles.nix/"
