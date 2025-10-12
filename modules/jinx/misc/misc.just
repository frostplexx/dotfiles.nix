
[macos]
[group('󰲽 utility')]
[doc('Restarts yabai, skhd and lazykeys')]
restart_wm:
    @sudo yabai --load-sa 
    @sudo pkill -9 lazykeys 
    @sudo pkill -9 skhd

[macos]
[group('󰲽 utility')]
[doc('Sets the current screen to HiDPI mode')]
set_screen_hidpi:
    @"{{DOTFILES_FOLDER}}/modules/jinx/misc/highres_display.sh"

[group('󰲽 utility')]
[doc('Generates an SSH config file from hosts inside 1Password')]
[working-directory("./")]
generate_ssh_hosts:
    @"{{DOTFILES_FOLDER}}/modules/jinx/misc/ssh.fish"

[group('󰲽 utility')]
[doc('Edit the system config')]
edit:
    @cd "{{DOTFILES_FOLDER}}"; nvim "{{DOTFILES_FOLDER}}"


[group('󰲽 utility')]
[doc('Search for nix packages')]
search package:
    #!/usr/bin/env bash
    # nh search produces a broken pipe error which we ignore
    DATA=$(nh search "{{package}}" --json 2>/dev/null)
    ELAPSED=$(echo $DATA |jq ".elapsed_ms")
    QUERY=$(echo $DATA |jq ".query")
    echo "$DATA" | jq -c '.results[] | "\(.package_attr_name)\t\(tojson)"' -r | \
      fzf \
      --with-nth=1 \
      --multi \
      --style minimal \
      --layout=reverse  \
      --delimiter='\t' \
      --prompt=" $QUERY took $(echo $ELAPSED)ms: " \
      --preview='
        echo {2} | jq -r -C "
          . as \$pkg |
          \"\u001b[0;34m \(.package_pname) \u001b[0;0m(\u001b[0;32m\(.package_pversion)\u001b[0;0m)\n\n\(.package_description)\n\n\u001b[0;33m󰖟 Homepage:\u001b[0;0m \(.package_homepage[0])\n\u001b[0;33m󱄅 Defined at:\u001b[0;0m \(.package_position)\u001b[0;33m\n Supported Platforms:\u001b[0;0m\n  \" +
          (\$pkg.package_platforms
            | map(select(. == \"aarch64-linux\" or . == \"x86_64-linux\" or . == \"aarch64-darwin\" or . == \"x86_64-darwin\"))
            | join(\", \"))
        "
      ' \
      --preview-window=wrap \
      --bind 'enter:execute-silent(echo {+1} | tr " " "\n" | pbcopy)+abort' \
      --ansi \
      --preview-window=wrap \


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
