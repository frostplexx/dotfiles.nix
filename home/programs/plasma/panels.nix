{
  programs.plasma.panels = [
    # Windows-like panel at the bottom
    {
      location = "bottom";
      hiding = "normalpanel";
      floating = true;
      widgets = [
        {
          name = "org.kde.plasma.kickoff";
          config = {
            General = {
              icon = "nix-snowflake-white";
              alphaSort = true;
            };
          };
        }
        "org.kde.plasma.marginsseparator"
        {
          name = "org.kde.plasma.pager";
          config = {
            General = {
              displayedText = "Number";
              showWindowIcons = false;
            };
          };
        }
        {
          name = "org.kde.plasma.panelspacer";
        }
        {
          iconTasks = {
            launchers = [
              "applications:org.kde.dolphin.desktop"
              # "applications:firefox.desktop"
              "applications:zen.desktop"
              # "applications:kitty.desktop"
              "applications:ghostty.desktop"
              "applications:steam.desktop"
            ];
          };
        }
        {
          name = "org.kde.plasma.panelspacer";
        }
        "org.kde.plasma.marginsseparator"
        {
          systemTray.items = {
            shown = [
              "org.kde.plasma.bluetooth"
              "org.kde.plasma.networkmanagement"
            ];
            hidden = [
              "org.kde.plasma.volume"
              "org.kde.plasma.clipboard"
              "org.kde.plasma.brightness"
            ];
          };
        }
        {
          digitalClock = {
            calendar.firstDayOfWeek = "monday";
            time.format = "24h";
            # appearance = {
            #   showDate = false;
            #   fontScale = 0.8;
            # };
          };
        }
      ];
    }
  ];
}
