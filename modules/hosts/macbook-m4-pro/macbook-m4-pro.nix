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
  overlays = [
    # TODO: Remove once vscodium is fixed
    (_final: prev: {
      vscodium = prev.vscodium.overrideAttrs (_old: {
        preFixup = "";
      });
    })
    # TODO(daniel): remove moonlight-qt overlay once nixpkgs bump fixes
    #   the underlying issues:
    #   1. Qt's qconfig.pri hardcodes QMAKE_MACOSX_DEPLOYMENT_TARGET=13
    #      while all nixpkgs deps target 14.0, causing Apple ld to crash.
    #      Fix: https://github.com/NixOS/nixpkgs/pull/NNN (upstream Qt
    #      build should match SDK version).
    #   2. ld64-957.1 (from cctools-port 1010.6) crashes with SIGTRAP
    #      when linking arm64 Mach-O with many object files.
    #      Fix: newer cctools/ld64 or switch to ld64.lld upstream.
    (_final: prev: {
      moonlight-qt = prev.moonlight-qt.overrideAttrs (old: {
        MACOSX_DEPLOYMENT_TARGET = "14.0";
        qmakeFlags = (old.qmakeFlags or []) ++ ["QMAKE_MACOSX_DEPLOYMENT_TARGET=14.0"];
        NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -B${prev.lld}/bin --ld-path=${prev.lld}/bin/ld64.lld";
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
          inputs.lazykeys.darwinModules.default
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
                  inputs.sops-nix.homeManagerModules.sops
                  inputs.spicetify-nix.homeManagerModules.spicetify
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
