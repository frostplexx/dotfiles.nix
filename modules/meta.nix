_: {
  # Define the systems for per-system outputs
  systems = [
    "x86_64-linux"
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
        shellHook =
          /*
          bash
          */
          ''
            # if session is not called "dotfiles.nix", rename it to that
            if [ $(rex session inspect |grep label) != "label: dotfiles.nix" ]; then
              echo "Renaming session to dotfiles.nix"
              rex session rename dotfiles.nix
            fi
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

    # Checks for CI. deadcode/linting are deliberately not here — the
    # standalone "Statix Lint" CI job already runs deadnix/statix once on
    # Linux; duplicating them as flake checks would just rebuild the same
    # result on every system in the check matrix.
    checks = {
      formatting = pkgs.runCommand "check-formatting" {} ''
        ${pkgs.alejandra}/bin/alejandra --check ${../.} || exit 1
        touch $out
      '';
    };
  };
}
