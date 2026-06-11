
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

[group('󰒔 maintain')]
[doc('Delete nix fetcher/eval caches for user and root (fixes "object not found - no match for id")')]
clean-cache:
    @echo "Deleting nix caches for $(whoami)..."
    @rm -rf "$HOME"/.cache/nix/tarball-cache "$HOME"/.cache/nix/gitv3 "$HOME"/.cache/nix/fetcher-cache-v*.sqlite* "$HOME"/.cache/nix/eval-cache-v*
    @echo "Deleting nix caches for root..."
    @sudo -H sh -c 'rm -rf "$HOME"/.cache/nix/tarball-cache "$HOME"/.cache/nix/gitv3 "$HOME"/.cache/nix/fetcher-cache-v*.sqlite* "$HOME"/.cache/nix/eval-cache-v*'
    @echo "Done. Nix will re-download flake inputs on next use."

