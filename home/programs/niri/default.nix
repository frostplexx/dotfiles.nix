{pkgs, ...}: {
  imports = [./settings.nix ./binds.nix ./rules.nix ./gtk.nix];

  xdg.configFile = {
    "swaync" = {
      source = ./swaync;
      recursive = true;
    };
    "waybar" = {
      source = ./waybar;
      recursive = true;
    };
  };

  programs = {
    waybar = {
      enable = true;
    };

    fuzzel = {
      enable = true;
      settings = {
        colors = {
          background = "1e1e2edd";
          text = "cdd6f4ff";
          prompt = "bac2deff";
          placeholder = "7f849cff";
          input = "cdd6f4ff";
          match = "89b4faff";
          selection = "585b70ff";
          selection-text = "cdd6f4ff";
          selection-match = "89b4faff";
          counter = "7f849cff";
          border = "89b4faff";
        };
        main = {
          terminal = "${pkgs.wezterm}/bin/wezterm";
          layer = "overlay";
          font = "JetBrainsMono Nerd Font Propo";
        };
      };
    };
  };

  services = {
    swaync = {
      enable = true;
    };
  };

  home.sessionVariables = {
    DISPLAY = "DP-2";
  };
}
