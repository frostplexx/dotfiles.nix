# This module assembles the full list of system modules to be used
# for building the system, including overlays, machine config,
# user config, and OS-specific modules.
{
  inputs,
  pkgs,
  nixpkgsConfig,
  system,
  user,
  name,
  machineConfig,
  machineConfigArgs,
  hm-modules,
  assets,
  mkHomeConfig,
}: let
  # Determine if we are building for Darwin (macOS)
  inherit (pkgs.stdenv) isDarwin;
  # Select the correct Home Manager module set for the OS
  home-manager =
    if isDarwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;
  # Import Darwin and Linux specific modules
  darwinModule = import ./darwin.nix {inherit inputs user;};
  linuxModule = import ./linux.nix {inherit inputs;};
in
  [
    # Apply overlays globally
    {nixpkgs.overlays = pkgs.overlays or [];}
    # Apply Nixpkgs configuration globally
    {nixpkgs.config = nixpkgsConfig;}
    # Import the machine-specific configuration, passing all relevant arguments
    ({modulesPath, ...}: import machineConfig (machineConfigArgs // {inherit modulesPath;}))
    # Import any additional modules (e.g., jinx)
    ({pkgs, ...}: import ../../modules {inherit pkgs;})
    # Trust the root user and the system user for Nix operations
    {nix.settings.trusted-users = ["root" user];}
    # Home Manager configuration for user environments
    home-manager.home-manager
    {
      nixpkgs.config = nixpkgsConfig;
      # Set the state version for Home Manager (Darwin and Linux differ)
      system.stateVersion =
        if isDarwin
        then 6
        else "24.05";
      home-manager = {
        useGlobalPkgs = true; # Use the global pkgs set
        useUserPackages = true; # Allow user packages
        backupFileExtension = "backup"; # Backup extension for file collisions
        # Pass extra arguments to all Home Manager modules
        extraSpecialArgs = {inherit inputs system assets;};
        # Shared Home Manager modules for all users
        sharedModules =
          [
            inputs.nixcord.homeModules.nixcord
            inputs._1password-shell-plugins.hmModules.default
            inputs.nixkit.homeModules.default
            inputs.sops-nix.homeManagerModules.sops
            inputs.spicetify-nix.homeManagerModules.spicetify
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # Stupid module fails when not on darwin
            inputs.mac-app-util.homeManagerModules.default
          ];
        # Per-user Home Manager configuration
        users.${user} = mkHomeConfig {
          inherit user;
          modules = hm-modules;
        };
      };
    }
    # Expose extra arguments for use in custom modules
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        inherit user system inputs assets;
      };
    }
    # Import Darwin or Linux specific modules as appropriate
    (
      if isDarwin
      then darwinModule
      else linuxModule
    )
  ]
  # Optionally add Determinate NixOS modules for Linux systems
  ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    inputs.determinate.nixosModules.default
  ]
