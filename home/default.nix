{
  vars,
  pkgs,
  ...
}: let
  # Get all immediate subdirectories of ./programs
  programDirs = builtins.attrNames (
    builtins.readDir ./programs
  );
  # Map each directory to its default.nix path
  programModules = map (dir: ./programs/${dir}/default.nix) programDirs;

  # Determine home directory based on system
  homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${vars.user}"
    else "/home/${vars.user}";
in {
  nixpkgs.config.allowUnfree = true;
  imports = programModules;

  home = {
    inherit homeDirectory;
    stateVersion = "24.05";
    # Dont manage this file because it causes issues
    file."~/.gtkrc-2.0".enable = false;
  };

  programs.home-manager.enable = true;
}
