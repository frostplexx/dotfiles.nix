#!/usr/bin/env just --justfile
# deploy.just - Deploy system configuration using just

alias d := deploy
alias u := upgrade

# Define variables
nix_cmd := `if [ "$(uname)" = "Darwin" ]; then echo "darwin"; else echo "os"; fi`

# Set default recipe
default:
    @just --list --list-prefix "    " --list-heading $'🔧 Available Commands:\n'

[group('nix')]
[doc('Deploy system configuration')]
deploy host="$(hostname)": lint
    @echo "Deploying system configuration without update..."
    @nix run github:viperml/nh -- {{nix_cmd}} switch -H {{host}}

[group('nix')]
[doc('Upgrade flake inputs and deploy')]
upgrade: update-refs lint
    @echo "Deploying system configuration with update..."
    @nix run github:viperml/nh -- {{nix_cmd}} switch --update

[group('nix')]
[doc('Update every fetchFromGithub with its newest commit and hash')]
update-refs:
    @./scripts/update-flake-revs.sh

[group('maintain')]
[doc('Clean the nix store with nh')]
clean:
    @nix run github:viperml/nh -- clean all

[group('maintain')]
[doc('Verify and repair the nix-store')]
repair:
    @sudo nix-store --verify --check-contents --repair

[group('lint')]
[doc('Lint all nix files using statix and deadnix')]
lint: format
    @nix run nixpkgs#statix -- check .
    @nix run nixpkgs#deadnix -- -eq .

[group('lint')]
[doc('Format files using alejandra')]
format:
    @nix fmt . 2> /dev/null

[group('lint')]
[doc('Show diff between current and commited changes')]
diff:
    git diff ':!flake.lock'
