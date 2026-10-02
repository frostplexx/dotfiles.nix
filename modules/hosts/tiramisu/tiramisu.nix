{
  self,
  inputs,
  lib,
  config,
  ...
}: let
  inherit (config.flake.lib) collectModules nixpkgsConfig;

  overlays = [
    inputs.vicinae.overlays.default
    inputs.nix-cachyos-kernel.overlays.pinned
    inputs.millennium.overlays.default
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
          inputs.aerothemeplasma-nix.nixosModules.aerothemeplasma-nix

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
              extraSpecialArgs = {
                inherit inputs;
                inherit (config.flake) defaults;
                aeroTheme = true;
              };
              sharedModules =
                [
                  inputs.nvf.homeManagerModules.default
                  inputs.nixcord.homeModules.nixcord
                  inputs.nixkit.homeModules.default
                  inputs.zen-browser.homeModules.beta
                  inputs.tidaluna.homeManagerModules.default
                  inputs.sops-nix.homeManagerModules.sops
                  inputs.plasma-manager.homeModules.plasma-manager
                ]
                ++ collectModules (
                  lib.filterAttrs
                  (n: _: !(builtins.elem n ["agate" "obsidian" "skhd" "vscode"]))
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
