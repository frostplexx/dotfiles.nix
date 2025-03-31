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
  isDarwin = pkgs.stdenv.isDarwin;
  # The config files for this system.
  machineConfig = ../machines/${name};

  # Settings for Package management
  nixpkgsConfig = {
    allowUnfree = true;
    allowUnsupportedSystem = false;
    allowBroken = true;
    allowInsecure = true; # Fixed typo here
  };

  # NixOS vs nix-darwin functions
  systemFunc =
    if isDarwin
    then inputs.darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if isDarwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;

  # Nixpkgs alias with settings applied that we can pass through to our machines
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = nixpkgsConfig;
  };

  # Build the home configuration from the modules
  mkHomeConfig = {
    pkgs,
    modules ? [],
    user,
  }: {
    # Import the fixed global config and each applied package
    imports =
      [
        ../home
      ]
      ++ builtins.map (name: ../home/${name}) modules;
    _module.args = {inherit user;};
    # Apply nix config
    nixpkgs.config = nixpkgsConfig;
  };
in
  systemFunc rec {
    inherit system;

    modules = [
      # Apply our overlays. Overlays are keyed by system type so we have
      # to go through and apply our system type. We do this first so
      # the overlays are available globally.
      {nixpkgs.overlays = overlays;}
      # Apply the config we defined above
      {nixpkgs.config = nixpkgsConfig;}
      # Trust our own user
      {nix.settings.trusted-users = [user];}
      # New and faster replacement for cppNix (the default nix interpreter)
      inputs.lix-module.nixosModules.default
      (import machineConfig {inherit user system pkgs;})

      # Home manager configuration
      home-manager.home-manager
      {
        nixpkgs.config = nixpkgsConfig;
        system.stateVersion = 6;
        home-manager = {
          # useGlobalPkgs needs to be disabled to be able to use overlays
          useGlobalPkgs = false;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs pkgs;};
          # Home Manager Modules
          sharedModules = [
            # Use Nixcord for declaratively managing discord
            inputs.nixcord.homeManagerModules.nixcord
            # Plasma-manager for managing KDE Plasma
            inputs.plasma-manager.homeManagerModules.plasma-manager
          ];
          # Apply only the specific modules from hm-modules
          users.${user} = mkHomeConfig {
            inherit pkgs;
            user = user;
            modules = hm-modules;
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
