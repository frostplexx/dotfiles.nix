{inputs, ...}: {
  flake.modules.homeManager.spotify = {pkgs, ...}: let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
  in {
    programs.spicetify = {
      enable = false;
      spotifyLaunchFlags = "--disable-update-restarts";
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
        betterGenres
        lastfm
        listPlaylistsWithSong
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
  };
}
