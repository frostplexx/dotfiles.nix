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
            adblockify
            hidePodcasts
            shuffle # shuffle+ (special characters are sanitized out of extension names)
            betterGenres
            lastfm
            listPlaylistsWithSong
        ];
        enabledCustomApps = with spicePkgs.apps; [
            lyricsPlus
            ncsVisualizer
        ];
        theme = spicePkgs.themes.comfy;
        colorScheme = "catppuccin-mocha";
    };
}
