{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./decorations.nix
    ./panels.nix
    ./rounded-corners.nix
  ];

  gtk = {
    enable = true;

    theme = {
      package = pkgs.rose-pine-gtk-theme;
      name = "Rosé Pine";
    };

    cursorTheme = {
      name = "BreezeX-RoséPine";
      package = pkgs.rose-pine-cursor;
      size = 28;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    gtk2.extraConfig = ''
      gtk-xft-dpi = 96
    '';
    gtk3.extraConfig = {
      gtk-xft-dpi = 96;
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-xft-dpi = 96;
    };
  };

  home.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
  };

  programs.plasma = {
    enable = true;
    #
    # Some high-level settings:
    #
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "BreezeX-RoséPine";
      cursor.theme = "Phinger Cursors (dark)";
      wallpaper = "/home/daniel/dotfiles.nix/assets/wallpaper.png";
    };

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

        Plugins = {
          kwin4_effect_geometry_changeEnabled = true;
          roundedcornersEnabled = true;
          kwin4_effect_shapecornersEnabled.value = true;
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

      # Window decoration settings
      kwinrulesrc = {
        "Windows" = {
          BorderSize = "Normal";
          BorderSizeAuto = false;
        };
        "org.kde.kdecoration2" = {
          ButtonsOnLeft = "XIA";
          ButtonsOnRight = "";
          library = "org.kde.kwin.aurorae";
          theme = "kwin4_decoration_qml_plastik";
        };
      };
    };
  };

  home.file = {
    ".local/share/color-schemes/rose-pine.colors".text = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/ashbork/kde/refs/heads/main/Rose%20Pine/colorschemes/rose-pine.colors";
      sha256 = "sha256-Jt0gt8fMtlWCGCO5gr3q5RWC/mOK+OyXW5trnF/LwnI=";
    };
  };
}
