{assets, ...}: {
    environment.customIcons = {
        enable = true;
        icons = [
            # {
            #   path = "/Applications/Nix Apps/Spotify.app";
            #   icon = "${assets}/darwin-icons/spotify.icns";
            # }
            {
                path = "/Applications/Nix Apps/kitty.app";
                icon = "${assets}/darwin-icons/kitty.icns";
            }
            {
                path = "/Applications/Nix Apps/Vesktop.app";
                icon = "${assets}/darwin-icons/discord.icns";
            }
        ];
    };
}
