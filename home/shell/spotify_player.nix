_: {
  programs.spotify-player = {
    enable = true;
    settings = {
      theme = "default";
      border_type = "Rounded";
      progress_bar_type = "Line";
      playback_window_position = "Top";
      play_icon = "";
      pause_icon = "";
      liked_icon = "";
      copy_command = {
        command = "wl-copy";
        args = [];
      };
      client_id_command = "~/dotfiles.nix/home/programs/shell/spotify_client_id.sh";
      client_id = "d5b77903b8f34340a4d35a044fcc73c5";
      device = {
        audio_cache = true;
        normalization = true;
        volume = 50;
      };
    };
  };
}
