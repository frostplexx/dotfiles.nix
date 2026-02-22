
[group('󰒔 maintain')]
[doc('Clean and optimize the nix store with nh')]
clean:
    @nh clean all -k 5
    @nix-collect-garbage -d
    @nix store gc

[group('󰒔 maintain')]
[doc('Optimize the nix store')]
optimize:
    @nix store optimise -v

[group('󰒔 maintain')]
[doc('Verify and repair the nix-store')]
repair:
    @sudo nix-store --verify --check-contents --repair

