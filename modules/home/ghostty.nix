_: {
  flake.homeManagerModules.ghostty = {
    defaults,
    pkgs,
    inputs,
    ...
  }: {
    programs = {
      ghostty = {
        enable = true;
        enableFishIntegration = true;
        # installBatSyntax = true;
        # installVimSyntax = true;
        # package = pkgs.ghostty-bin;
        package =
          if pkgs.stdenv.hostPlatform.isDarwin
          then inputs.nixkit.packages.${pkgs.system}.ghostty-tip
          else pkgs.ghostty;
        settings = {
          theme =
            {
              "catppuccin" = "Catppuccin Mocha";
              "rose-pine" = "Rose Pine Moon";
            }
              .${
              defaults.settings.theme
            };
          font-family = "Maple Mono NF";
          font-size = 13;
          background-opacity =
            if defaults.settings.transparent_terminal
            then 0.8
            else 1.0;
          # macos-glass-regular or macos-glass-clear
          background-blur =
            if defaults.settings.transparent_terminal
            then "macos-glass-regular"
            else false;
          window-save-state = "always";
          unfocused-split-opacity = 0.9;
          notify-on-command-finish-action = "bell,notify";
          bell-features = "system,title";
          adjust-cell-height = "3%";
          window-padding-x = 0;
          window-padding-y = 0;
          macos-titlebar-proxy-icon = "hidden";
          notify-on-command-finish = "unfocused";
          macos-window-buttons = "hidden";
          mouse-hide-while-typing = true;
          macos-window-shadow = false;
          window-decoration = true;
          macos-option-as-alt = true;
          custom-shader = "shaders/cursor_warp.glsl";
          auto-update = "off";
          macos-titlebar-style = "tabs";
          keybind = [
            "global:ctrl+alt+cmd+s=toggle_quick_terminal"
            "performable:cmd+p=text:p\n"
            "ctrl+shift+enter=new_split:auto"
            "alt+k=goto_split:top"
            "alt+j=goto_split:bottom"
            "alt+h=goto_split:left"
            "alt+l=goto_split:right"
            "ctrl+shift+x=write_scrollback_file:open"
            "global:ctrl+grave_accent=toggle_quick_terminal"
          ];
        };
      };
    };
  };
}
