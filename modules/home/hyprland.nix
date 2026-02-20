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
            "col.active_border" = "rgba(${accent_color}ff) rgba(cba6f7ff) 45deg";
            "col.inactive_border" = "rgba(7f849cff)";
          };

          bind = [
            # keybindings
            "$mod, Return, exec, kitty"
            "$mod, d, exec, rofi -show drun"
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
      };
    };
}
