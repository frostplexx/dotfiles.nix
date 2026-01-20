# This module sets up the Nixpkgs package set and configuration options.
# It centralizes the configuration for package management, including
# unfree, broken, and insecure package allowances.
{
    inputs,
    system,
    overlays,
    ...
}: let
    # Configuration for Nixpkgs, controlling which packages are allowed.
    nixpkgsConfig = {
        allowUnfree = true; # Allow unfree packages (e.g., proprietary software)
        allowUnsupportedSystem = false; # Disallow unsupported systems
        allowBroken = true; # Allow broken packages (use with caution)
        allowInsecure = true; # Allow insecure packages (use with caution)
        doCheckByDefault = false;
        packageOverrides = pkgs: {
            electron = pkgs.electron_38; # electron is ancient, so override it with electron_37 which is the newest version
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
