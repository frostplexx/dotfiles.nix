
[group('󱄅 system')]
[doc('Build and switch to the system configuration (-v for verbose)')]
[positional-arguments]
deploy host="$(hostname)": lint
    @cd {{DOTFILES_FOLDER}}; git add .
    @mkdir -p "$HOME/.config/sops/age"
    @if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then \
        if [ "$(uname)" = "Darwin" ] && security find-generic-password -a "$USER" -s "sops-age-key" -w 2>/dev/null; then \
            security find-generic-password -a "$USER" -s "sops-age-key" -w > "$HOME/.config/sops/age/keys.txt"; \
            chmod 600 "$HOME/.config/sops/age/keys.txt"; \
            echo "→ Imported age key from Login Keychain"; \
        else \
            echo "⚠  sops age key missing at ~/.config/sops/age/keys.txt"; \
            if [ "$(uname)" = "Darwin" ]; then \
                echo "   Seed it once: security add-generic-password -a \"$USER\" -s \"sops-age-key\" -w < keys.txt"; \
            else \
                echo "   Copy it from another machine: scp <host>:.config/sops/age/keys.txt ~/.config/sops/age/"; \
            fi; \
            exit 1; \
        fi; \
    fi
    @if [[ $1 == *"--verbose"* || $1 == *"-v"* ]]; then \
        if [[ "$(uname)" == "Darwin" ]]; then \
            echo "Running nix-darwin rebuild switch with verbose output..."; \
            sudo darwin-rebuild switch --flake {{DOTFILES_FOLDER}} --verbose --show-trace; \
        else \
            echo "Running nixos-rebuild switch with verbose output..."; \
            sudo nixos-rebuild switch --flake {{DOTFILES_FOLDER}} --verbose --show-trace; \
        fi; \
    else \
        nh {{nix_cmd}} switch -H {{host}} {{DOTFILES_FOLDER}}; \
    fi



[group('󱄅 system')]
[doc('Build the configuration and show the package diff, without switching')]
build host="$(hostname)":
    @cd {{DOTFILES_FOLDER}} && git add --intent-to-add .
    @nh {{nix_cmd}} build --diff always -H {{host}} {{DOTFILES_FOLDER}}

[group('󱄅 system')]
[doc('Build on and deploy to a remote NixOS host over SSH')]
deploy-remote host="tiramisu" target="Gaming_PC": lint
    @cd {{DOTFILES_FOLDER}} && git add --intent-to-add .
    @# Build on the target itself: the Mac can't build x86_64-linux locally.
    @nh os switch -H {{host}} --target-host {{target}} --build-host {{target}} {{DOTFILES_FOLDER}}

[group('󱄅 system')]
[doc('Switch back to the previous system generation')]
[confirm('Switch back to the previous system generation?')]
rollback:
    @if [ "$(uname)" = "Darwin" ]; then \
        sudo darwin-rebuild switch --rollback; \
    else \
        sudo nixos-rebuild switch --rollback; \
    fi

[group('󱄅 system')]
[doc('List system generations (* = current)')]
generations:
    #!/usr/bin/env fish
    set -l profiles /nix/var/nix/profiles
    set -l current (readlink $profiles/system)
    for link in (ls $profiles | string match -r '^system-\d+-link$' | sort -t- -k2 -n)
        set -l date
        set -l gen (string replace -r '^system-(\d+)-link$' '$1' $link)
        # stat the symlink itself (store paths all have mtime 1970). BSD and
        # GNU stat disagree on flags, and GNU's -f doesn't fail, it means --file-system.
        if test (uname) = Darwin
            set date (stat -f '%Sm' -t '%F %R' $profiles/$link)
        else
            set date (stat -c '%y' $profiles/$link | string sub -l 16)
        end
        set -l mark ' '
        test "$link" = "$current"; and set mark '*'
        printf '%s %4s  %s  %s\n' $mark $gen $date (path basename (readlink $profiles/$link))
    end

[group('󱄅 system')]
[doc('Search nixpkgs; Enter copies the selected attribute names')]
search package:
    #!/usr/bin/env fish
    set -l copy pbcopy
    command -q pbcopy; or set copy wl-copy
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

[group('󱄅 system')]
[doc('Edit a sops-encrypted file in the repo')]
edit-secret:
    #!/usr/bin/env fish
    cd {{DOTFILES_FOLDER}}
    set -l file (git grep -l -E '"sops": \{|^sops:' | fzf --prompt "secret > " --height 40% --border)
    test -n "$file"; or exit 0
    SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt sops $file

[group('󱄅 system')]
[doc('Generate ~/.ssh/hosts from the SSH items in 1Password')]
[working-directory("./")]
generate-ssh-hosts:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/misc/ssh.fish"

[group('󱄅 system')]
[doc('Wake a machine through UpSnap (Wake-on-LAN)')]
[macos]
wake:
    #!/usr/bin/env fish
    wololo

[group('󱄅 system')]
[doc('Show OS, nix and dotfiles info')]
info:
    @echo -e "\033[0;33mOS:\033[0m $(uname -s) $(uname -r) ($(uname -m))"
    @echo -e -n "\033[0;33mNix Version:\033[0m $(nix --version)\n"
    @echo -e "\033[0;33mSystem:\033[0m $(darwin-version 2>/dev/null || nixos-version)"
    @echo -e "\033[0;33mDotfiles:\033[0m $(echo {{DOTFILES_FOLDER}})"
