_: {
  programs.niri.settings.window-rules = [
    {
      matches = [{app-id = "zen$";}];
      open-on-workspace = "1";
    }
    {
      matches = [{app-id = "org.wezfurlong.wezterm$";}];
      open-on-workspace = "2";
    }
    {
      matches = [{app-id = "jetbrains-idea$";}];
      open-on-workspace = "2";
    }
    # Space 3: Notes
    {
      matches = [{app-id = "obsidian$";}];
      open-on-workspace = "3";
    }
    # Space 4: Communication
    {
      matches = [{app-id = "vesktop$";}];
      open-on-workspace = "4";
    }
    # Space 5: Music
    {
      matches = [{app-id = "spotify$";}];
      open-on-workspace = "6";
    }
    # Space 6: Gaming
    {
      matches = [{app-id = "steam$";}];
      open-on-workspace = "6";
    }
    {
      matches = [{app-id = "steam_app_.*";}];
      open-on-workspace = "6";
    }
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
}
