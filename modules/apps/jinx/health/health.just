
[group('󰓙 health')]
[doc('Format, lint and run nix flake check')]
check: lint
    @{{STATUS}} working "Running nix flake check"
    @nix flake check {{DOTFILES_FOLDER}}

[group('󰓙 health')]
[doc('Check that tools, keys and logins needed to deploy are in place')]
doctor:
    @"{{DOTFILES_FOLDER}}/modules/apps/jinx/health/doctor.fish" "{{DOTFILES_FOLDER}}"
