# This module sets up the Nixpkgs package set and configuration options.
# It centralizes the configuration for package management, including
# unfree, broken, and insecure package allowances.
{
    inputs,
    system,
    overlays,
    nixpkgsConfig,
    ...
}: let
    # Import Nixpkgs with the above configuration and overlays.
    pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config = nixpkgsConfig;
    };
in {
    inherit pkgs nixpkgsConfig;
}
