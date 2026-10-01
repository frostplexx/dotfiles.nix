{
  self,
  inputs,
  lib,
  config,
  ...
}: let
  inherit (config.flake.lib) collectModules nixpkgsConfig;

  # Overlays
  overlays = [
    inputs.vicinae.overlays.default
    # TODO: Remove once vscodium is fixed
    (_final: prev: {
      vscodium = prev.vscodium.overrideAttrs (_old: {
        preFixup = "";
      });
    })
  ];
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
          inputs.nixkit.darwinModules.default
          inputs.determinate.darwinModules.default
          inputs.sops-nix.darwinModules.sops

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
                  inputs.agate.homeManagerModules.default
                  inputs.nvf.homeManagerModules.default
                  inputs.nixcord.homeModules.nixcord
                  inputs.nixkit.homeModules.default
                  inputs.zen-browser.homeModules.beta
                  inputs.tidaluna.homeManagerModules.default
                  inputs.sops-nix.homeManagerModules.sops
                  inputs.vicinae.homeManagerModules.default
                  {
                    # Disable nix management in home-manager on Darwin (handled by Determinate)
                    nix.enable = false;
                    targets.darwin.linkApps.enable = false;
                    targets.darwin.copyApps.enable = true;
                  }
                ]
                ++ collectModules (
                  lib.filterAttrs
                  (n: _: !(builtins.elem n ["plasma" "sunshine"]))
                  self.homeManagerModules
                );
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
