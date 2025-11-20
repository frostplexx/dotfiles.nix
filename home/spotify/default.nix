{
  inputs,
  pkgs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  programs.spicetify = {
    enable = true;
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
    theme = spicePkgs.themes.catppuccin;
    # colorScheme = "catppuccin-mocha";
    colorScheme = "mocha";
  };
}
