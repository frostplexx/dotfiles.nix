_: {
  flake.modules.homeManager.kitty = {
    pkgs,
    config,
    ...
  }: let
    accent_color = "cba6f7";
    transparent_terminal = false;
  in {
    programs.kitty = {
      enable = true;

      settings = {
        url_color = "#${accent_color}";
        term = "xterm-256color";
        editor = "nvim";
        shell_integration = "enabled";
        window_padding_width = "2 2";
        draw_minimal_borders = "yes";
        background_opacity =
          if transparent_terminal
          then "0.9"
          else "1.0";
        background_blur = "25";
        remember_window_size = "yes";
        initial_window_width = 1280;
        initial_window_height = 800;
        confirm_os_window_close = "1";
        hide_window_decorations = "titlebar-only";
        enabled_layouts = "splits:split_axis=horizontal";
        macos_option_as_alt = "both";
        wayland_titlebar_color = "background";
        cursor_shape = "block";
        cursor_blink_interval = "-1";
        cursor_stop_blinking_after = "30.0";
        scrollback_lines = "10000";
        scrollback_indicator_opacity = "0.5";
        copy_on_select = "clipboard";
        strip_trailing_spaces = "smart";
        undercurl_style = "thin-dense";
        url_style = "curly";
        show_hyperlink_targets = "yes";
        mouse_hide_wait = "1.0";
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{index} {tab.active_exe.split('/')[-1] if tab.active_exe not in ('-fish', 'kitten') else ''} {title.split('/')[-1] if '/' in title else title}{tab.last_focused_progress_percent}";
        active_tab_font_style = "bold";
        inactive_tab_font_style = "normal";
        active_tab_background = "#${accent_color}";
        allow_remote_control = "yes";
        startup_session = "${config.xdg.configHome}/kitty/saved-session.kitty";
        watcher = "${config.xdg.configHome}/kitty/watcher.py";
        listen_on = "unix:/tmp/mykitty";
        font_family = "Maple Mono";
        disable_ligatures = "cursor";
        font_size =
          if pkgs.stdenv.isDarwin
          then "12"
          else "9";
        modify_font = "cell_height 100%";
        scrollback_pager = "nvim -u NONE -R -M -c 'lua require(\"core.kitty_scrollback\")(INPUT_LINE_NUMBER, CURSOR_LINE, CURSOR_COLUMN)' -";
      };

      quickAccessTerminalConfig = {
        start_as_hidden = true;
        hide_on_focus_loss = false;
        background_opacity = 0.85;
      };

      shellIntegration = {
        mode = "no-cursor";
        enableFishIntegration = true;
      };

      enableGitIntegration = true;

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
        "ctrl+j" = "neighboring_window down";
        "ctrl+k" = "neighboring_window up";
        "ctrl+h" = "neighboring_window left";
        "ctrl+l" = "neighboring_window right";
        "alt+j" = "kitten relative_resize.py down  3";
        "alt+k" = "kitten relative_resize.py up    3";
        "alt+h" = "kitten relative_resize.py left  3";
        "alt+l" = "kitten relative_resize.py right 3";
        "ctrl+shift+x" = "show_scrollback";
        "shift+enter" = "send_text normal,application \\n";
      };

      extraConfig = ''
        include ${config.xdg.configHome}/kitty/themes/mocha.conf

        map --when-focus-on var:IS_NVIM ctrl+j
        map --when-focus-on var:IS_NVIM ctrl+k
        map --when-focus-on var:IS_NVIM ctrl+h
        map --when-focus-on var:IS_NVIM ctrl+l

        map --when-focus-on var:IS_NVIM alt+j
        map --when-focus-on var:IS_NVIM alt+k
        map --when-focus-on var:IS_NVIM alt+h
        map --when-focus-on var:IS_NVIM alt+l
      '';
    };

    xdg.configFile = {
      # Watcher for auto-saving sessions
      "kitty/watcher.py".text = ''
        from typing import Any
        import os


        from kitty.boss import Boss
        from kitty.session import default_save_as_session_opts, save_as_session_part2
        from kitty.window import Window

        _CONFIG_HOME = os.getenv("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))

        SESSION = os.path.join(_CONFIG_HOME, "kitty/saved-session.kitty")


        def _save_as_session(boss: Boss, window: Window, data: dict[str, Any]) -> None:
            opts = default_save_as_session_opts()
            opts.save_only = True
            opts.use_foreground_process = True
            save_as_session_part2(boss, opts, SESSION)


        def on_focus_change(boss: Boss, window: Window, data: dict[str, Any])-> None:
            _save_as_session(boss, window, data)


        def on_title_change(boss: Boss, window: Window, data: dict[str, Any])-> None:
            _save_as_session(boss, window, data)
      '';

      "kitty/themes/mocha.conf".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/kitty/refs/heads/main/themes/mocha.conf";
        hash = "sha256-cWrJfNVCuuT/NbU8qYCq5PAB4MS8WcT74AMBm+IO+c0=";
      };
    };
  };
}
