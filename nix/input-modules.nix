{
  system,
  inputs,
}: let
  # Helper function to get system-specific input modules
  mkInputModules = {
    core = [
      inputs
      .stylix
      .${
        if system == "aarch64-darwin"
        then "darwinModules"
        else "nixosModules"
      }
      .stylix
    ];

    home = [
      inputs.plasma-manager.homeManagerModules.plasma-manager
      inputs.anyrun.homeManagerModules.default
      inputs.nixcord.homeManagerModules.nixcord
      inputs.spicetify-nix.homeManagerModules.default
      {
        # explicitly disable stylix for spicetify because its managed by spicetify-nix
        stylix.targets.spicetify.enable = false;
      }
    ];

    darwin = [
    ];
  };
in
  mkInputModules
