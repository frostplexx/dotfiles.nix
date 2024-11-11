{ pkgs }:

let
  # Helper function to import a shell file
  importShell = file: import (./. + "/${file}") { inherit pkgs; };

  # Get all .nix files in the current directory
  files = builtins.attrNames (builtins.readDir ./.);

  # Filter for .nix files that aren't default.nix
  shellFiles = builtins.filter
    (name:
      name != "default.nix" &&
      builtins.match ".*\\.nix" name != null
    )
    files;

  # Convert file names to shell names (remove .nix extension)
  shellNames = map
    (name:
      builtins.substring 0 (builtins.stringLength name - 4) name
    )
    shellFiles;

  # Create the shells attribute set
  shells = builtins.listToAttrs (map
    (name: {
      inherit name;
      value = importShell "${name}.nix";
    })
    shellNames
  );

in
shells
