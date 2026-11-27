_: {
  # Define the systems for per-system outputs
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  # Make nixpkgs available per-system
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    # `nix run .#tack` gives CI the exact pinned tack build.
    packages.tack = inputs'.tack.packages.tack;

    # Default formatter. tack writes .tack/default.nix with nixfmt, so run the
    # same tool there. Any other formatter would rewrite it and make tack call
    # the resolver out of date.
    formatter = pkgs.writeShellApplication {
      name = "fmt";
      runtimeInputs = [pkgs.alejandra pkgs.nixfmt pkgs.findutils];
      text = ''
        case "''${1:-}" in
          "" | .)
            find . -name '*.nix' -not -path './.tack/*' -exec alejandra {} +
            find .tack -name '*.nix' -exec nixfmt {} +
            ;;
          *) exec alejandra "$@" ;;
        esac
      '';
    };

    # Development shells
    devShells = {
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
      # .tack/default.nix is tack-managed: nixfmt there, alejandra everywhere else.
      formatting = pkgs.runCommand "check-formatting" {} ''
        ${pkgs.findutils}/bin/find ${../.} -name '*.nix' -not -path '*/.tack/*' -print0 \
          | ${pkgs.findutils}/bin/xargs -0 ${pkgs.alejandra}/bin/alejandra --check
        ${pkgs.findutils}/bin/find ${../.}/.tack -name '*.nix' -print0 \
          | ${pkgs.findutils}/bin/xargs -0 ${pkgs.nixfmt}/bin/nixfmt --check
        touch $out
      '';
    };
  };
}
