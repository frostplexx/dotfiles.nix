{
  self,
  inputs,
  lib,
  config,
  ...
}: let
  collectModules = attrs: lib.attrValues (lib.filterAttrs (_n: v: v != {}) attrs);

  nixPkgsConfig = {
    allowUnfree = true;
    allowBroken = false;
    allowUnsupportedSystem = false;
  };

  overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];
in {
  flake = {
    nixosConfigurations.tiramisu = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          # Core modules
          inputs.home-manager.nixosModules.home-manager
          inputs.nixkit.nixosModules.default
          inputs.determinate.nixosModules.default
          inputs.sops-nix.nixosModules.sops
          inputs.disko.nixosModules.disko

          # Nixpkgs configuration
          {
            nixpkgs.config = nixPkgsConfig;
            nixpkgs.overlays = overlays;
          }

          # Home Manager shared modules
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs;
                inherit (config.flake) defaults;
              };
              sharedModules =
                [
                  inputs.nvf.homeManagerModules.default
                  inputs.nixcord.homeModules.nixcord
                  inputs.nixkit.homeModules.default
                  inputs.zen-browser.homeModules.beta
                  inputs.tidaluna.homeManagerModules.default
                  inputs.sops-nix.homeManagerModules.sops
                  inputs.spicetify-nix.homeManagerModules.spicetify
                  inputs.plasma-manager.homeModules.plasma-manager
                ]
                ++ collectModules (
                  lib.filterAttrs
                  (n: _: !(builtins.elem n ["agate" "obsidian" "vscode"] || lib.hasPrefix "neovim" n))
                  self.homeManagerModules
                );
            };
          }
        ]
        ++ collectModules self.nixOSModules;
      specialArgs = {
        inherit inputs;
        inherit (config.flake) defaults;
      };
    };
  };
}
