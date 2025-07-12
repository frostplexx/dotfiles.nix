# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ inputs, nixpkgs, overlays, ... } @ args: name: {
  system,
  user,
  hm-modules ? [],
}:
let
  # Load the Nixpkgs package set and configuration.
  pkgsConfig = import ./pkgs.nix { inherit inputs system overlays; };
  inherit (pkgsConfig) pkgs;
  inherit (pkgsConfig) nixpkgsConfig;

  # Fetch remote assets (e.g., wallpapers).
  assets = import ./assets.nix { inherit pkgs; };

  # Machine config path
  machineConfig = ../../machines/${name};

  # Merge all relevant arguments for the machine config.
  machineConfigArgs = { inherit system user pkgs inputs assets; } // args;

  # Function to build the Home Manager configuration for a user.
  mkHomeConfig = args: import ./home-config.nix args;

  # Assemble the full list of system modules.
  modules = import ./modules.nix {
    inherit inputs pkgs nixpkgsConfig system user name machineConfig machineConfigArgs hm-modules assets mkHomeConfig;
  };

  # Determine if we are building for Darwin (macOS).
  inherit (inheritpkgs.stdenv) isDarwin;
  # Select the correct system builder function for the OS.
  systemFunc =
    if isDarwin
    then inputs.darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
in
# Call the system builder function with the assembled modules and configuration.
systemFunc {
  inherit system;
  inherit (inputs.nixpkgs) lib;
  inherit modules;
}
