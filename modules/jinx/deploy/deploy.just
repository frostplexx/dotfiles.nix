
[group('󱄅 nix')]
[doc('Deploy system configuration')]
[positional-arguments]
deploy host="$(hostname)": lint
    @git add .
    @if [[ $1 == *"--verbose"* || $1 == *"-v"* ]]; then \
        if [[ "$(uname)" == "Darwin" ]]; then \
            echo "Running nix-darwin rebuild switch with verbose output..."; \
            sudo darwin-rebuild switch --flake . --verbose --show-trace; \
        else \
            echo "Running nixos-rebuild switch with verbose output..."; \
            nixos-rebuild switch --flake . --verbose --show-trace; \
        fi; \
    else \
        nh {{nix_cmd}} switch -H {{host}}; \
    fi
