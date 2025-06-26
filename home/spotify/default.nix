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
            popupLyrics
            betterGenres
        ];
        theme = spicePkgs.themes.comfy;
        colorScheme = "catppuccin-mocha";
    };
}
