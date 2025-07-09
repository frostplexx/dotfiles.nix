
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
[no-cd]
edit:
    cd "$HOME/dotfiles.nix/"
    nvim "$HOME/dotfiles.nix/"

[macos]
[group('utility')]
[doc('Clear DNS Cache')]
[confirm]
clear_dns:
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
