{assets, ...}: {
  environment.customIcons = {
    enable = true;
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

      {
        path = "/Users/daniel/Applications/Home Manager Trampolines/Spotify.app";
        icon = "${assets}/darwin-icons/spotify.icns";
      }
      {
        path = "/Users/daniel/Applications/Home Manager Trampolines/kitty.app";
        icon = "${assets}/darwin-icons/kitty.icns";
      }
      {
        path = "/Users/daniel/Applications/Home Manager Trampolines/Vesktop.app";
        icon = "${assets}/darwin-icons/discord.icns";
      }
    ];
  };
}
