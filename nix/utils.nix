# Utility functions for flake configuration
{
  inputs,
  vars ? {},
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  # Common nixpkgs config
  nixpkgsConfig = {
    allowUnfree = true;
    allowUnsupportedSystem = false;
    allowBroken = true;
    alllowInsecure = true;
    # Needed for vintagestory
    permittedInsecurePackages = [
      "dotnet-runtime-wrapped-7.0.20"
      "dotnet-runtime-7.0.20"
    ];
  };

  # Helper function to get system-specific input modules
  mkInputModules = {system ? "x86_64-linux"}: import ./input-modules.nix {inherit system inputs;};

  # Base overlays that are always included
  baseOverlays = import ./overlays.nix {inherit inputs;};

  # Helper function to create a pkgs instance with overlays
  mkPkgs = {
    system,
    overlays ? [],
  }:
    import inputs.nixpkgs {
      inherit system;
      config = nixpkgsConfig;
      overlays =
        (
          if system == "aarch64-darwin"
          then baseOverlays.darwin
          else baseOverlays.nixos
        )
        ++ overlays;
    };

  # Helper function to generate home-manager configuration
  mkHomeConfig = {
    pkgs,
    modules ? [],
  }: {
    imports = map (name: ../home/programs/${name}) modules;

    # Required home-manager settings
    home = {
      stateVersion = "23.11"; # Use a stable home-manager version
      username = vars.user;
      homeDirectory =
        if pkgs.stdenv.isDarwin
        then "/Users/${vars.user}"
        else "/home/${vars.user}";
    };

    # Common home-manager settings
    programs = {
      home-manager.enable = true;
    };

    nixpkgs.config = nixpkgsConfig;
  };

  # Create a Darwin system configuration
  mkDarwinSystem = {
    modules ? [],
    system ? "aarch64-darwin",
    stateVersion ? "5",
    extraOverlays ? [],
  }: let
    inputModules = mkInputModules {inherit system;};
    pkgs = mkPkgs {
      inherit system;
      overlays = extraOverlays;
    };
  in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit inputs vars pkgs;
        # Pass the home configuration helper to modules
        mkHomeManagerConfiguration = {
          withModules = modules: mkHomeConfig {inherit pkgs modules;};
        };
      };
      modules =
        [
          inputs.home-manager.darwinModules.home-manager
          {
            system.stateVersion = stateVersion;
            nixpkgs.config = nixpkgsConfig;

            # Basic home-manager configuration
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs vars pkgs;};
              users.${vars.user} = import ../home;
              sharedModules = inputModules.home;
            };
          }
        ]
        ++ inputModules.core
        ++ inputModules.darwin
        ++ modules;
    };

  # Create a NixOS system configuration
  mkNixosSystem = {
    modules ? [],
    system ? "x86_64-linux",
    stateVersion ? "24.05",
    extraOverlays ? [],
  }: let
    inputModules = mkInputModules {inherit system;};
    pkgs = mkPkgs {
      inherit system;
      overlays = extraOverlays;
    };
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs vars pkgs;
        # Pass the home configuration helper to modules
        mkHomeManagerConfiguration = {
          withModules = modules: mkHomeConfig {inherit pkgs modules;};
        };
      };
      modules =
        [
          inputs.home-manager.nixosModules.home-manager
          {
            system.stateVersion = stateVersion;
            nixpkgs.config = nixpkgsConfig;

            # Basic home-manager configuration
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs vars pkgs;};
              users.${vars.user} = import ../home;
              sharedModules = inputModules.home;
            };
          }
        ]
        ++ inputModules.core
        ++ modules;
    };

  # Main flake generation function
  mkFlake = {
    inputs,
    systems ? ["aarch64-darwin" "x86_64-linux"],
    imports, # Allow adding new modules from inputs
    extraOverlays ? {
      # Allow adding new overlays
      darwin = [];
      nixos = [];
    },
  }: let
    # Merge input modules
    # Import and process all configuration modules
    processImports = map import;
    processedImports = processImports imports;

    # Extract configurations
    nixosConfigs =
      lib.foldl lib.recursiveUpdate {}
      (map (x: x.nixosConfigurations or {}) processedImports);
    darwinConfigs =
      lib.foldl lib.recursiveUpdate {}
      (map (x: x.darwinConfigurations or {}) processedImports);

    # Generate per-system outputs
    perSystem = system: let
      pkgs = mkPkgs {
        inherit system;
        overlays =
          if system == "aarch64-darwin"
          then extraOverlays.darwin
          else extraOverlays.nixos;
      };
    in {
      devShells = import ../templates {inherit pkgs;};
      formatter = pkgs.alejandra;
    };

    systemOutputs = inputs.flake-utils.lib.eachSystem systems perSystem;
  in
    systemOutputs
    // {
      darwinConfigurations =
        lib.mapAttrs
        (_name: config:
          mkDarwinSystem {
            inherit (config) system stateVersion;
            inherit (config) modules;
            extraOverlays = extraOverlays.darwin;
          })
        darwinConfigs;

      nixosConfigurations =
        lib.mapAttrs
        (_name: config:
          mkNixosSystem {
            inherit (config) system stateVersion;
            inherit (config) modules;
            extraOverlays = extraOverlays.nixos;
          })
        nixosConfigs;
    };
in {
  lib = {
    inherit mkFlake;
  };
}
