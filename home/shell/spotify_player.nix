{pkgs, ...}: {
  programs.spotify-player = {
    enable = true;
    package = pkgs.spotify-player.override {
      withAudioBackend = "rodio";
      withSixel = false;
      withFuzzy = true;
      withImage = true;
      withNotify = true;
      withDaemon = true;
      withStreaming = true;
      withMediaControl = false;
    };
    settings = {
      theme = "default";
      border_type = "Rounded";
      progress_bar_type = "Line";
      playback_window_position = "Top";
      play_icon = "";
      pause_icon = "";
      name = "mbp";
      liked_icon = "";
      default_device = "mbp";
      notify_streaming_only = true;
      enable_streaming = "DaemonOnly";
      copy_command = {
        command = "wl-copy";
        args = [];
      };
      client_id = "d5b77903b8f34340a4d35a044fcc73c5";
      device = {
        audio_cache = true;
        normalization = false;
        volume = 50;
      };
    };
  };

}
