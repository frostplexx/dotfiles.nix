{ vars, pkgs, ... }:
let
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
in
{
  nixpkgs.config.allowUnfree = true;
  imports = programModules ++ [
    ./stylix.nix
  ];

  home = {
    inherit homeDirectory;
    stateVersion = "24.05";
  };


  # Write nix config that enables nix command and flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs.home-manager.enable = true;
}
