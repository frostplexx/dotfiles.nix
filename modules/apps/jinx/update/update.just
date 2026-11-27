
[group('󰚰 update')]
[doc('Pull merged update PRs and deploy')]
update: lint
    @{{DOTFILES_FOLDER}}/modules/apps/jinx/update/update.fish \
        --dotfiles {{DOTFILES_FOLDER}} \
        --nix-config "{{NIX_CONFIG}}" \
        --nh-cmd {{nix_cmd}}
    @if command -v pi-update-extensions >/dev/null; then pi-update-extensions; fi

[group('󰚰 update')]
[doc('Update all pins')]
update-inputs: lint
    @{{STATUS}} working "Updating all pins"
    @cd {{DOTFILES_FOLDER}} && GH_TOKEN=$(op read op://Personal/NixOS_PAT/token) tack update

[group('󰚰 update')]
[doc('Update a single pin')]
update-input name: lint
    @{{STATUS}} working "Updating pin {{name}}"
    @cd {{DOTFILES_FOLDER}} && GH_TOKEN=$(op read op://Personal/NixOS_PAT/token) tack update {{name}}

[group('󰚰 update')]
[doc('Show upstream commits for the last pins.lock.json change')]
changelog:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/update/changelog.fish" {{DOTFILES_FOLDER}}

[group('󰚰 update')]
[doc('Roll selected pins back to an earlier commit')]
rollback-inputs:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/update/rollback_inputs.fish" "{{DOTFILES_FOLDER}}"

[group('󰚰 update')]
[doc('Squash-merge selected open PRs (admin override)')]
merge-updates:
    @cd {{DOTFILES_FOLDER}} && \
    {{DOTFILES_FOLDER}}/modules/apps/jinx/update/merge_updates.fish
