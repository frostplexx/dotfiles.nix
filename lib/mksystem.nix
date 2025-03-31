# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  inputs,
  nixpkgs,
  overlays,
  ...
}: name: {
  system,
  user,
  hm-modules,
}: let
  darwin = pkgs.stdenv.isDarwin;

  # The config files for this system.
  machineConfig = ../machines/${name};

  nixpkgsConfig = {
    allowUnfree = true;
    allowUnsupportedSystem = false;
    allowBroken = true;
    alllowInsecure = true;
  };

  # TODO: port this to my system
  # userOSConfig = ../users/${user}/${if darwin then "darwin" else "nixos" }.nix;
  # userHMConfig = ../users/${user}/home-manager.nix;

  # NixOS vs nix-darwin functions
  systemFunc =
    if darwin
    then inputs.darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;
  pkgs = nixpkgs.legacyPackages.${system};

  # Build the home configuration from the modules
  mkHomeConfig = {
    pkgs,
    modules ? [],
  }: {
    imports = map (name: ../home/${name}) modules;
    nixpkgs.config = nixpkgsConfig;
  };
in
  systemFunc rec {
    inherit system;

    specialArgs = {
      inherit inputs pkgs;
      # Pass the home configuration helper to modules
      mkHomeManagerConfiguration = {
        withModules = modules: mkHomeConfig {inherit pkgs modules;};
      };
    };

    modules = [
      # Apply our overlays. Overlays are keyed by system type so we have
      # to go through and apply our system type. We do this first so
      # the overlays are available globally.
      {nixpkgs.overlays = overlays;}

      # Trust our own user
      {nix.settings.trusted-users = [user];}

      # New and faster replacement for cppNix (the default nix interpreter)
      inputs.lix-module.nixosModules.default

      machineConfig
      # userOSConfig
      home-manager.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs pkgs;};
          sharedModules = [
            # Use Nixcord for declaratively managing discord
            inputs.nixcord.homeManagerModules.nixcord

            # Plasma-manager for managing KDE Plasma
            inputs.plasma-manager.homeManagerModules.plasma-manager
          ];

          users.${user} = {config, ...}: {
            imports = [
              # Import the base home-manager configuration
              ../home
            ];
            _module.args = {
              inherit user;
            };
          };
        };
      }

      # We expose some extra arguments so that our modules can parameterize
      # better based on these values.
      {
        config._module.args = {
          currentSystem = system;
          currentSystemName = name;
          currentSystemUser = user;
          inherit inputs;
        };
      }
    ];
  }
