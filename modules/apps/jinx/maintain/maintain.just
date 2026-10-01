
[group('󰒔 store')]
[doc('Delete old generations (keeps 5) and garbage-collect')]
clean:
    @nh clean all -k 5

[group('󰒔 store')]
[doc('Deduplicate the nix store')]
optimise:
    @nix store optimise -v

[group('󰒔 store')]
[doc('Verify and repair the nix store')]
repair:
    @sudo nix-store --verify --check-contents --repair

[group('󰒔 store')]
[doc('Delete nix fetcher and eval caches (fixes "object not found")')]
clean-cache:
    @echo "Deleting nix caches for $(whoami)..."
    @rm -rf "$HOME"/.cache/nix/tarball-cache "$HOME"/.cache/nix/gitv3 "$HOME"/.cache/nix/fetcher-cache-v*.sqlite* "$HOME"/.cache/nix/eval-cache-v*
    @echo "Deleting nix caches for root..."
    @sudo -H sh -c 'rm -rf "$HOME"/.cache/nix/tarball-cache "$HOME"/.cache/nix/gitv3 "$HOME"/.cache/nix/fetcher-cache-v*.sqlite* "$HOME"/.cache/nix/eval-cache-v*'
    @echo "Done. Nix will re-download flake inputs on next use."

