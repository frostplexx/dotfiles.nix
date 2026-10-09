
[group('󰀵 macos')]
[doc('Install TidaLuna into TIDAL')]
[macos]
install-tidaluna:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/misc/tidaluna.sh"

[group('󰀵 macos')]
[doc('Exclude node_modules under ~ from Time Machine')]
[macos]
exclude-node-modules:
    @find $HOME -type d -maxdepth 3 -name 'node_modules' | xargs -n 1 sudo tmutil addexclusion -p

[group('󰀵 macos')]
[doc('Set the external display to HiDPI mode')]
[macos]
set-hidpi:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/misc/highres_display.fish"

[group('󰀵 macos')]
[doc('Flush the DNS cache')]
[macos]
[confirm]
flush-dns:
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder

[group('󰋖 help')]
[doc('Show help for jinx or one command')]
help command="":
    #!/usr/bin/env bash
    if [ -n "{{command}}" ]; then

        DATA=$(just --dump-format json --dump |jq '.recipes."{{command}}"')

        if [ "$DATA" == "null" ]; then
            printf "\n\033[0;31mCommand {{command}} doesn't exist!\033[0m\n"
            printf "Run \033[0;34mjinx help\033[0m to get a list of available commands"
            exit 0;
        fi

        printf "\n\033[0;32m$(echo $DATA|jq -r ".doc")\033[0m\n\n"
        PARAMS=$(echo $DATA | jq -r '.parameters')
        PARAMS_TEXT=""
        if [ "$PARAMS" != "null" ] && [ "$PARAMS" != "[]" ]; then
            PARAMS_TEXT=" [PARAMS]"
        fi
        printf "\033[0;33mUsage: \033[0;32mjinx $(echo $DATA|jq -r ".name") \033[0;36m[OPTIONS] <COMMAND>$PARAMS_TEXT\033[0m\n\n"
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
