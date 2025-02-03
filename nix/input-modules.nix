{inputs, ...}: let
  # Helper function to get system-specific input modules
  mkInputModules = {
    core = [
    ];

    home = [
      inputs.nixcord.homeManagerModules.nixcord
      inputs.spicetify-nix.homeManagerModules.default
      inputs.niri.homeModules.niri
    ];

    darwin = [
    ];
  };
in
  mkInputModules
