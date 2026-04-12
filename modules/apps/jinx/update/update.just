
[group('󱄅 nix')]
[doc('Update flake inputs and deploy')]
update: lint
    @{{DOTFILES_FOLDER}}/modules/apps/jinx/update/update.fish \
        --dotfiles {{DOTFILES_FOLDER}} \
        --nix-config "{{NIX_CONFIG}}" \
        --nh-cmd {{nix_cmd}}


[group('󱄅 nix')]
[doc('Update every fetchFromGithub with its newest commit and hash')]
update-refs:
    @echo -e "Updating refs..."
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/update/update-flake-revs.fish" {{DOTFILES_FOLDER}}


[group('󱄅 nix')]
[doc('Update flake inputs')]
update-inputs: lint
    @nix flake update --option access-tokens github.com=$(op read op://Personal/GitHub/token)

[group('󱄅 nix')]
[doc('list the changes from the updated inputs')]
changelog:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/update/changelog.fish" {{DOTFILES_FOLDER}}
