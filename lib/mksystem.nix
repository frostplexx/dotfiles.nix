# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ inputs, nixpkgs, overlays, ... } @ args: name: {
  system,
  user,
  hm-modules ? [],
}:
let
  # Load pkgs and config
  pkgsConfig = import ./mksystem/pkgs.nix { inherit inputs system overlays; };
  pkgs = pkgsConfig.pkgs;
  nixpkgsConfig = pkgsConfig.nixpkgsConfig;

  # Fetch assets
  assets = import ./mksystem/assets.nix { inherit pkgs; };

  # Machine config path
  machineConfig = ../machines/${name};

  # Merge args for machine config
  machineConfigArgs = { inherit system user pkgs inputs assets; } // args;

  # Home config builder
  mkHomeConfig = args: import ./mksystem/home-config.nix args;

  # Modules list
  modules = import ./mksystem/modules.nix {
    inherit inputs pkgs nixpkgsConfig system user name machineConfig machineConfigArgs hm-modules assets mkHomeConfig;
  };

  # System function
  isDarwin = pkgs.stdenv.isDarwin;
  systemFunc =
    if isDarwin
    then inputs.darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
in
systemFunc rec {
  inherit system;
  inherit (inputs.nixpkgs) lib;
  inherit modules;
}
