_: {
    services.dunst = {
        enable = true;
        settings = {
            global = {
                width = 300;
                height = 300;
                offset = "30x50";

                transparency = 10;
                origin = "bottom-right";
                separator_color = "frame";
                font = "Maple Mono 10";
                highlight = "#89b4fa";
                frame_color = "#89b4fa";
            };
            urgency_low = {
                background = "#1e1e2e";
                foreground = "#cdd6f4";
            };
            urgency_normal = {
                background = "#1e1e2e";
                foreground = "#cdd6f4";
            };

            urgency_critical = {
                background = "#1e1e2e";
                foreground = "#cdd6f4";
                frame_color = "#fab387";
            };
        };
    };
}
