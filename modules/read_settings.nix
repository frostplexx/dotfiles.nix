{pkgs, lib, config, ...}: let
  # Read and parse settings.yaml from parent directory
  settingsFile = ../settings.yaml;

  # Parse YAML settings if file exists, otherwise use defaults
  settings =
    if builtins.pathExists settingsFile
    then builtins.fromJSON (builtins.readFile (
      pkgs.runCommand "yaml-to-json" {
        buildInputs = [ pkgs.yq-go ];
      } ''
        yq eval -o=json "${settingsFile}" > $out
      ''
    ))
    else {
      # Default settings structure
      dotfiles_path = null;
      nh_flake = null;
      nixpkgs = {
        allow_unfree = true;
        allow_unsupported_system = false;
        allow_broken = true;
        allow_insecure = true;
      };
      state_version = {
        darwin = 6;
        linux = "24.05";
      };
    };

in {
  options = {
    getDotfilesPath = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Path to the dotfiles repository root";
    };
    mkDotfilesEnv = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      description = "Environment variables for dotfiles";
    };
    getNixpkgsConfig = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      description = "Nixpkgs configuration settings";
    };
    getStateVersion = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      description = "State versions for Darwin and Linux";
    };
  };

  config = {
    getDotfilesPath =
      # Priority: environment variable > YAML setting > current directory
      if builtins.getEnv "DOTFILES_PATH" != ""
      then builtins.getEnv "DOTFILES_PATH"
      else if settings.dotfiles_path != null
      then settings.dotfiles_path
      else toString (builtins.dirOf settingsFile);

    mkDotfilesEnv = {
      DOTFILES_PATH = config.getDotfilesPath;
      NH_FLAKE =
        if settings.nh_flake != null
        then settings.nh_flake
        else config.getDotfilesPath;
    };

    getNixpkgsConfig = {
      allowUnfree = settings.nixpkgs.allow_unfree;
      allowUnsupportedSystem = settings.nixpkgs.allow_unsupported_system;
      allowBroken = settings.nixpkgs.allow_broken;
      allowInsecure = settings.nixpkgs.allow_insecure;
      packageOverrides = pkgs:
        if builtins.hasAttr "electron_version" settings && settings.electron_version != null
        then { electron = pkgs.${settings.electron_version}; }
        else {};
    };

    getStateVersion = {
      darwin = settings.state_version.darwin;
      linux = settings.state_version.linux;
    };
  };
}
