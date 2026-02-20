_: {
  flake.modules.homeManager.hyprland =
    {
      inputs,
      pkgs,
      lib,
      ...
    }:
    let
      accent_color = "cba6f7";
    in
    {
      wayland.windowManager.hyprland = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        xwayland.enable = true;
        systemd.enable = true;
        settings = {
          "$mod" = "SUPER";

          monitor = "DP-1, 2560x1080@144, 0x0, 1";

          input = {
            follow_mouse = 1;
            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
            accel_profile = "flat";
          };

          general = {
            gaps_in = 5;
            gaps_out = 5;
            border_size = 5;
            "decoration.rounding" = 10;
            layout = "dwindle";
          };

          decoration = {
            active_opacity = 1.0;
            inactive_opacity = 0.9;
            fullscreen_opacity = 1.0;
          };

          bind = [
            # keybindings
            "$mod, Return, exec, kitty"
            "$mod, d, exec, rofi -show drun"

            # Launch apps
            "SUPER CTRL ALT, d, exec, discord"
            "SUPER CTRL ALT, m, exec, tidal"
            "SUPER CTRL ALT, t, exec, kitty"
            "SUPER CTRL ALT, b, exec, zen"

            # Focus windows (hjkl)
            "SUPER CTRL ALT, h, movefocus, l"
            "SUPER CTRL ALT, j, movefocus, d"
            "SUPER CTRL ALT, k, movefocus, u"
            "SUPER CTRL ALT, l, movefocus, r"

            # Fullscreen
            "SUPER CTRL ALT, space, fullscreen"

            # Minimize
            "SUPER, m, minimize"

            # Switch to workspace
            "SUPER CTRL ALT, 1, workspace, 1"
            "SUPER CTRL ALT, 2, workspace, 2"
            "SUPER CTRL ALT, 3, workspace, 3"
            "SUPER CTRL ALT, 4, workspace, 4"
            "SUPER CTRL ALT, 5, workspace, 5"
            "SUPER CTRL ALT, 6, workspace, 6"

            # Move window to workspace and follow
            "SUPER CTRL ALT SHIFT, 1, movetoworkspace, 1"
            "SUPER CTRL ALT SHIFT, 2, movetoworkspace, 2"
            "SUPER CTRL ALT SHIFT, 3, movetoworkspace, 3"
            "SUPER CTRL ALT SHIFT, 4, movetoworkspace, 4"
            "SUPER CTRL ALT SHIFT, 5, movetoworkspace, 5"
            "SUPER CTRL ALT SHIFT, 6, movetoworkspace, 6"

            # Move windows (swap)
            "SUPER CTRL ALT SHIFT, h, movewindow, l"
            "SUPER CTRL ALT SHIFT, j, movewindow, d"
            "SUPER CTRL ALT SHIFT, k, movewindow, u"
            "SUPER CTRL ALT SHIFT, l, movewindow, r"

            # Toggle float
            "SUPER CTRL ALT, f, togglefloating"

            # Focus back and forth
            "ALT, tab, cyclenext"
            "ALT SHIFT, tab, cyclenext, prev"

            # Enter resize mode
            "SUPER CTRL ALT, r, submap, resize"
          ];

          bindl = [
            # Resize mode bindings
            # "submap:resize, h, resizeactive, -20 0"
            # "submap:resize, j, resizeactive, 0 20"
            # "submap:resize, k, resizeactive, 0 -20"
            # "submap:resize, l, resizeactive, 20 0"
            # "submap:resize, escape, submap, reset"
            # "submap:resize, Return, submap, reset"
          ];

          bindm = [
            # mouse movements
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
            "$mod ALT, mouse:272, resizewindow"
          ];

          windowrulev2 = [
            # Floating rules
            "title:^(Picture(-| )in(-| )Picture|PiP)$, floating, oncreatedr:1"
            "subrole:^AXSystemDialog$, floating, oncreatedr:1"
            "title:^kittyfloat$, floating, oncreatedr:1"
            "title:^MiniPlayer$, floating, oncreatedr:1"

            # Browser apps -> Workspace 1
            "app:^Firefox$, workspace: 1"
            "app:^Zen$, workspace: 1"

            # Development apps -> Workspace 2
            "app:^(IntelliJ IDEA|WezTerm|Ghostty|Termius|kitty)$, workspace: 2"

            # Productivity apps -> Workspace 3
            "app:^(GoodNotes|Obsidian|Things)$, workspace: 3"

            # Communication apps -> Workspace 4
            "app:^(Vesktop|zoom.us|Discord|Mail)$, workspace: 4"

            # Music -> Workspace 5
            "app:^(Spotify|Music|TIDAL)$, workspace: 5"
          ];

          workspace = [
            "1, persistent:true, monitor:DP-1, default:true"
            "2, persistent:true, monitor:DP-1"
            "3, persistent:true, monitor:DP-1"
            "4, persistent:true, monitor:DP-1"
            "5, persistent:true, monitor:DP-1"
            "6, persistent:true, monitor:DP-1"
          ];
        };

        extraConfig = ''
          env = NIXOS_OZONE_WL, 1
          env = NIXPKGS_ALLOW_UNFREE, 1
          env = XDG_CURRENT_DESKTOP, Hyprland
          env = XDG_SESSION_TYPE, wayland
          env = XDG_SESSION_DESKTOP, Hyprland
          env = GDK_BACKEND, wayland
          env = CLUTTER_BACKEND, wayland
          env = QT_QPA_PLATFORM, wayland
          env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
          env = QT_AUTO_SCREEN_SCALE_FACTOR, 1
          env = WLR_NO_HARDWARE_CURSORS,1
          env = MOZ_ENABLE_WAYLAND, 1
        '';
      };
    };
}
