_: {
  flake.homeManagerModules.sonora = {pkgs, ...}: {
    programs.sonora = {
      enable = true;
      settings = {
        appearance = {
          theme = "dark";
          adaptive_theme = true;
          ambient = true;
          ambient_motion = true;
          visualizer = true;
          visualizer_style = "wave";
          visualizer_screens = {
            cover = true;
            lyrics = true;
            queue = true;
          };
          player_bar_layout = "compact";
          rounding = "subtle";
          blur = true;
          os_fullscreen = false;
        };
        normalisation = false;
        discord_presence = false;
        lyrics_providers = [
          "Local"
          "Subsonic"
          "Jellyfin"
          "Spotify"
          "YouTube Music"
          "Apple Music"
          "Musixmatch"
          "LrcLib"
        ];
        lyrics_provider_priority = [
          "Subsonic"
          "Jellyfin"
          "Local"
          "Apple Music"
          "Spotify"
          "YouTube Music"
          "Musixmatch"
          "LrcLib"
          "Kugou"
          "NetEase"
        ];
        lyrics_word_synced_first = true;
        karaoke_lyrics = true;
        blur_lyrics = true;
        romanized_lyrics = true;

        check_updates = false;
        auto_update = false;

        tray_icon = false;
      };
    };
  };
}
