{assets, ...}: {
    environment.customIcons = {
        enable = false;
        icons = [
            {
                path = "/Users/daniel/Applications/Home Manager Apps/Spotify.app";
                icon = "${assets}/darwin-icons/spotify.icns";
            }
            {
                path = "/Users/daniel/Applications/Home Manager Apps/kitty.app";
                icon = "${assets}/darwin-icons/kitty.icns";
            }
            {
                path = "/Users/daniel/Applications/Home Manager Apps/Vesktop.app";
                icon = "${assets}/darwin-icons/discord.icns";
            }
        ];
    };
}
