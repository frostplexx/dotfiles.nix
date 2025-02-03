{
  config,
  pkgs,
  ...
}: let
  makeCommand = command: {
    command = [command];
  };
  pointer = config.home.pointerCursor;
in {
  programs.niri = {
    package = pkgs.niri-unstable;
    settings = {
      environment = {
        CLUTTER_BACKEND = "wayland";
        DISPLAY = ":0";
        GDK_BACKEND = "wayland,x11";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        SDL_VIDEODRIVER = "wayland";
      };
      prefer-no-csd = true;
      spawn-at-startup = [
        (makeCommand "waybar")
        (makeCommand "swww-daemon")
        (makeCommand "swaync")
        (makeCommand "swww img /home/daniel/dotfiles.nix/assets/wallpaper.png")
        (makeCommand "wl-paste --type image --watch cliphist store")
        (makeCommand "wl-paste --type text --watch cliphist store")
        (makeCommand "zen")
        (makeCommand "wezterm")
        (makeCommand "vesktop")
        (makeCommand "spotify")
        (makeCommand "solaar --battery-icons=regular --window=hide")
        # (makeCommand "steam-runtime")
        (makeCommand "1password --silent")
        (makeCommand "ulauncher")
        (makeCommand "sunshine")
      ];
      outputs = {
        "DP-2" = {
          mode = {
            refresh = 144.001;
            width = 2560;
            height = 1080;
          };
        };
      };
      cursor = {
        size = 20;
        theme = "${pointer.name}";
      };
      layout = {
        gaps = 8;
        focus-ring.enable = false;
        always-center-single-column = true;
        border = {
          enable = true;
          width = 1;
          active.color = "rgb(137 180 250)";
          inactive.color = "rgb(127 132 156)";
        };
      };
      cursor.hide-when-typing = true;
    };
  };
}
