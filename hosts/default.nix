_:

{
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
