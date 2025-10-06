# Configuration for Lyra MacBook
{
  pkgs,
  user,
  lib,
  ...
}: {
  imports = [
    ../shared.nix # Base configuration
    ./apps.nix # macbook-pro-m1 specific apps
    # ./custom_icons.nix
    # ./smb_automount.nix
  ];

  services.lazykeys = {
    enable = true;
    normalQuickPress = true; # Quick press of Caps Lock will send Escape
    includeShift = false; # Hyper key will be Cmd+Ctrl+Alt (without Shift)
    mode = "custom";
    customKey = "escape";
  };

  # services.smbAutoMount = {
  #   enable = true;
  #   autoSetup = true;
  #
  #   mounts = {
  #     "/Volumes/backup" = {
  #       share = "//u397529:tusRp8vxZAnJwwj2@u397529.your-storagebox.de/backup";
  #       options = [ "rw" "soft" "noowners" "nosuid" ];
  #       sidebarName = "Storage Box Backup";
  #     };
  #
  #     # Add more mounts as needed
  #     # "/Volumes/another-share" = {
  #     #   share = "//user:pass@server.com/share";
  #     #   options = [ "rw" "soft" "noowners" "nosuid" ];
  #     #   sidebarName = "Another Server";
  #     # };
  #   };
  # };

  programs.opsops.enable = true;

  # Basic system configuration
  networking = {
    hostName = "macbook-pro-m1";
    computerName = "macbook-pro-m1";
    dns = [
      "9.9.9.10"
    ];
    knownNetworkServices = [
      "Wi-Fi"
      "Ethernet Adaptor"
      "Thunderbolt Ethernet"
    ];
  };
  time.timeZone = "Europe/Berlin";

  # Security settings
  security.pam.services.sudo_local.touchIdAuth = true;

  # You can enable the fish shell and manage fish configuration and plugins with Home Manager, but to enable vendor fish completions provided by Nixpkgs you
  # will also want to enable the fish shell in /etc/nixos/configuration.nix:
  programs.fish.enable = true;

  # Add ~/.local/bin to PATH
  environment = {
    # https://github.com/nix-community/home-manager/pull/2408
    pathsToLink = ["/share/fish"];
    shells = [pkgs.fish];
  };
  # User configuration
  users = {
    users.${user} = {
      home = "/Users/${user}";
      description = user;
      shell = pkgs.fish;
      uid = 501;
    };
    # https://github.com/nix-darwin/nix-darwin/issues/1237#issuecomment-2562230471
    knownUsers = [user];
  };

  # System defaults and preferences
  system = {
    primaryUser = user;
    startup.chime = false;

    # Post-activation scripts
    activationScripts = {
      postActivation = let
        # Convert hex color to Apple's 0-1 RGBA format
        hexToAppleRGBA = hex: let
          # Remove # if present
          cleanHex = lib.removePrefix "#" hex;
          # Extract RGB components
          r = lib.fromHexString (builtins.substring 0 2 cleanHex);
          g = lib.fromHexString (builtins.substring 2 2 cleanHex);
          b = lib.fromHexString (builtins.substring 4 2 cleanHex);
          # Convert to 0-1 range
          rNorm = r / 255.0;
          gNorm = g / 255.0;
          bNorm = b / 255.0;
        in "${builtins.toString rNorm} ${builtins.toString gNorm} ${builtins.toString bNorm} 1.000000";

        # Get highlight color from stylix or use fallback
        highlightColor = "#cba6f7";
        appleHighlightColor = hexToAppleRGBA highlightColor;
      in {
        text = ''
          echo "Running activate settings..."

          # Run defaults commands as the user, not root
          sudo -u ${user} defaults write "Apple Global Domain" com.apple.mouse.linear -bool true
          sudo -u ${user} defaults write "Apple Global Domain" "com.apple.mouse.scaling" -string "0.875"

          # Disable transparent menubar
          sudo -u ${user} defaults write "Apple Global Domain" SLSMenuBarUseBlurredAppearance -bool true

          # Other for custom color or nothing
          sudo -u ${user} defaults write "Apple Global Domain" AppleIconAppearanceTintColor Other

          # can be either TintedDark, TintedLight, RegularLight, RegularDark, ClearDark, ClearLight or empty for automatic colors
          sudo -u ${user} defaults write "Apple Global Domain" AppleIconAppearanceTheme RegularDark

          # Affects Icons, Folders and widgets. Needs to have AppleIconAppearanceTintColor set to Other
          # Color is rgba value divided by 256 so its between 0 and 1
          sudo -u ${user} defaults write "Apple Global Domain" AppleIconAppearanceCustomTintColor -string "${appleHighlightColor}"

          # Set highlight color
          sudo -u ${user} defaults write "Apple Global Domain" AppleHighlightColor -string "${appleHighlightColor} Other"

          # No idea what it does
          sudo -u ${user} defaults write "com.apple.Appearance-Settings.extension" AppleOtherHighlightColor -string "${appleHighlightColor}"

          sudo -u ${user} launchctl setenv CHROME_HEADLESS 1

          killall Finder;
          killall Dock;

        '';
      };
    };

    defaults = {
      smb.NetBIOSName = "macbook-pro-m1";
      # Menu bar clock settings
      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 2;
        ShowDayOfMonth = false;
        ShowDayOfWeek = false;
      };

      # Mouse settings
      ".GlobalPreferences"."com.apple.mouse.scaling" = 0.875;

      hitoolbox.AppleFnUsageType = "Do Nothing";

      # Global system preferences
      NSGlobalDomain = {
        # Window behavior
        NSWindowShouldDragOnGesture = true;
        NSAutomaticWindowAnimationsEnabled = true;
        NSWindowResizeTime = 0.001;

        # Keyboard settings
        KeyRepeat = 2;
        InitialKeyRepeat = 12;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;

        # Interface preferences
        AppleShowAllExtensions = true;
        _HIHideMenuBar = true;
        AppleICUForce24HourTime = true;
        NSAutomaticCapitalizationEnabled = false;

        AppleInterfaceStyleSwitchesAutomatically = false;
        AppleInterfaceStyle = "Dark";

        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";

        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = true;

        # File dialogs
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Font rendering
        AppleFontSmoothing = 1;

        "com.apple.sound.beep.feedback" = 0;
      };

      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = true;
      };

      # Finder preferences
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = false;
        FXEnableExtensionChangeWarning = false;
        _FXSortFoldersFirst = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
      };

      # Dock settings
      dock = {
        # Hot corners
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;

        # Appearance
        tilesize = 45;
        mineffect = "scale";
        show-recents = false;

        # Behavior
        expose-group-apps = true;
        mru-spaces = false;
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.4;

        # Pinned apps
        persistent-apps = [
          "/Applications/Things3.app"
          # "/Applications/Ghostty.app/"
          # "/Applications/kitty.app/"
          "/Applications/Zen.app/"
          # "/Applications/Firefox.app"
          # "/Applications/Safari.app"
          # "${pkgs.kitty}/Applications/kitty.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
        ];
      };

      # Other system settings
      trackpad.FirstClickThreshold = 0;
      WindowManager = {
        AutoHide = true;
        EnableStandardClickToShowDesktop = false;
        EnableTilingByEdgeDrag = false;
        HideDesktop = true;
        StageManagerHideWidgets = true;
      };
      spaces.spans-displays = false;
      ActivityMonitor.IconType = 6;

      # Login window settings
      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
        autoLoginUser = user;
      };

      controlcenter = {
        AirDrop = false;
        Bluetooth = false;
        NowPlaying = false;
        BatteryShowPercentage = false;
      };

      # Additional user preferences
      CustomUserPreferences = {
        NSGlobalDomain.WebKitDeveloperExtras = true;

        # Turn on app auto-update
        "com.apple.commerce".AutoUpdate = true;

        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };

        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 1;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };

        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          ShowTabView = false;
          FXPreferredViewStyle = "Nlsv";
          FXDefaultSearchScope = "SCcf"; # Search current folder by default
          NewWindowTargetPath = "file:///Users/${user}/Downloads";
        };

        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };
      };
    };
  };
}
