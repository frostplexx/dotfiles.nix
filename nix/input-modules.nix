{inputs, ...}: let
  # Helper function to get system-specific input modules
  mkInputModules = {
    core = [
      inputs.lix-module.nixosModules.default
    ];

    home = [
      inputs.nixcord.homeManagerModules.nixcord
      inputs.plasma-manager.homeManagerModules.plasma-manager
    ];

    darwin = [
    ];
  };
in
  mkInputModules
