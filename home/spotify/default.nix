{
  inputs,
  pkgs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};

  spotify = pkgs.spotify.overrideAttrs (oldAttrs: {
    src =
      if (pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64)
      then
        pkgs.fetchurl {
          url = "https://web.archive.org/web/20251029235406/https://download.scdn.co/SpotifyARM64.dmg";
          sha256 = "sha256-0gwoptqLBJBM0qJQ+dGAZdCD6WXzDJEs0BfOxz7f2nQ=";
        }
      else oldAttrs.src;
  });
in {
  programs.spicetify = {
    enable = true;
    spotifyPackage = spotify;
    spotifyLaunchFlags = "--disable-update-restarts";
    enabledExtensions = with spicePkgs.extensions; [
      hidePodcasts
      betterGenres
      lastfm
      listPlaylistsWithSong
      # popupLyrics
    ];
    # enabledCustomApps = with spicePkgs.apps; [
    # ];
    # theme = spicePkgs.themes.comfy;
    # theme = spicePkgs.themes.catppuccin;
    theme = spicePkgs.themes.dribbblish;
    # colorScheme = "mocha";
    colorScheme = "catppuccin-mocha";
  };
}
