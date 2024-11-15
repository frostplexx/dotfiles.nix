{ pkgs }: rec {
  apple-music-desktop = pkgs.callPackage ./apple-music.nix { };
}
