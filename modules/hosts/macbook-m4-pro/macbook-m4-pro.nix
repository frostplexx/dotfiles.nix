{
  self,
  inputs,
  lib,
  config,
  ...
}: let
  # Helper to collect all modules from an attrset
  collectModules = attrs: lib.attrValues (lib.filterAttrs (_n: v: v != {}) attrs);

  # Shared nixpkgs config
  nixpkgsConfig = {
    allowUnfree = true;
    allowBroken = false;
    allowUnsupportedSystem = false;
  };
  # Overlays
  overlays = [];
in {
  # Declare the module options using flake-parts-modules
  flake = {
    darwinConfigurations.macbook-m4-pro = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules =
        [
          # Core modules
          inputs.home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.nix-homebrew
          inputs.lazykeys.darwinModules.default
          inputs.nixkit.darwinModules.default
          inputs.determinate.darwinModules.default

          # Nixpkgs configuration
          {
            nixpkgs.config = nixpkgsConfig;
            nixpkgs.overlays = overlays;
          }

          # Home Manager shared modules
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              sharedModules =
                [
                  inputs.nvf.homeManagerModules.default
                  inputs.nixcord.homeModules.nixcord
                  inputs.nixkit.homeModules.default
                  inputs.zen-browser.homeModules.beta
                  inputs.tidaluna.homeManagerModules.default
                  inputs.sops-nix.homeManagerModules.sops
                  inputs.nix-index-database.homeModules.default
                  {
                    # Disable nix management in home-manager on Darwin (handled by Determinate)
                    nix.enable = false;
                    targets.darwin.linkApps.enable = false;
                    targets.darwin.copyApps.enable = true;
                  }
                ]
                ++ collectModules self.homeManagerModules;
              extraSpecialArgs = {
                inherit inputs;
                inherit (config.flake) defaults;
              };
            };
          }
        ]
        ++ collectModules self.darwinModules;
      specialArgs = {
        inherit inputs;
        inherit (config.flake) defaults;
      };
    };
  };
}
