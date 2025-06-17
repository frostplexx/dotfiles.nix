{
    pkgs,
    lib,
    inputs,
    ...
}: {
    environment.etc."nix/nix.custom.conf".text = ''
        experimental-features = nix-command flakes
        lazy-trees = true
        warn-dirty = false
        extra-substituters = "https://cache.nixos.org" "https://install.determinate.systems" "https://nix-community.cachix.org"
        extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    '';

    # Determinate uses its own daemon to manage the Nix installation that
    # conflicts with nix-darwin’s native Nix management.
    nix = {
        enable =
            if pkgs.stdenv.isDarwin
            then false
            else true;
        # Disable channels
        channel.enable = false;
        extraOptions = ''
            experimental-features = nix-command flakes
            warn-dirty = false
        '';

        # Make flake registry and nix path match flake inputs
        nixPath = ["nixpkgs=${inputs.nixpkgs}"];

        settings = {
            extra-platforms = ["aarch64-darwin"];
            extra-trusted-users = ["daniel"];
            max-jobs = 8;
            sandbox = true;

            # given the users in this list the right to specify additional substituters via:
            #    1. `nixConfig.substituters` in `flake.nix`
            #    2. command line args `--options substituters http://xxx`
            substituters = [
                "https://cache.nixos.org"
                "https://install.determinate.systems"
                # nix community's cache server
                "https://nix-community.cachix.org"
            ];

            trusted-public-keys = [
                # nix community's cache server public key
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
            ];
        };
    };

    documentation =
        {
            enable = true;
            man =
                {
                    enable = true;
                }
                // lib.optionalAttrs pkgs.stdenv.isLinux {
                    generateCaches = true;
                };
        }
        // lib.optionalAttrs pkgs.stdenv.isLinux {
            dev.enable = true;
        };
}
