# Home Manager configuration with module selection
_: let
  # List of all available modules
  allModules = {
    aerospace = ./programs/aerospace;
    editor = ./programs/editor;
    firefox = ./programs/firefox;
    git = ./programs/git;
    wezterm = ./programs/wezterm;
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
