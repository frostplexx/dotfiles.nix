
[group('󰚰 update')]
[doc('Pull merged update PRs and deploy')]
update: lint
    @{{DOTFILES_FOLDER}}/modules/apps/jinx/update/update.fish \
        --dotfiles {{DOTFILES_FOLDER}} \
        --nix-config "{{NIX_CONFIG}}" \
        --nh-cmd {{nix_cmd}}
    @if command -v pi-update-extensions >/dev/null; then pi-update-extensions; fi

[group('󰚰 update')]
[doc('Update all flake inputs locally')]
update-inputs: lint
    @nix flake update --flake {{DOTFILES_FOLDER}} --option access-tokens github.com=$(op read op://Personal/NixOS_PAT/token)

[group('󰚰 update')]
[doc('Update a single flake input')]
update-input name: lint
    @nix flake update {{name}} --flake {{DOTFILES_FOLDER}} --option access-tokens github.com=$(op read op://Personal/NixOS_PAT/token)

[group('󰚰 update')]
[doc('Show upstream commits for the last flake.lock change')]
changelog:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/update/changelog.fish" {{DOTFILES_FOLDER}}

[group('󰚰 update')]
[doc('Roll selected flake inputs back to an earlier commit')]
rollback-inputs:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/update/rollback_inputs.fish" "{{DOTFILES_FOLDER}}"

[group('󰚰 update')]
[doc('Squash-merge selected open PRs (admin override)')]
merge-updates:
    @cd {{DOTFILES_FOLDER}} && \
    {{DOTFILES_FOLDER}}/modules/apps/jinx/update/merge_updates.fish
