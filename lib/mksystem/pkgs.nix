# This module sets up the Nixpkgs package set and configuration options.
# It centralizes the configuration for package management, including
# unfree, broken, and insecure package allowances.
{
    inputs,
    system,
    overlays,
    config,
    ...
}: let
    # Configuration for Nixpkgs, controlling which packages are allowed.
    nixpkgsConfig = config.getNixpkgsConfig ++ {
        packageOverrides = pkgs: {
          electron = pkgs.electron_37; # electron is ancient, so override it with electron_37 which is the newest version
        };
  };

    # Import Nixpkgs with the above configuration and overlays.
    pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config = nixpkgsConfig;
    };
in {
    inherit pkgs nixpkgsConfig;
}
