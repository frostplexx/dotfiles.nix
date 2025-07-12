
[group('󱄅 nix')]
[doc('Upgrade flake inputs and deploy')]
upgrade: lint
    @echo "Deploying system configuration with update..."
    @NIX_CONFIG="{{NIX_CONFIG}}" nh {{nix_cmd}} switch --update


[group('󱄅 nix')]
[doc('Update every fetchFromGithub with its newest commit and hash')]
update-refs:
    @echo -e "Updating refs..."
    @"$HOME/dotfiles.nix/scripts/jinx/update/update-flake-revs.sh" $HOME/dotfiles.nix
