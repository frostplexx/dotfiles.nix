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

    "Mod+Tab".action.focus-workspace-previous = {};

    "Mod+BracketLeft".action.consume-or-expel-window-left = {};
    "Mod+BracketRight".action.consume-or-expel-window-right = {};

    # Window movement with Alt+hjkl
    "Alt+H".action.focus-column-left = {};
    "Alt+J".action.focus-window-or-workspace-down = {};
    "Alt+K".action.focus-window-or-workspace-up = {};
    "Alt+L".action.focus-column-right = {};

    # Window swapping with Alt+Shift+hjkl
    "Alt+Shift+H".action.move-column-left = {};
    "Alt+Shift+J".action.move-window-down-or-to-workspace-down = {};
    "Alt+Shift+K".action.move-window-up-or-to-workspace-up = {};
    "Alt+Shift+L".action.move-column-right = {};

    # Window states
    # "Alt+t".action.set-window-layout = "tiles"; # Tiling mode
    # "Alt+s".action.set-window-layout = "stacked"; # Stacking mode
    "Alt+f".action.fullscreen-window = {}; # Toggle fullscreen
    "Mod+R".action.switch-preset-column-width = {};
    "Mod+Shift+R".action.reset-window-height = {};

    # "Mod+Minus".action.set-column-width = "-10%";
    # "Mod+Plus".action.set-column-width = "+10%";
    # "Mod+Shift+Minus".action.set-column-height = "-10%";
    # "Mod+Shift+Plus".action.set-column-height = "+10%";

    "Ctrl+Shift+2".action.screenshot-window = {};
    # "Alt+Shift+f".action.toggle-floating = {}; # Toggle floating
  };
}
