{pkgs, ...}: {
    programs.spotify-player = {
        enable = false;
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

    # launchd.agents.spotify-player = {
    #     enable = true;
    #     config = {
    #         ProgramArguments = [
    #             "${pkgs.spotify-player.override {
    #                 withAudioBackend = "rodio";
    #                 withSixel = false;
    #                 withFuzzy = false;
    #                 withImage = false;
    #                 withNotify = false;
    #                 withDaemon = true;
    #                 withStreaming = true;
    #                 withMediaControl = false;
    #             }}/bin/spotify_player"
    #             "-d"
    #         ];
    #         RunAtLoad = true;
    #         KeepAlive = {
    #             Crashed = true;
    #             SuccessfulExit = false;
    #         };
    #         StandardOutPath = "/tmp/spotify-player.log";
    #         StandardErrorPath = "/tmp/spotify-player.error.log";
    #         ProcessType = "Background";
    #     };
    # };
}
