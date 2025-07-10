
[macos]
[group('󰲽 utility')]
[doc('Sets the current screen to HiDPI mode')]
set_screen_hidpi:
    @"$HOME/dotfiles.nix/scripts/jinx/misc/highres_display.sh"

[group('󰲽 utility')]
[doc('Generates an SSH config file from hosts inside 1Password')]
[working-directory("./")]
generate_ssh_hosts:
    @"$HOME/dotfiles.nix/scripts/jinx/misc/ssh.fish"

[group('󰲽 utility')]
[doc('Edit the system config')]
edit:
    @cd "$HOME/dotfiles.nix/"; nvim "$HOME/dotfiles.nix/"

[macos]
[group('󰲽 utility')]
[doc('Clear DNS Cache')]
[confirm]
clear_dns:
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder


[group('󰋖 help')]
[doc('Show Help')]
help command="":
    #!/usr/bin/env bash
    if [ -n "{{command}}" ]; then

        DATA=$(just --dump-format json --dump |jq '.recipes."{{command}}"')

        if [ "$DATA" == "null" ]; then
            printf "\n\033[0;31mCommand {{command}} doesn't exist!\033[0m\n"
            printf "Run \033[0;34mjinx help\033[0m to get a list of available commands"
            exit 0;
        fi

        printf "\n\033[0;32m$(echo $DATA|jq ".doc")\033[0m\n\n"
        PARAMS=$(echo $DATA | jq -r '.parameters')
        PARAMS_TEXT=""
        if [ "$PARAMS" != "null" ] && [ "$PARAMS" != "[]" ]; then
            PARAMS_TEXT=" [PARAMS]"
        fi
        printf "\033[0;33mUsage: \033[0;32mjinx $(echo $DATA|jq ".name") \033[0;36m[OPTIONS] <COMMAND>$PARAMS_TEXT\033[0m\n\n"
        if [ "$PARAMS" != "null" ] && [ "$PARAMS" != "[]" ]; then
            printf "\033[0;33mParameters:\033[0m\n"
            echo $DATA | jq -r '.parameters[] | "  \u001b[36m\(.name)\u001b[0m - \(if .default then "\u001b[32mdefault: \u001b[35m\(.default)\u001b[0m" else "\u001b[31mrequired\u001b[0m" end)"'
            printf "\n"
        fi
        printf "\033[0;33mOptions:\033[0m run \033[0;34mjust --help\033[0m to see available options\n\n"
    else
        printf "\033[0;33mUsage: \033[0;32mjinx \033[0;36m[OPTIONS] <COMMAND>\033[0m\n\n"
        printf "\033[0;33mOptions:\033[0m run \033[0;34mjust --help\033[0m to see available options\n\n"
        just --list --list-heading $'\033[0;33mCommands:\n'
    fi
