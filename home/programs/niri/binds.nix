_: {
  programs.niri.settings.binds = {
    # Audio controls
    "XF86AudioRaiseVolume".action.spawn = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
    "XF86AudioLowerVolume".action.spawn = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";

    # Application launcher
    "Mod+Space".action.spawn = "fuzzel";

    # Window management
    "Mod+Q".action.close-window = {}; # Close current window

    # Workspace navigation (1-9)
    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;

    # Move windows to workspaces (Shift+Mod+1-9)
    "Shift+Mod+1".action.move-column-to-workspace = 1;
    "Shift+Mod+2".action.move-column-to-workspace = 2;
    "Shift+Mod+3".action.move-column-to-workspace = 3;
    "Shift+Mod+4".action.move-column-to-workspace = 4;
    "Shift+Mod+5".action.move-column-to-workspace = 5;
    "Shift+Mod+6".action.move-column-to-workspace = 6;
    "Shift+Mod+7".action.move-column-to-workspace = 7;
    "Shift+Mod+8".action.move-column-to-workspace = 8;
    "Shift+Mod+9".action.move-column-to-workspace = 9;

    # Window movement with Alt+hjkl
    # "Alt+h".action.move-window = "left";
    # "Alt+j".action.move-window = "down";
    # "Alt+k".action.move-window = "up";
    # "Alt+l".action.move-window = "right";

    # Window swapping with Alt+Shift+hjkl
    # "Alt+Shift+h".action.swap-window-with = "left";
    # "Alt+Shift+j".action.swap-window-with = "down";
    # "Alt+Shift+k".action.swap-window-with = "up";
    # "Alt+Shift+l".action.swap-window-with = "right";

    # Window states
    # "Alt+t".action.set-window-layout = "tiles"; # Tiling mode
    # "Alt+s".action.set-window-layout = "stacked"; # Stacking mode
    # "Alt+f".action.toggle-fullscreen = {}; # Toggle fullscreen
    # "Alt+Shift+f".action.toggle-floating = {}; # Toggle floating
  };
}
