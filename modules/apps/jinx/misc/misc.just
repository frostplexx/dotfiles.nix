
[group('󰀵 macos')]
[doc('Install TidaLuna into TIDAL')]
[macos]
install-tidaluna:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/misc/tidaluna.sh"

[group('󰀵 macos')]
[doc('Exclude node_modules under ~ from Time Machine')]
[macos]
exclude-node-modules:
    @if ! sudo -n true 2>/dev/null; then \
        {{STATUS}} blocked auth "sudo password required"; \
        sudo -v; \
    fi
    @{{STATUS}} working "Excluding node_modules from Time Machine"
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
    @if ! sudo -n true 2>/dev/null; then \
        {{STATUS}} blocked auth "sudo password required"; \
        sudo -v; \
    fi
    @{{STATUS}} working "Flushing DNS cache"
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder

[group('󱄅 system')]
[doc('Search nixpkgs; Enter copies the selected attribute names')]
search package:
    #!/usr/bin/env fish
    set -l copy pbcopy
    command -q pbcopy; or set copy wl-copy
    {{STATUS}} blocked question "Select packages"
    fzf \
        --phony \
        --multi \
        --query="{{package}}" \
        --style minimal \
        --layout=reverse \
        --delimiter='\t' \
        --prompt=" nix search: " \
        --bind 'start,change:reload:
          if test -n {q}
            set DATA (nh search {q} --json 2>/dev/null)
            echo $DATA | jq -c \'.results[] | "\(.package_attr_name)\t\(tojson)"\' -r 2>/dev/null
          end
        ' \
        --with-nth=1 \
        --preview='
          echo {2} | jq -r -C "
            . as \$pkg |
            \"\u001b[0;34m \(.package_pname) \u001b[0;0m(\u001b[0;32m\(.package_pversion)\u001b[0;0m)\n\n\(.package_description)\n\n\u001b[0;33m󰖟 Homepage:\u001b[0;0m \(.package_homepage[0])\n\u001b[0;33m󱄅 Defined at:\u001b[0;0m \(.package_position)\u001b[0;33m\n Supported Platforms:\u001b[0;0m\n  \" +
            (\$pkg.package_platforms
              | map(select(. == \"aarch64-linux\" or . == \"x86_64-linux\" or . == \"aarch64-darwin\" or . == \"x86_64-darwin\"))
              | join(\", \"))
          "
        ' \
        --preview-window=wrap \
        --bind "enter:execute-silent(echo {+1} | tr ' ' '\n' | $copy)+abort" \
        --ansi \
        < /dev/null
