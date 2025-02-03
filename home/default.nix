# Home Manager configuration with module selection
_: let
  # List of all available modules
  allModules = {
    aerospace = ./programs/aerospace;
    editor = ./programs/editor;
    firefox = ./programs/firefox;
    git = ./programs/git;
    kitty = ./programs/kitty;
    wezterm = ./programs/wezterm;
    ghostty = ./programs/ghostty;
    nixcord = ./programs/nixcord;
    niri = ./programs/niri;
    plasma = ./programs/plasma;
    gnome = ./programs/gnome;
    hyprland = ./programs/hyprland;
    shell = ./programs/shell;
    spicetify = ./programs/spicetify;
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
