{
  pkgs,
  lib,
  ...
}: {
  # Shared nix settings
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';

    # Set auto optimise store and garbage collection
    optimise.automatic = true;

    settings = {
      # Optional but recommended: Keep build dependencies around for offline builds
      keep-outputs = true;
      keep-derivations = true;

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
