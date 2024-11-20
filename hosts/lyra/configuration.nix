{
  home-manager,
  nix-darwin,
  inputs,
  vars,
  ...
}: {
  imports = [
    ./apps.nix
    ./system.nix
    ./host-users.nix
    ./custom_icons/custom_icons.nix
    ./stylix.nix
  ];

  services.nix-daemon.enable = true;

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
}
