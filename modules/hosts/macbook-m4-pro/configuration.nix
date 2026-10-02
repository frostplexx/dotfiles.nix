{
  inputs,
  lib,
  ...
}: {
  flake.darwinModules.macbook-m4-pro = {
    pkgs,
    defaults,
    config,
    ...
  }: let
    inherit (defaults) user;

    hexToAppleRGBA = hex: let
      cleanHex = lib.removePrefix "#" hex;
      r = lib.fromHexString (builtins.substring 0 2 cleanHex);
      g = lib.fromHexString (builtins.substring 2 2 cleanHex);
      b = lib.fromHexString (builtins.substring 4 2 cleanHex);
      rNorm = r / 255.0;
      gNorm = g / 255.0;
      bNorm = b / 255.0;
    in "${builtins.toString rNorm} ${builtins.toString gNorm} ${builtins.toString bNorm} 1.000000";
    appleHighlightColor = hexToAppleRGBA "#${defaults.settings.accent_color}";

    # Dock > Options > "Assign To", ported from agate-wm's docked layout.
    # Desktops are addressed by position and resolved to Space UUIDs on each
    # activation (see space-bindings.py), so this survives recreated Spaces.
    spaceBindings = let
      on = display: space: {inherit display space;};
    in {
      "app.zen-browser.zen" = on "external" 1; # web
      "com.mitchellh.ghostty" = on "external" 2; # term
      "md.obsidian" = on "external" 3; # notes
      "com.culturedcode.ThingsMac" = on "builtin" 1; # tasks
      "com.apple.mail" = on "builtin" 2; # mail
      "dev.vencord.vesktop" = on "builtin" 2; # comms
      "com.spotify.client" = on "builtin" 3; # music
      "org.jeffvli.feishin" = on "builtin" 3; # music
      "com.tidal.desktop" = on "builtin" 3; # music
    };
  in {
    system.stateVersion = defaults.system.darwinVersion;

    # Determinate Nix settings
    determinateNix.customSettings =
      defaults.nixSettings
      // {
        extra-trusted-users = ["root" user];
        # Build x86_64-linux closures on sorbet; this Mac is arm64.
        builders = "ssh-ng://root@192.168.0.85 x86_64-linux - 4 2";
      };

    # Nix-homebrew configuration
    nix-homebrew = {
      enable = true;
      enableRosetta = false;
      inherit user;
      mutableTaps = false;
      autoMigrate = true;
      taps = with inputs; {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
        "macos-fuse-t/homebrew-cask" = fuse-t;
      };
    };

    programs = {
      opsops.enable = true;
      _1password.enable = true;
      _1password-gui = {
        enable = true;
      };
    };

    # Networking
    networking = {
      hostName = "macbook-m4-pro";
      computerName = "macbook-m4-pro";
      dns = [
        "192.168.0.85"
        "45.90.28.61"
        "45.90.30.61"
      ];
      knownNetworkServices = [
        "Wi-Fi"
        "Thunderbolt Bridge"
      ];
    };

    time.timeZone = defaults.system.timeZone;

    # Security settings
    security.pam.services.sudo_local = {
      touchIdAuth = true;
      watchIdAuth = true;
    };

    # Fish shell
    programs.fish = {
      enable = true;
      useBabelfish = true;
    };

    environment = {
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
      knownUsers = [user];
    };

    power = {
      sleep = {
        computer = 10;
        display = 5;
      };
    };

    # System defaults
    system = {
      primaryUser = user;
      startup.chime = false;

      activationScripts = {
        postActivation = let
          script =
            /*
            bash
            */
            ''
              sudo -u ${user} launchctl setenv CHROME_HEADLESS 1

              sudo -u ${user} defaults -currentHost write com.apple.screensaver 'CleanExit' -string "YES"
              sudo -u ${user} defaults -currentHost write com.apple.screensaver 'PrefsVersion' -int "100"
              sudo -u ${user} defaults -currentHost write com.apple.screensaver 'idleTime' -int '180'

              sudo -u ${user} /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "${defaults.settings.wallpaper}"'

              # Set default list view settings for new folders. Uses -dict-add so
              # the other FK_StandardViewSettings subkeys are left intact, which
              # CustomUserPreferences (whole-key writes) can't do.
              sudo -u ${user} defaults write com.apple.finder FK_StandardViewSettings -dict-add ListViewSettings '{ "columns" = ( { "ascending" = 1; "identifier" = "name"; "visible" = 1; "width" = 300; }, { "ascending" = 0; "identifier" = "dateModified"; "visible" = 1; "width" = 181; }, { "ascending" = 0; "identifier" = "size"; "visible" = 1; "width" = 97; } ); "iconSize" = 16; "showIconPreview" = 0; "sortColumn" = "name"; "textSize" = 12; "useRelativeDates" = 1; }'
              sudo -u ${user} defaults write com.apple.finder FK_StandardViewSettings -dict-add ExtendedListViewSettings '{ "columns" = ( { "ascending" = 1; "identifier" = "name"; "visible" = 1; "width" = 300; }, { "ascending" = 0; "identifier" = "dateModified"; "visible" = 1; "width" = 181; }, { "ascending" = 0; "identifier" = "size"; "visible" = 1; "width" = 97; } ); "iconSize" = 16; "showIconPreview" = 0; "sortColumn" = "name"; "textSize" = 12; "useRelativeDates" = 1; }'

              # ApplePressAndHold: delete global key so per-app overrides take effect.
              # If the global key exists (even as true), it shadows all per-app values.
              # The per-app values live in CustomUserPreferences below.
              sudo -u ${user} defaults delete -g ApplePressAndHoldEnabled 2>/dev/null || true

              # Restarts the Dock itself when the resolved bindings change.
              sudo -u ${user} ${pkgs.python3}/bin/python3 ${./space-bindings.py} ${lib.escapeShellArg (builtins.toJSON spaceBindings)} || true
            '';

          # Only restart Finder/Dock when the settings they read actually changed,
          # instead of on every switch.
          settingsHash = builtins.hashString "sha256" (script
            + builtins.toJSON {
              inherit (config.system.defaults) dock finder CustomUserPreferences;
            });
          stamp = "/var/db/nix-darwin-defaults.hash";
        in {
          enable = true;
          text = ''
            ${script}
            if [ "$(cat ${stamp} 2>/dev/null)" != "${settingsHash}" ]; then
              killall Finder Dock 2>/dev/null || true
              echo "${settingsHash}" > ${stamp}
            fi
          '';
        };
      };

      defaults = {
        smb.NetBIOSName = "macbook-m4-pro";
        menuExtraClock = {
          Show24Hour = true;
          ShowDate = 2;
          ShowDayOfMonth = false;
          ShowDayOfWeek = false;
        };
        ".GlobalPreferences"."com.apple.mouse.scaling" = 0.875;
        hitoolbox.AppleFnUsageType = "Do Nothing";
        screensaver = {
          askForPassword = true;
          askForPasswordDelay = 5;
        };
        NSGlobalDomain = {
          AppleSpacesSwitchOnActivate = false;
          NSWindowShouldDragOnGesture = true;
          NSAutomaticWindowAnimationsEnabled = true;
          NSWindowResizeTime = 0.001;
          KeyRepeat = 2;
          InitialKeyRepeat = 12;
          AppleKeyboardUIMode = 3;
          AppleShowAllExtensions = true;
          NSTableViewDefaultSizeMode = 2;
          _HIHideMenuBar = false;
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
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;
          AppleFontSmoothing = 1;
          "com.apple.sound.beep.feedback" = 0;
        };
        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
        finder = {
          AppleShowAllExtensions = true;
          _FXShowPosixPathInTitle = false;
          FXEnableExtensionChangeWarning = false;
          _FXSortFoldersFirst = true;
          AppleShowAllFiles = true;
          FXPreferredViewStyle = "Nlsv";
          ShowPathbar = true;
          ShowStatusBar = true;
          FXDefaultSearchScope = "SCcf";
        };
        dock = {
          wvous-tl-corner = 1;
          wvous-tr-corner = 1;
          wvous-bl-corner = 1;
          wvous-br-corner = 1;
          tilesize = 45;
          mineffect = "scale";
          show-recents = false;
          expose-group-apps = true;
          mru-spaces = false;
          autohide = true;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.4;
          persistent-apps = [
            "/Applications/Things3.app"
            "/Users/daniel/Applications/Home Manager Apps/Zen Browser (Beta).app"
            # "/Users/daniel/Applications/Home Manager Apps/Obsidian.app"
            "/Applications/Obsidian.app"
            "/Users/daniel/Applications/Home Manager Apps/Ghostty.app"
            # "/Applications/tidalunar.app"
            # "/Applications/Nix Apps/Feishin.app"
            "/Applications/TIDAL.app/"
          ];
        };
        trackpad = {
          FirstClickThreshold = 0;
          TrackpadFourFingerHorizSwipeGesture = 2; # NOTE: needed for agate wm
        };
        WindowManager = {
          AutoHide = true;
          EnableStandardClickToShowDesktop = false;
          EnableTilingByEdgeDrag = false;
          HideDesktop = true;
          StageManagerHideWidgets = true;
        };
        spaces.spans-displays = false;
        ActivityMonitor.IconType = 6;
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
        CustomUserPreferences = {
          NSGlobalDomain = {
            WebKitDeveloperExtras = true;
            "com.apple.mouse.linear" = true;
            SLSMenuBarUseBlurredAppearance = false;
            AppleIconAppearanceTintColor = "Other";
            AppleIconAppearanceTheme = "RegularDark";
            AppleIconAppearanceCustomTintColor = appleHighlightColor;
            AppleHighlightColor = "${appleHighlightColor} Other";
          };
          "com.apple.Appearance-Settings.extension".AppleOtherHighlightColor = appleHighlightColor;
          "com.apple.dock" = {
            contents-immutable = true;
            size-immutable = true;
          };
          "com.apple.commerce".AutoUpdate = true;
          "com.apple.AdLib" = {
            allowIdentifierForAdvertising = false;
            allowApplePersonalizedAdvertising = false;
            forceLimitAdTracking = true;
          };
          # Use key repeat instead of the accent popup (see postActivation).
          "com.vscodium".ApplePressAndHoldEnabled = false;
          "com.apple.SoftwareUpdate" = {
            AutomaticCheckEnabled = true;
            ScheduleFrequency = 1;
            AutomaticDownload = 1;
            CriticalUpdateInstall = 1;
          };
          "com.apple.finder" = {
            ShowExternalHardDrivesOnDesktop = true;
            ShowTabView = false;
            SidebarDevicesSectionDisclosedState = true;
            SidebarPlacesSectionDisclosedState = true;
            SidebarShowingiCloudDesktop = false;
            NewWindowTargetPath = "file:///Users/${user}/Downloads";
          };
          "com.apple.desktopservices" = {
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

    # Homebrew
    homebrew = {
      enable = true;
      caskArgs.no_quarantine = true;
      onActivation = {
        # Taps are pinned through nix-homebrew (mutableTaps = false) and bumped
        # via flake.lock, so `brew update` has nothing to do.
        autoUpdate = false;
        upgrade = true;
        cleanup = "zap";
      };
      masApps = {
        # "Xcode" = 497799835;
        "Things" = 904280696;
        "eduVPN" = 1317704208;
        "Goodnotes" = 1444383602;
        "System Color Picker" = 1545870783;
        "Numbers" = 361304891;
        "Keynote" = 361285480;
      };

      taps = builtins.attrNames config.nix-homebrew.taps;
      brews = [
        "displayplacer"
        "tag"
      ];
      casks = [
        "tailscale-app"
        "tidal"
        "cleanshot"
        "mac-mouse-fix"
        "orbstack"
        "affinity"
        "mullvad-vpn"
        "fuse-t"
        "macos-fuse-t/cask/fuse-t-sshfs"
        "macpacker"
        # "sf-symbols"
      ];
    };

    documentation = {
      doc.enable = true;
      info.enable = true;
    };

    fonts.packages = with pkgs; [
      monocraft
      maple-mono.NF
    ];

    # Custom app icons (nixkit). Icons come from dotfiles-assets, which is
    # git-lfs, so they are fetched pinned to a commit like the wallpaper.
    environment.customIcons = {
      enable = true;
      clearCacheOnActivation = true;
      icons = [
        {
          path = "/Applications/Nix Apps/Feishin.app";
          icon = builtins.fetchurl {
            url = "https://media.githubusercontent.com/media/frostplexx/dotfiles-assets.nix/619d817f5b612da8487bb02c5dc3347057362706/darwin-icons/music.icns";
            sha256 = "sha256-ox91B5qQGP7axqpIi9Nbf8mcA+iFM7dCS6qfN2eNYsw=";
          };
        }
      ];
    };

    # System packages
    # System packages: Nix itself, the toolchain, man pages, `mas` (used by
    # the Homebrew activation) and GUI apps, which land in /Applications/Nix
    # Apps (the Dock and custom icons point there). User CLI tools live in
    # home-manager below; `op` comes from programs._1password.
    environment.systemPackages = with pkgs; [
      inputs.determinate.packages.${pkgs.stdenv.hostPlatform.system}.default
      gcc
      gnumake
      man-pages
      man-pages-posix
      mas

      # GUI apps
      feishin
      moonlight-qt
      utm
      zoom-us
    ];

    # Home Manager
    home-manager.users.${user} = _: {
      home = {
        stateVersion = "26.05";
        username = user;
        homeDirectory = "/Users/${user}";
        sessionVariables.EDITOR = "nvim";

        # Development and CLI tools (tiramisu is gaming-only and doesn't get these)
        packages = with pkgs; [
          curl
          ffmpeg
          jq
          just
          macpm
          nmap
          pandoc
          poppler-utils # pdftotext, used from the Obsidian vault
          secretspec
          sops
          sshpass
          switchaudio-osx # used by vicinae's audio-device extension
          tart
          uv
          wget
        ];
      };
      programs.home-manager.enable = true;
    };
  };
}
