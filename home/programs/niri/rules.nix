_: {
  programs.niri.settings.window-rules = [
    {
      matches = [{app-id = "zen$";}];
      open-on-workspace = "browse";
    }
    {
      matches = [{app-id = "org.wezfurlong.wezterm$";}];
      open-on-workspace = "dev";
    }
    {
      matches = [{app-id = "jetbrains-idea$";}];
      open-on-workspace = "dev";
    }
    # Space 3: Notes
    {
      matches = [{app-id = "obsidian$";}];
      open-on-workspace = "write";
    }
    # Space 4: Communication
    {
      matches = [{app-id = "vesktop$";}];
      open-on-workspace = "chat";
    }
    # Space 5: Music
    {
      matches = [{app-id = "spotify$";}];
      open-on-workspace = "music";
      open-maximized = true;
    }
    # Space 6: Gaming
    {
      matches = [{app-id = "steam$";}];
      open-on-workspace = "game";
    }
    {
      matches = [{app-id = "steam_app_.*";}];
      open-on-workspace = "game";
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
