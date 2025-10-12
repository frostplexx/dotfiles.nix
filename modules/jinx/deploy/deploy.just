
[group('󱄅 nix')]
[doc('Deploy system configuration')]
[positional-arguments]
deploy host="$(hostname)": lint
    @cd {{DOTFILES_FOLDER}}; git add .
    @if [[ $1 == *"--verbose"* || $1 == *"-v"* ]]; then \
        if [[ "$(uname)" == "Darwin" ]]; then \
            echo "Running nix-darwin rebuild switch with verbose output..."; \
            sudo darwin-rebuild switch --flake . --verbose --show-trace; \
        else \
            echo "Running nixos-rebuild switch with verbose output..."; \
            nixos-rebuild switch --flake . --verbose --show-trace; \
        fi; \
    else \
        nh {{nix_cmd}} switch -H {{host}} {{DOTFILES_FOLDER}}; \
    fi
    @jinx r



[group('󱄅 nix')]
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
