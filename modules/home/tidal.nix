_: {
  flake.homeManagerModules.tidal = {pkgs, ...}: {
    programs.tidaluna = {
      enable = true;
      stores = [
        "https://github.com/meowarex/TidalLuna-Plugins/releases/download/latest/store.json"
        "https://github.com/Inrixia/luna-plugins/releases/download/dev/store.json"
      ];

      #To list settingsNames and settings:  const idb = await luna.core.ReactiveStore.getStore("@luna/pluginStorage").dump(); console.log(JSON.stringify(idb, null, 2));
      plugins = [
        # {
        #   shortURL = "@meowarex/radiant-lyrics";
        #   settingsName = "RadiantLyrics";
        #   settings = {
        #     "lyricsGlowEnabled" = false;
        #     "trackTitleGlow" = false;
        #     "hideUIEnabled" = false;
        #     "playerBarVisible" = false;
        #     "qualityProgressColor" = false;
        #     "floatingPlayerBar" = true;
        #     "playerBarTint" = 10;
        #     "playerBarTintColor" = "#000000";
        #     "playerBarTintCustomColors" = [];
        #     "playerBarRadius" = 8;
        #     "playerBarSpacing" = 10;
        #     "CoverEverywhere" = false;
        #     "performanceMode" = false;
        #     "spinningArt" = true;
        #     "textGlow" = 20;
        #     "backgroundScale" = 15;
        #     "backgroundRadius" = 25;
        #     "backgroundContrast" = 120;
        #     "backgroundBlur" = 80;
        #     "backgroundBrightness" = 40;
        #     "spinSpeed" = 45;
        #     "settingsAffectNowPlaying" = true;
        #     "stickyLyrics" = false;
        #     "stickyLyricsIcon" = "sparkle";
        #     "lyricsStyle" = 2;
        #     "syllableStyle" = 0;
        #     "contextAwareLyrics" = true;
        #     "blurInactive" = true;
        #     "bubbledLyrics" = true;
        #     "syllableLogging" = false;
        #     "lyricsFontSize" = 100;
        #     "romanizeLyrics" = false;
        #   };
        # }
        {
          shortURL = "DiscordRPC";
          settingsName = "DiscordRPC";
          settings = {
            "displayOnPause" = false;
            "displayArtistIcon" = true;
            "displayPlaylistButton" = true;
            "customStatusText" = "{track} by {artist}";
          };
        }
        {
          shortURL = "DesktopConnect";
        }
        {
          shortURL = "NoBuffer";
        }
        {
          shortURL = "Themer";
          settingsName = "Themer";
          settings = {
            "css" = builtins.readFile (
              pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/frostplexx/catppuccin-tidal/refs/heads/main/mocha.css";
                sha256 = "sha256-eN17wamb5sz3cY2ZfFwS2nYkYaUZTJV11chWhEKVrfU=";
              }
            );
          };
        }
      ];
    };
  };
}
