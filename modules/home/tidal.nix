_: {
  flake.homeManagerModules.tidal = _: {
    programs.tidaluna = {
      stores = [
        "https://github.com/meowarex/TidalLuna-Plugins/releases/download/latest/store.json"
        "https://github.com/Inrixia/luna-plugins/releases/download/dev/store.json"
      ];

      #To list settingsNames and settings:  const idb = await luna.core.ReactiveStore.getStore("@luna/pluginStorage").dump(); console.log(JSON.stringify(idb, null, 2));
      plugins = [
        {
          shortURL = "@meowarex/radiant-lyrics";
          settingsName = "RadiantLyrics";
          settings = {
            "lyricsGlowEnabled" = true;
            "textGlow" = 20;
            "lyricsStyle" = 2;
            "lyricsFontSize" = 100;
            "blurInactive" = true;
            "contextAwareLyrics" = true;
            "bubbledLyrics" = true;
            "romanizeLyrics" = false;
            "aiSyllables" = false;
            "syllableStyle" = 0;
            "syllableLogging" = false;
            "lyricsOffsetMs" = 0;
            "hideUIEnabled" = true;
            "playerBarVisible" = false;
            "qualityProgressColor" = false;
            "integratedSeekBar" = false;
            "floatingPlayerBar" = true;
            "playerBarRadius" = 15;
            "playerBarSpacing" = 4;
            "playerBarBlur" = true;
            "playerBarBlurAmount" = 15;
            "playerBarTintEnabled" = true;
            "playerBarTint" = 5;
            "playerBarTintColor" = "#000000";
            "playerBarTintCustomColors" = [];
            "backdropEnabled" = false;
            "backdropStyle" = 0;
            "backdropPlaybackReactive" = true;
            "CoverEverywhere" = true;
            "performanceMode" = false;
            "backdropOpacity" = 100;
            "backdropWarp" = 10;
            "backdropBlurPasses" = 6;
            "backdropSpeed" = 175;
            "backdropContrast" = 125;
            "backdropSaturation" = 125;
            "backdropDithering" = 15;
            "backdropScale" = 100;
            "backdropDarken" = 8;
          };
        }
        {
          shortURL = "Song Downloader";
          settingsName = "SongDownloader";
          settings = {
            "downloadQuality" = "HI_RES_LOSSLESS";
            "pathFormat" = "{artist} - {album} - {title}";
            "useRealMAX" = true;
          };
        }
        {
          shortURL = "NoBuffer";
        }
      ];
    };
  };
}
