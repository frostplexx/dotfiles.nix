{pkgs, ...}: {
  programs.plasma = {
    enable = !pkgs.stdenv.isDarwin;
    #
    # Some high-level settings:
    #
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Papirus-Dark";
      wallpaper = "/home/daniel/dotfiles/home/programs/plasma/wallpaper.jpg";
    };
    panels = [
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
                "applications:firefox.desktop"
                "applications:kitty.desktop"
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

    shortcuts = {
      krunner = {
        "_launch" = "Meta+Space";
      };
      plasmashell = {
        "Activate Task Manager Entry 1" = "";
        "Activate Task Manager Entry 2" = "";
        "Activate Task Manager Entry 3" = "";
        "Activate Task Manager Entry 4" = "";
        "Activate Task Manager Entry 5" = "";
        "Activate Task Manager Entry 6" = "";
        "Activate Task Manager Entry 7" = "";
        "Activate Task Manager Entry 8" = "";
        "Activate Task Manager Entry 9" = "";
        "Activate Task Manager Entry 10" = "";
      };

      kwin = {
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";
      };
    };

    kscreenlocker = {
      lockOnResume = true;
      timeout = 10;
    };
    #
    # Some low-level settings:
    #
    configFile = {
      # Add Dolphin settings
      dolphinrc = {
        "General".ShowHiddenFiles = true;
        "KDE".SingleClick = false;
      };
      # Disable all hot corners
      kwinrc = {
        "ElectricBorders" = {
          Bottom = "None";
          BottomLeft = "None";
          BottomRight = "None";
          Left = "None";
          Right = "None";
          Top = "None";
          TopLeft = "None";
          TopRight = "None";
        };
        Desktops.Number = {
          value = 5;
          # Forces kde to not change this value (even through the settings app).
          immutable = true;
        };
      };
      kscreenlockerrc = {
        Greeter.WallpaperPlugin = "org.kde.potd";
        # To use nested groups use / as a separator. In the below example,
        # Provider will be added to [Greeter][Wallpaper][org.kde.potd][General].
        "Greeter/Wallpaper/org.kde.potd/General".Provider = "bing";
      };
    };
  };
}
