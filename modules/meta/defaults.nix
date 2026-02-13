{lib, ...}: {
  options.flake.defaults = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = {};
    description = "Shared default values passed to all configurations via specialArgs";
  };

  config.flake.defaults = {
    user = "daniel";

    system = {
      darwinVersion = 6;
      nixosVersion = "25.11";
      timeZone = "Europe/Berlin";
      locale = "en_US.UTF-8";
    };

    personalInfo = {
      name = "Daniel";
      email = "62436912+frostplexx@users.noreply.github.com";
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC6vBvnnlbxJXg9lUqFD0mil+60y4BZr/UAcX1Y4scV";
    };

    paths = {
      flake = "dotfiles.nix";
    };
  };
}
