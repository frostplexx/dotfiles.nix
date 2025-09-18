_: {
    programs.btop = {
        enable = true;
        settings = {
            theme_background = false;
            # This causes problems or something
            vim_keys = false;
            update_ms = 700;
        };
    };
}
