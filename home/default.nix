# Home Manager configuration with module selection
_: let
  # List of all available modules
  allModules = {
    aerospace = ./aerospace;
    editor = ./editor;
    firefox = ./firefox;
    git = ./git;
    kitty = ./kitty;
    ghostty = ./ghostty;
    nixcord = ./nixcord;
    plasma = ./plasma;
    shell = ./shell;
    ssh = ./ssh;
  };

  # Helper function to create home-manager configuration
  mkHomeConfiguration = {modules ? []}: {
    imports = map (name: allModules.${name}) modules;
  };
in {
  # Global home settings
  home = {
    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles.nix";
    };
  };

  # Create configuration with specific modules
  _module.args.mkHomeManagerConfiguration = {
    withModules = modules:
      mkHomeConfiguration {
        inherit modules;
      };
  };
}
