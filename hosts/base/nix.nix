{
  pkgs,
  vars,
  ...
}: {
  # Shared nix settings
  nix = {
    package = pkgs.nixVersions.git;
    extraOptions = ''
      experimental-features = nix-command flakes
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
      trusted-users = ["root" vars.user];

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

  # Allow non-free apps
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };

  documentation = {
    enable = true;
    man = {
      enable = true;
    };
    # dev.enable = true;
  };
  # man.generateCaches = true;
}
