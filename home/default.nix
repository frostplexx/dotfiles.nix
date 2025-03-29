# Home Manager configuration with module selection
_: let
  # List of all available modules
  allModules = {
    aerospace = ./programs/aerospace;
    editor = ./programs/editor;
    firefox = ./programs/firefox;
    git = ./programs/git;
    wezterm = ./programs/wezterm;
    kitty = ./programs/kitty;
    ghostty = ./programs/ghostty;
    nixcord = ./programs/nixcord;
    plasma = ./programs/plasma;
    shell = ./programs/shell;
    ssh = ./programs/ssh;
    macos-wm = ./programs/macos-wm;
  };

  # Helper function to create home-manager configuration
  mkHomeConfiguration = {modules ? []}: {
    imports = map (name: allModules.${name}) modules;
  };
in {
  # TODO: move to a better place
  home.sessionVariables = {
    NH_FLAKE = "$HOME/dotfiles.nix";
  };

  _module.args.mkHomeManagerConfiguration = {
    # Create configuration with all modules
    withAll = mkHomeConfiguration {
      modules = builtins.attrNames allModules;
    };

    # Create configuration with specific modules
    withModules = modules:
      mkHomeConfiguration {
        inherit modules;
      };
  };
}
