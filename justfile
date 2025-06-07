#!/usr/bin/env just --justfile

alias d := deploy
alias u := upgrade

# macOS need nh darwin switch and NixOS needs nh os switch
nix_cmd := `if [ "$(uname)" = "Darwin" ]; then echo "darwin"; else echo "os"; fi`

# Set default recipe
default:
    @just --list --list-prefix "    " --list-heading $'🔧 Available Commands:\n'

[group('nix')]
[doc('Deploy system configuration')]
deploy host="$(hostname)": lint
    @echo "Deploying system configuration without update..."
    @git add .
    @export NH_NO_CHECKS; nh {{nix_cmd}} switch -H {{host}}

[group('nix')]
[doc('Upgrade flake inputs and deploy')]
upgrade: update-refs lint
    @echo "Deploying system configuration with update..."
    @git add .
    @export NH_NO_CHECKS; nh {{nix_cmd}} switch --update
    # Add again because flake.lock gets updated
    @git add .
    @git commit -m "chore: update inputs"


[group('nix')]
[doc('Update every fetchFromGithub with its newest commit and hash')]
update-refs:
    @echo -e "Updating refs..."
    @./scripts/update-flake-revs.sh

[group('maintain')]
[doc('Clean and optimise the nix store with nh')]
clean:
    @export NH_NO_CHECKS
    @nh clean all -k 5

[group('maintain')]
[doc('Optimise the nix store')]
optimise:
    @nix store optimise -v

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
