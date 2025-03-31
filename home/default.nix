# Home Manager configuration with module selection
{
  pkgs,
  user,
  ...
}: let
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
    # username = user;
    # homeDirectory = "/Users/daniel";
    stateVersion = "23.11"; # Use appropriate state version
    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles.nix";

      EDITOR = "nvim"; # Default editor, can be overridden in specific modules
    };
  };

  programs = {
    home-manager.enable = true; # Let Home Manager manage itself
    zsh.enable = true; # Basic bash configuration
  };
  # Create configuration with specific modules
  _module.args.mkHomeManagerConfiguration = {
    withModules = modules:
      mkHomeConfiguration {
        inherit modules;
      };
  };
}
