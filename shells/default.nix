# shells/default.nix
{ pkgs }:
let
  # Common arguments to pass to each shell
  commonArgs = {
    inherit pkgs;
    inherit (pkgs) system;
  };

  # Get the directory of this file
  dir = builtins.dirOf (builtins.toString ./.);

  # List all files in the directory
  files = builtins.attrNames (builtins.readDir dir);

  # Filter for .nix files that aren't default.nix
  shellFiles = builtins.filter (name:
    name != "default.nix" &&
    builtins.match ".*\\.nix" name != null
  ) files;

  # Convert filenames to attribute names (remove .nix extension)
  shellNames = map (name:
    builtins.substring 0 (builtins.stringLength name - 4) name
  ) shellFiles;

  # Import all shell files and create an attribute set
  importShell = name: import (dir + "/${name}.nix") commonArgs;
  shells = builtins.listToAttrs (map (name: {
    inherit name;
    value = importShell name;
  }) shellNames);

in shells
