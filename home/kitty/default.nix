{
    pkgs,
    config,
    ...
}: {
    programs.kitty = {
        enable = true;

        # Theme
        #theme = "Catppuccin";

        # Settings
        settings = {
            # Colors
            url_color = "#4dc6ff";

            # Environment
            term = "xterm-256color";
            editor = "nvim";
            shell_integration = "enabled";

            # Window
            window_padding_width = "2 2";
            draw_minimal_borders = "yes";
            background_opacity = "0.9";
            background_blur = "25";
            remember_window_size = "yes";
            initial_window_width = 1280;
            initial_window_height = 800;
            confirm_os_window_close = "1";
            hide_window_decorations = "titlebar-only";
            enabled_layouts = "splits:split_axis=horizontal";

            # macOS specific
            macos_option_as_alt = "both";

            # Titlebar
            wayland_titlebar_color = "background";

            # Cursor
            cursor_shape = "block";
            cursor_blink_interval = "-1";
            cursor_stop_blinking_after = "30.0";
            cursor_trail = "3";

            # Scrolling
            scrollback_lines = "10000";
            scrollback_indicator_opacity = "0.5";

            # Copy behavior
            copy_on_select = "clipboard";
            strip_trailing_spaces = "smart";

            # Undercurl and URLs
            undercurl_style = "thin-dense";
            url_style = "curly";
            show_hyperlink_targets = "yes";

            # Mouse
            mouse_hide_wait = "1.0";

            # Bell
            enable_audio_bell = "no";
            visual_bell_duration = "0.0";
            visual_bell_color = "none";
            window_alert_on_bell = "no";

            # Tab bar
            tab_bar_edge = "top";
            tab_bar_style = "powerline";
            tab_powerline_style = "slanted";
            # tab_title_template = "{index} { tab.active_exe if tab.active_exe not in ('-fish', 'kitten') else title}{tab.last_focused_progress_percent}";
            tab_title_template = "{index} {tab.active_exe.split('/')[-1] if tab.active_exe not in ('-fish', 'kitten') else ''} {title.split('/')[-1] if '/' in title else title}{tab.last_focused_progress_percent}";
            active_tab_font_style = "bold";
            inactive_tab_font_style = "normal";
            active_tab_background = "#8aadf4";

            # Remote control
            allow_remote_control = "yes";
            listen_on = "unix:/tmp/mykitty";

            # Fonts
            # font_family = "JetBrains Mono";
            font_family = "Maple Mono";
            disable_ligatures = "cursor";

            font_size =
                if pkgs.stdenv.isDarwin
                then "12"
                else "9";
            modify_font = "cell_height 100%";

            scrollback_pager = "nvim -u NONE -R -M -c 'lua require(\"core.kitty_scrollback\")(INPUT_LINE_NUMBER, CURSOR_LINE, CURSOR_COLUMN)' -";
        };

        shellIntegration = {
            mode = "no-cursor";
            # enableFishIntegration = true;
            enableFishIntegration = true;
        };

        # Keybindings
        keybindings = {
            "ctrl+shift+-" = "launch --location=hsplit --cwd=current";
            "ctrl+shift+=" = "launch --location=vsplit --cwd=current";
            "f4" = "launch --location=split";
            "ctrl+alt+k" = "scroll_line_up";
            "ctrl+alt+j" = "scroll_line_down";
            "ctrl+alt+u" = "scroll_page_up";
            "ctrl+alt+d" = "scroll_page_down";
            "ctrl+shift+h" = "move_window left";
            "ctrl+shift+j" = "move_window down";
            "ctrl+shift+k" = "move_window up";
            "ctrl+shift+l" = "move_window right";
            "ctrl+j" = "kitten ~/dotfiles.nix/home/kitty/pass_keys.py bottom ctrl+j";
            "ctrl+k" = "kitten ~/dotfiles.nix/home/kitty/pass_keys.py top    ctrl+k";
            "ctrl+h" = "kitten ~/dotfiles.nix/home/kitty/pass_keys.py left   ctrl+h";
            "ctrl+l" = "kitten ~/dotfiles.nix/home/kitty/pass_keys.py right  ctrl+l";
            "ctrl+shift+left" = "resize_window wider 5";
            "ctrl+shift+right" = "resize_window narrower 5";
            "ctrl+shift+up" = "resize_window taller";
            "ctrl+shift+down" = "resize_window shorter";
            "ctrl+shift+x" = "show_scrollback";
        };

        # Extra configuration to ensure catpuccin theme is included
        extraConfig = ''
            include ${config.xdg.configHome}/kitty/themes/mocha.conf
        '';
    };

    xdg.configFile = {
        # Copy pass_keys.py
        "kitty/pass_keys.py".source = ./pass_keys.py;

        # This is needed for the neovim plugin. It expects the file in ~/.config/kitty/
        "kitty/navigate_kitty.py".source = ./navigate_kitty.py;

        # Copy ssh.conf
        "kitty/ssh.conf".source = ./ssh.conf;

        # Copy icon
        # "kitty/kitty.app.png".source = ./kitty.app.png;

        "kitty/themes/mocha.conf".source = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/kitty/refs/heads/main/themes/mocha.conf";
            hash = "sha256-kvzdAcM+ZCQ/u6S7avS4iHd2lDKwv/6GLPiN6A6QlSQ=";
        };
    };
}
