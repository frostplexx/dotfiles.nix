# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  inputs,
  nixpkgs,
  overlays,
  ...
} @ args: name: {
  system,
  user,
  hm-modules ? [],
}: let
  inherit (pkgs.stdenv) isDarwin;
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

  # Merge the explicitly needed attributes with all the extra ones captured in args.
  machineConfigArgs = {inherit system user pkgs inputs;} // args;

  # Build the home configuration from the modules
  mkHomeConfig = {
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
    inherit (inputs.nixpkgs) lib;

    modules = [
      # Apply our overlays. Overlays are keyed by system type so we have
      # to go through and apply our system type. We do this first so
      # the overlays are available globally.
      {nixpkgs.overlays = overlays;}
      # Apply the config we defined above
      {nixpkgs.config = nixpkgsConfig;}
      # New and faster replacement for cppNix (the default nix interpreter)
      inputs.lix-module.nixosModules.default
      # Import our machine config with all available arguments
      ({modulesPath, ...}: import machineConfig (machineConfigArgs // {inherit modulesPath;}))
      # Trust myself
      {nix.settings.trusted-users = ["root" user];}

      # Home manager configuration
      home-manager.home-manager
      {
        nixpkgs.config = nixpkgsConfig;
        # Why do darwin and linux use different stateVerions???
        system.stateVersion =
          if isDarwin
          then 6
          else "24.05";
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
            inherit user;
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

      # Enable nix-homebrew on macOS
      (
        if isDarwin
        then {
          imports = [inputs.nix-homebrew.darwinModules.nix-homebrew];
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;
            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = false;
            # User owning the Homebrew prefix
            inherit user;
            # Optional: Enable fully-declarative tap management
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
            taps = with inputs; {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "nikitabobko/homebrew-tap" = homebrew-nikitabobko;
              "FelixKratz/homebrew-formulae" = homebrew-felixkratz;
            };
          };
        }
        else {}
      )
    ];
  }
