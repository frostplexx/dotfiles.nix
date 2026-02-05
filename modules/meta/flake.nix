_: {
    # Define the systems for per-system outputs
    systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
    ];

    # Make nixpkgs available per-system
    perSystem = {pkgs, ...}: {
        # Default formatter
        formatter = pkgs.alejandra;

        # Development shells
        devShells = {
            # Default shell for working on this flake
            default = pkgs.mkShell {
                name = "dotfiles";
                packages = with pkgs; [
                    # Nix tools
                    alejandra
                    deadnix
                    statix
                    nil
                    nix-tree
                    nix-diff
                    nvd

                    # General utilities
                    jq
                    yq-go
                ];
                shellHook = ''
                    echo "dotfiles.nix development shell"
                    echo "Available commands:"
                    echo "  alejandra .     - Format nix files"
                    echo "  deadnix .       - Find dead code"
                    echo "  statix check .  - Lint nix files"
                '';
            };

            # Shell for CI/validation
            ci = pkgs.mkShell {
                name = "dotfiles-ci";
                packages = with pkgs; [
                    alejandra
                    deadnix
                    statix
                    nix-tree
                ];
            };
        };

        # Checks for CI
        checks = {
            formatting = pkgs.runCommand "check-formatting" {} ''
                ${pkgs.alejandra}/bin/alejandra --check ${../.} || exit 1
                touch $out
            '';

            deadcode = pkgs.runCommand "check-deadcode" {} ''
                ${pkgs.deadnix}/bin/deadnix --fail ${../.} || exit 1
                touch $out
            '';

            linting = pkgs.runCommand "check-linting" {} ''
                ${pkgs.statix}/bin/statix check ${../.} || exit 1
                touch $out
            '';
        };
    };
}
