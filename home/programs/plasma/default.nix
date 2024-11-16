{pkgs, ...}: {
  programs.plasma = {
    enable = !pkgs.stdenv.isDarwin;

    #
    # Some high-level settings:
    #
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      # Managed by stylix
      # cursor = {
      #   theme = "Breeze";
      #   size = 28;
      # };
      iconTheme = "Papirus-Dark";
      wallpaper = "/home/daniel/dotfiles/home/programs/plasma/wallpaper.jpg";
    };

    # Managed by stylix
    # fonts = {
    #   general = {
    #     family = "Noto Sans";
    #     pointSize = 11;
    #   };
    # };

    desktop.widgets = [
      # {
      #   plasmusicToolbar = {
      #     position = {
      #       horizontal = 51;
      #       vertical = 100;
      #     };
      #     size = {
      #       width = 250;
      #       height = 250;
      #     };
      #   };
      # }
    ];

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        hiding = "normalpanel";
        floating = true;
        widgets = [
          # We can configure the widgets by adding the name and config
          # attributes. For example to add the the kickoff widget and set the
          # icon to "nix-snowflake-white" use the below configuration. This will
          # add the "icon" key to the "General" group for the widget in
          # ~/.config/plasma-org.kde.plasma.desktop-appletsrc.
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General = {
                icon = "nix-snowflake-white";
                alphaSort = true;
              };
            };
          }
          # Adding configuration to the widgets can also for example be used to
          # pin apps to the task-manager, which this example illustrates by
          # pinning dolphin and konsole to the task-manager by default with widget-specific options.
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
          # If no configuration is needed, specifying only the name of the
          # widget will add them with the default configuration.
          "org.kde.plasma.marginsseparator"
          # If you need configuration for your widget, instead of specifying the
          # the keys and values directly using the config attribute as shown
          # above, plasma-manager also provides some higher-level interfaces for
          # configuring the widgets. See modules/widgets for supported widgets
          # and options for these widgets. The widgets below shows two examples
          # of usage, one where we add a digital clock, setting 12h time and
          # first day of the week to Sunday and another adding a systray with
          # some modifications in which entries to show.
          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
              time.format = "24h";
            };
          }
          {
            systemTray.items = {
              # We explicitly show bluetooth and battery
              shown = [
                "org.kde.plasma.bluetooth"
              ];
              # And explicitly hide networkmanagement and volume
              hidden = [
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
            };
          }
        ];
      }
    ];

    kscreenlocker = {
      lockOnResume = true;
      timeout = 10;
    };

    #
    # Some mid-level settings:
    #
    # shortcuts = {
    #   ksmserver = {
    #     "Lock Session" = [
    #       "Screensaver"
    #       "Meta+Ctrl+Alt+L"
    #     ];
    #   };
    #
    #   kwin = {
    #     "Expose" = "Meta+,";
    #     "Switch Window Down" = "Meta+J";
    #     "Switch Window Left" = "Meta+H";
    #     "Switch Window Right" = "Meta+L";
    #     "Switch Window Up" = "Meta+K";
    #   };
    # };

    #
    # Some low-level settings:
    #
    # configFile = {
    #   baloofilerc."Basic Settings"."Indexing-Enabled" = false;
    #   kwinrc.Desktops.Number = {
    #     value = 5;
    #     # Forces kde to not change this value (even through the settings app).
    #     immutable = true;
    #   };
    #   kscreenlockerrc = {
    #     Greeter.WallpaperPlugin = "org.kde.potd";
    #     # To use nested groups use / as a separator. In the below example,
    #     # Provider will be added to [Greeter][Wallpaper][org.kde.potd][General].
    #     "Greeter/Wallpaper/org.kde.potd/General".Provider = "bing";
    #   };
    # };
  };
}
