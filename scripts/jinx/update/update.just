
[group('nix')]
[doc('Upgrade flake inputs and deploy')]
upgrade: lint
    @echo "Deploying system configuration with update..."
    @git add .
    @NIX_CONFIG="{{NIX_CONFIG}}" nh {{nix_cmd}} switch --update
    # Add again because flake.lock gets updated
    @git add .
    @git commit -m "chore: update inputs"


[group('nix')]
[doc('Update every fetchFromGithub with its newest commit and hash')]
update-refs:
    @echo -e "Updating refs..."
    @"$HOME/dotfiles.nix/scripts/jinx/update/update-flake-revs.sh" $HOME/dotfiles.nix
