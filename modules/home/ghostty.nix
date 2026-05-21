_: {
  flake.homeManagerModules.ghostty = {
    pkgs,
    defaults,
    ...
  }: {
    programs = {
      ghostty = {
        enable = true;
        enableFishIntegration = true;
        installBatSyntax = true;
        installVimSyntax = true;
        package = pkgs.ghostty-bin;
        settings = {
          theme = "Catppuccin Mocha";
          font-family = "Maple Mono"; # Nerd Font not needed as ghostty has icons built in
          font-size = 13;
          background-opacity =
            if defaults.settings.transparent_terminal
            then 0.8
            else 1.0;
          # macos-glass-regular or macos-glass-clear
          background-blur = "macos-glass-regular";
          window-save-state = "always";
          unfocused-split-opacity = 0.9;
          macos-titlebar-proxy-icon = "hidden";
          notify-on-command-finish = "unfocused";
          macos-window-buttons = "hidden";
          mouse-hide-while-typing = true;
          macos-window-shadow = false;
          shell-integration = "fish";
          shell-integration-features = true;
          window-decoration = true;
          macos-option-as-alt = true;
          auto-update = "off";
          macos-titlebar-style = "tabs";
          keybind = [
            "global:ctrl+alt+cmd+s=toggle_quick_terminal"
            "ctrl+shift+up=resize_split:up,20"
            "ctrl+shift+down=resize_split:down,20"
            "ctrl+shift+left=resize_split:left,20"
            "ctrl+shift+right=resize_split:right,20"
            "ctrl+shift+equal=new_split:right"
            "ctrl+shift+minus=new_split:down"

            "ctrl+shift+enter=new_split:auto"
            "alt+k=goto_split:top"
            "alt+j=goto_split:bottom"
            "alt+h=goto_split:left"
            "alt+l=goto_split:right"
            "super+shift+i=inspector:toggle"
            "ctrl+shift+x=write_scrollback_file:open"
          ];
        };
      };
    };
  };
}
