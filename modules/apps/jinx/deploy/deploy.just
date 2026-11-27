
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
    @if ! sudo -n true 2>/dev/null; then \
        {{STATUS}} blocked auth "sudo password required"; \
        sudo -v; \
    fi
    @{{STATUS}} working "Switching system configuration"
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
[doc('Switch back to the previous system generation')]
[confirm('Switch back to the previous system generation?')]
rollback:
    @if ! sudo -n true 2>/dev/null; then \
        {{STATUS}} blocked auth "sudo password required"; \
        sudo -v; \
    fi
    @{{STATUS}} working "Switching to previous generation"
    @if [ "$(uname)" = "Darwin" ]; then \
        sudo darwin-rebuild switch --rollback; \
    else \
        sudo nixos-rebuild switch --rollback; \
    fi


[group('󱄅 system')]
[doc('Generate ~/.ssh/hosts from the SSH items in 1Password')]
[working-directory("./")]
generate-ssh-hosts:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/misc/ssh.fish"

[group('󱄅 system')]
[doc('Show OS, nix and dotfiles info')]
info:
    @echo -e "\033[0;33mOS:\033[0m $(uname -s) $(uname -r) ($(uname -m))"
    @echo -e -n "\033[0;33mNix Version:\033[0m $(nix --version)\n"
    @echo -e "\033[0;33mSystem:\033[0m $(darwin-version 2>/dev/null || nixos-version)"
    @echo -e "\033[0;33mDotfiles:\033[0m $(echo {{DOTFILES_FOLDER}})"
