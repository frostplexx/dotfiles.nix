_:

{

  # Your existing nixosConfigurations and darwinConfigurations stay the same
  nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit vars inputs;};
    modules = [
      ./nix/core.nix
      inputs.yuki.nixosModules.default
      ./hosts/nixos/configuration.nix
      inputs.stylix.nixosModules.stylix
      home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = [inputs.nur.overlay];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit vars inputs;};
          users.${vars.user} = import ./home;
          sharedModules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
            inputs.nixcord.homeManagerModules.nixcord
            inputs.spicetify-nix.homeManagerModules.default
            {
              # explicitly disable stylix for spicetify because its managed by spicetify-nix
              # TODO: This is a stupid place to put this and needs to be refactored
              stylix.targets.spicetify.enable = false;
            }
          ];
        };
      }
    ];
  };


  darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {inherit vars inputs;};
    modules = [
      ./nix/core.nix
      inputs.yuki.nixosModules.default
      inputs.stylix.darwinModules.stylix
      ./hosts/darwin/configuration.nix
      inputs.darwin-custom-icons.darwinModules.default
      home-manager.darwinModules.home-manager
      {
        nixpkgs.overlays = [
          inputs.nixpkgs-firefox-darwin.overlay
          inputs.nur.overlay
        ];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit vars inputs;};
          users.${vars.user} = import ./home;
          sharedModules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
            inputs.nixcord.homeManagerModules.nixcord
            inputs.spicetify-nix.homeManagerModules.default
            {
              # explicitly disable stylix for spicetify because its managed by spicetify-nix
              # TODO: This is a stupid place to put this and needs to be refactored
              stylix.targets.spicetify.enable = false;
            }
          ];
        };
      }
    ];
  };

  # nix-darwin configurations
  parts.darwinConfigurations = {
lyra = {
    system = "aarch64-darwin";
    stateVersion = 4;
    modules = [ ./lyra/configuration.nix ];
  };
  };

  # NixOS configurations
  parts.nixosConfigurations = {
    phoenix = {
      system = "x86_64-linux";
      stateVersion = "25.05";
      modules = [ ./phoenix/configuration.nix];
    };
  };
}
