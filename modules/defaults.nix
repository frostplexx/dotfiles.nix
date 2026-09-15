{lib, ...}: {
  options.flake = {
    darwinModules = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
      description = "Darwin modules to be collected into the configuration";
    };

    nixOSModules = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
      description = "NixOS modules to be collected into the configuration";
    };

    homeManagerModules = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
      description = "Home Manager modules to be collected into the configuration";
    };

    defaults = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Shared default values passed to all configurations via specialArgs";
    };
  };

  config.flake.defaults = {
    user = "daniel";

    system = {
      darwinVersion = 6;
      nixosVersion = "25.11";
      timeZone = "Europe/Berlin";
      locale = "en_US.UTF-8";
    };

    settings = {
      # dotfiles-assets is git-lfs, and fetching it as a flake input
      # (`git+https://...?lfs=1`) fails against GitHub's LFS batch API in CI,
      # so this stays a fetchurl pinned to a commit instead of `refs/heads/main`.
      wallpaper = builtins.fetchurl {
        url = "https://media.githubusercontent.com/media/frostplexx/dotfiles-assets.nix/d33b30edc1abc29d41da96dcccc49c49c5afdaaf/wallpapers/wallpaper.jpg";
        sha256 = "sha256-bkT9b7BCrtyk9yXcGuqZilxlMy3ipSG34kWYaHrhCSc=";
      };

      accent_color = "cba6f7";
      transparent_terminal = true;
      # Disable window manager in CI environments
      window_manager = false;
    };

    personalInfo = {
      name = "Daniel";
      email = "62436912+frostplexx@users.noreply.github.com";
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC6vBvnnlbxJXg9lUqFD0mil+60y4BZr/UAcX1Y4scV";
    };

    paths = {
      flake = "~/dotfiles.nix";
    };
  };
}
