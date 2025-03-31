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
in
  systemFunc rec {
    inherit system;

    modules = [
      # Apply our overlays. Overlays are keyed by system type so we have
      # to go through and apply our system type. We do this first so
      # the overlays are available globally.
      {nixpkgs.overlays = overlays;}

      # Allow unfree packages.
      {nixpkgs.config.allowUnfree = true;}

      # Trust our own user
      {nix.settings.trusted-users = [user];}

      # Use Nixcord for declaratively managing discord
      inputs.nixcord.homeManagerModules.nixcord

      # Plasma-manager for managing KDE Plasma
      inputs.plasma-manager.homeManagerModules.plasma-manager

      # New and faster replacement for cppNix (the default nix interpreter)
      inputs.lix-module.nixosModules.default

      machineConfig
      # userOSConfig
      # home-manager.home-manager
      # {
      #   home-manager = {
      #     useGlobalPkgs = true;
      #     useUserPackages = true;
      #     extraSpecialArgs = {
      #       inherit inputs;
      #       # Pass any other special arguments needed by home-manager modules
      #     };
      #     users.${user} = {config, ...}: {
      #       imports = [
      #         # Import the base home-manager configuration
      #         ../home
      #         # Then apply the selected modules using the function
      #         {
      #           _module.args.mkHomeManagerConfiguration = {
      #             withModules = modules: {
      #               imports = map (name: ../home/${name}) modules;
      #             };
      #           };
      #         }
      #         # Apply the selected modules
      #         (../home/_module.args.mkHomeManagerConfiguration.withModules hm-modules)
      #       ];
      #     };
      #   };
      # }

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
