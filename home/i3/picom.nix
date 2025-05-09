_: {
    services.picom = {
        enable = true;
        inactiveOpacity = 1;
        settings = {
            blur = {
                method = "gaussian";
                size = 10;
                deviation = 5.0;
            };

            # Looks weird on i3 because only border is rounded
            # Rounded corners configuration
            # corner-radius = 8;
            # round-borders = 1;

            # Exclude certain windows from having rounded corners
            rounded-corners-exclude = [
                "window_type = 'dock'"
                "window_type = 'desktop'"
                "class_g = 'i3bar'"
                "class_g = 'i3-frame'"
            ];

            # Additional picom settings for better appearance
            shadow = true;
            shadow-radius = 12;
            shadow-offset-x = -7;
            shadow-offset-y = -7;
            shadow-opacity = 0.7;

            # Fading effects
            fading = true;
            fade-in-step = 0.12;
            fade-out-step = 0.12;
            fade-delta = 5;
        };
    };
}
