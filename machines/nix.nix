{
    pkgs,
    lib,
    inputs,
    ...
}: {
    # Shared nix settings
    nix = {
        # Determinate uses its own daemon to manage the Nix installation that
        # conflicts with nix-darwin’s native Nix management.
        enable = false;
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
                # nix community's cache server
                "https://nix-community.cachix.org"
            ];

            trusted-public-keys = [
                # nix community's cache server public key
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
