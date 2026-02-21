{
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
    overlays = [
        inputs.nixkit.overlays.default
        (_final: prev: {
            kitty = prev.kitty.overrideAttrs (_oldAttrs: {
                doCheck = false;
            });
        })
    ];
in {
    imports = [
        inputs.flake-parts.flakeModules.modules
    ];

    # Declare the module options using flake-parts-modules
    flake = {
        modules = {
            darwin = {};
            nixos = {};
            homeManager = {};
        };

        # Darwin configuration for macbook-m4-pro
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
                                    inputs.sops-nix.homeManagerModules.sops
                                    inputs.spicetify-nix.homeManagerModules.spicetify
                                    {
                                        # Disable nix management in home-manager on Darwin (handled by Determinate)
                                        nix.enable = false;
                                        targets.darwin.linkApps.enable = false;
                                        targets.darwin.copyApps.enable = true;
                                    }
                                ]
                                ++ collectModules config.flake.modules.homeManager;
                            extraSpecialArgs = {
                                inherit inputs;
                                inherit (config.flake) defaults;
                            };
                        };
                    }
                ]
                ++ collectModules config.flake.modules.darwin;
            specialArgs = {
                inherit inputs;
                inherit (config.flake) defaults;
            };
        };

        # NixOS configuration for tiramisu
        nixosConfigurations.tiramisu = inputs.nixpkgs-nixos-25-11.lib.nixosSystem {
            system = "x86_64-linux";
            modules =
                [
                    # Core modules
                    inputs.home-manager.nixosModules.home-manager
                    inputs.nixkit.nixosModules.default
                    inputs.determinate.nixosModules.default

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
                                    inputs.sops-nix.homeManagerModules.sops
                                    inputs.spicetify-nix.homeManagerModules.spicetify
                                    inputs.plasma-manager.homeModules.plasma-manager
                                ]
                                ++ collectModules config.flake.modules.homeManager;
                            extraSpecialArgs = {
                                inherit inputs;
                                inherit (config.flake) defaults;
                            };
                        };
                    }
                ]
                ++ collectModules config.flake.modules.nixos;
            specialArgs = {
                inherit inputs;
                inherit (config.flake) defaults;
            };
        };
    };
}
