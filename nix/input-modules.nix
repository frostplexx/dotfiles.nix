{ system, inputs }: let
  inherit (inputs.nixpkgs) lib;

  # Helper function to get system-specific input modules
  mkInputModules = {
    core = [
      inputs.yuki.nixosModules.default
      inputs.stylix.${if system == "aarch64-darwin" then "darwinModules" else "nixosModules"}.stylix
    ];

    home = [
      inputs.plasma-manager.homeManagerModules.plasma-manager
      inputs.nixcord.homeManagerModules.nixcord
      inputs.spicetify-nix.homeManagerModules.default
      {
        # explicitly disable stylix for spicetify because its managed by spicetify-nix
        stylix.targets.spicetify.enable = false;
      }
    ];

    darwin = [
      inputs.darwin-custom-icons.darwinModules.default
    ];
  };
in
  mkInputModules
