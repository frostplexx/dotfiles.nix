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
        main = {
          terminal = "${pkgs.wezterm}/bin/wezterm";
          layer = "overlay";
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
