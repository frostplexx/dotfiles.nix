
[group('maintain')]
[doc('Clean and optimise the nix store with nh')]
clean:
    @nh clean all -k 5

[group('maintain')]
[doc('Optimise the nix store')]
optimise:
    @nix store optimise -v

[group('maintain')]
[doc('Verify and repair the nix-store')]
repair:
    @sudo nix-store --verify --check-contents --repair

