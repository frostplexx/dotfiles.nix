_: {
  flake.modules.homeManager.ghostty = {pkgs, ...}: {
    programs = {
      ghostty = {
        enable = true;
        enableFishIntegration = true;
        installBatSyntax = true;
        installVimSyntax = true;
        package = pkgs.ghostty-bin;
        settings = {
          theme = "Catppuccin Mocha";
          font-family = "Maple Mono";
          font-size = 12;
          background-opacity = 0.9;
          background-blur-radius = 20;
          unfocused-split-opacity = 0.9;
          mouse-hide-while-typing = true;
          window-decoration = true;
          macos-option-as-alt = true;
          term = "xterm-256color";
          auto-update = "off";
          macos-titlebar-style = "tabs";
          keybind = [
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

      zellij = {
        enable = false;
        enableFishIntegration = true;
        settings = {
          theme = "catppuccin-macchiato";
        };
      };
    };
  };
}
