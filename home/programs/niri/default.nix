{pkgs, ...}: let
  makeCommand = command: {
    command = [command];
  };
in {
  xdg.configFile = {
    "swaync" = {
      source = ../hyprland/swaync;
      recursive = true;
    };
    "waybar" = {
      source = ../hyprland/waybar;
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

    niri = {
      package = pkgs.niri-unstable;
      settings = {
        prefer-no-csd = true;
        spawn-at-startup = [
          (makeCommand "waybar")
          (makeCommand "swww-daemon")
          (makeCommand "swaync")
          (makeCommand "swww img /home/daniel/dotfiles.nix/home/programs/plasma/wallpaper.png")
          (makeCommand "wl-paste --type text --watch cliphist store")
          (makeCommand "xwayland-satellite")
          (makeCommand "zen")
          (makeCommand "wezterm")
          (makeCommand "vesktop")
          (makeCommand "spotify")
          (makeCommand "solaar --battery-icons=regular --window=hide")
          (makeCommand "steam-runtime")
          (makeCommand "1password --silent")
          (makeCommand "ulauncher")
          (makeCommand "sunshine")
        ];
        binds = {
          "Mod+Space".action.spawn = "fuzzel";
          "Mod+Q".action.quit.skip-confirmation = true;
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
        };
        window-rules = [
          {
            geometry-corner-radius = let
              radius = 8.0;
            in {
              bottom-left = radius;
              bottom-right = radius;
              top-left = radius;
              top-right = radius;
            };
            clip-to-geometry = true;
            draw-border-with-background = false;
          }
        ];
        layout = {
          gaps = 8;
          border = {
            enable = true;
            width = 3;
          };
        };
        cursor.hide-when-typing = true;
      };
    };
  };

  services = {
    swaync = {
      enable = true;
    };
  };
}
