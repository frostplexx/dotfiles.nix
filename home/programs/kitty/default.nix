{pkgs, ...}: {
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
      # background_opacity = "0.8";
      background_blur = "25";
      remember_window_size = "yes";
      initial_window_width = "640";
      initial_window_height = "400";
      confirm_os_window_close = "1";
      hide_window_decorations = "titlebar-only";
      enabled_layouts = "splits:split_axis=horizontal";

      # Titlebar
      wayland_titlebar_color = "background";

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = "-1";
      cursor_stop_blinking_after = "30.0";
      cursor_trail = "0";

      # Scrolling
      scrollback_lines = "10000";
      scrollback_indicator_opacity = "0.5";
      scrollback_pager = "nvim";

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
      tab_title_template = "{index} { tab.active_exe if tab.active_exe not in ('-zsh', 'kitten') else title}";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
      active_tab_background = "#8aadf4";

      # Remote control
      startup_session = "./startup.conf";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";
      remote_kitty = "if-needed";

      # Fonts
      font_family = "JetBrainsMono Nerd Font Mono";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      disable_ligatures = "cursor";

      # Set font size based on system because on linux wayland, font zise 13 is huge for some reason
      font_size =
        if pkgs.stdenv.isDarwin
        then "13"
        else "10";
      modify_font = "cell_height 100%";
    };

    # Keybindings
    keybindings = {
      "ctrl+shift+-" = "launch --location=hsplit --cwd=current";
      "ctrl+shift+=" = "launch --location=vsplit --cwd=current";
      "f4" = "launch --location=split";
      "f1" = "show_scrollback";
      "ctrl+alt+k" = "scroll_line_up";
      "ctrl+alt+j" = "scroll_line_down";
      "ctrl+alt+u" = "scroll_page_up";
      "ctrl+alt+d" = "scroll_page_down";
      "ctrl+shift+h" = "move_window left";
      "ctrl+shift+j" = "move_window down";
      "ctrl+shift+k" = "move_window up";
      "ctrl+shift+l" = "move_window right";
      "ctrl+j" = "kitten ~/dotfiles.nix/home/programs/kitty/pass_keys.py bottom ctrl+j";
      "ctrl+k" = "kitten ~/dotfiles.nix/home/programs/kitty/pass_keys.py top    ctrl+k";
      "ctrl+h" = "kitten ~/dotfiles.nix/home/programs/kitty/pass_keys.py left   ctrl+h";
      "ctrl+l" = "kitten ~/dotfiles.nix/home/programs/kitty/pass_keys.py right  ctrl+l";
      "ctrl+shift+left" = "resize_window wider 5";
      "ctrl+shift+right" = "resize_window narrower 5";
      "ctrl+shift+up" = "resize_window taller";
      "ctrl+shift+down" = "resize_window shorter";
      "ctrl+shift+x" = "close_window";
      "ctrl+shift+p" = "launch --title 'Project Selector' --copy-env --type=overlay zsh -il -c ~/.config/kitty/project_selector.sh";
    };

    # Extra configuration to ensure catpuccin theme is included
    # extraConfig = ''
    #   include ${config.xdg.configHome}/kitty/themes/catpuccin.conf
    # '';
  };

  xdg.configFile = {
    # Copy pass_keys.py
    "kitty/pass_keys.py".source = ./pass_keys.py;

    # Copy ssh.conf
    "kitty/ssh.conf".source = ./ssh.conf;

    # Copy theme

    # Copy icon
    "kitty/kitty.app.png".source = ./kitty.app.png;

    # If you have a project selector script
    "kitty/project_selector.sh".source = ./project_selector.sh;
  };
}
