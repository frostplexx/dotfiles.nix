# Main entry point for host configurations
{
  darwinConfigurations = {
    pc-dev-lyra = {
      system = "aarch64-darwin";
      stateVersion = 5;
      modules = [
        ./base # Base configuration
        ./machines/lyra/configuration.nix # Machine-specific configs
      ];
    };
  };

  nixosConfigurations = {
    pc-dev-phoenix = {
      system = "x86_64-linux";
      stateVersion = "24.05";
      modules = [
        ./base # Base configuration
        ./machines/phoenix/configuration.nix # Machine-specific configs
      ];
    };
  };
}
