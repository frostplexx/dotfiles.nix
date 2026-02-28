{
  inputs,
  lib,
  ...
}: {
  flake.modules.darwin.macbook-m4-pro = {
    pkgs,
    config,
    defaults,
    ...
  }: let
    inherit (defaults) user;
  in {
    system.stateVersion = 6;

    # Determinate Nix settings
    determinateNix.customSettings = {
      experimental-features = "nix-command flakes parallel-eval impure-derivations";
      lazy-trees = true;
      warn-dirty = false;
      substituters = "https://nix-community.cachix.org https://cache.nixos.org";
      trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
      extra-trusted-users = "root ${user}";
      eval-cores = 0;
      auto-optimise-store = true;
      max-jobs = "auto";
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
        "FelixKratz/homebrew-formulae" = jankyborders;
      };
    };

    # LazyKeys configuration
    services.lazykeys = {
      enable = true;
      normalQuickPress = false;
      includeShift = false;
      mode = "custom";
      customKey = "escape";
    };

    programs.opsops.enable = true;

    # Networking
    networking = {
      hostName = "macbook-m4-pro";
      computerName = "macbook-m4-pro";
      dns = ["9.9.9.10"];
      knownNetworkServices = [
        "Wi-Fi"
        "Ethernet Adaptor"
        "Thunderbolt Ethernet"
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
        computer = 5;
        display = 10;
      };
    };

    # System defaults
    system = {
      primaryUser = user;
      startup.chime = false;

      activationScripts = {
        postActivation = let
          hexToAppleRGBA = hex: let
            cleanHex = lib.removePrefix "#" hex;
            r = lib.fromHexString (builtins.substring 0 2 cleanHex);
            g = lib.fromHexString (builtins.substring 2 2 cleanHex);
            b = lib.fromHexString (builtins.substring 4 2 cleanHex);
            rNorm = r / 255.0;
            gNorm = g / 255.0;
            bNorm = b / 255.0;
          in "${builtins.toString rNorm} ${builtins.toString gNorm} ${builtins.toString bNorm} 1.000000";
          highlightColor = "#cba6f7";
          appleHighlightColor = hexToAppleRGBA highlightColor;
        in {
          enable = true;
          text = ''
            echo "Running activate settings..."

            sudo -u ${user} defaults write "Apple Global Domain" com.apple.mouse.linear -bool true
            sudo -u ${user} defaults write "Apple Global Domain" "com.apple.mouse.scaling" -string "0.875"
            sudo -u ${user} defaults write "Apple Global Domain" SLSMenuBarUseBlurredAppearance -bool false
            sudo -u ${user} defaults write "Apple Global Domain" AppleIconAppearanceTintColor Other
            sudo -u ${user} defaults write "Apple Global Domain" AppleIconAppearanceTheme RegularDark
            sudo -u ${user} defaults write "Apple Global Domain" AppleIconAppearanceCustomTintColor -string "${appleHighlightColor}"
            sudo -u ${user} defaults write "Apple Global Domain" AppleHighlightColor -string "${appleHighlightColor} Other"
            sudo -u ${user} defaults write "com.apple.Appearance-Settings.extension" AppleOtherHighlightColor -string "${appleHighlightColor}"
            sudo -u ${user} launchctl setenv CHROME_HEADLESS 1
            sudo -u ${user} defaults write com.apple.Dock contents-immutable -bool true
            sudo -u ${user} defaults write com.apple.dock size-immutable -bool yes

            killall Finder;
            killall Dock;
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
          NSWindowShouldDragOnGesture = true;
          NSAutomaticWindowAnimationsEnabled = true;
          NSWindowResizeTime = 0.001;
          KeyRepeat = 2;
          InitialKeyRepeat = 12;
          AppleKeyboardUIMode = 3;
          ApplePressAndHoldEnabled = true;
          AppleShowAllExtensions = true;
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
          ShowPathbar = true;
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
            "/Applications/Zen.app"
            "/Applications/Nix Apps/Obsidian.app"
          ];
        };
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
          NSGlobalDomain.WebKitDeveloperExtras = true;
          "com.apple.commerce".AutoUpdate = true;
          "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
          "com.apple.SoftwareUpdate" = {
            AutomaticCheckEnabled = true;
            ScheduleFrequency = 1;
            AutomaticDownload = 1;
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
            FXDefaultSearchScope = "SCcf";
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
        autoUpdate = true;
        upgrade = true;
        cleanup = "zap";
      };
      taps = builtins.attrNames config.nix-homebrew.taps;
      brews = ["displayplacer"];
      casks = [
        "tailscale-app"
        "chromium"
        "cleanshot"
        "mac-mouse-fix"
        "orbstack"
        "zoom"
        "zen"
        "affinity"
        "1password"
        "mullvad-vpn"
        "sf-symbols"
        "tidal"
      ];
    };

    documentation = {
      doc.enable = true;
      info.enable = true;
    };

    fonts.packages = with pkgs; [
      open-sans
      inter
      jetbrains-mono
      maple-mono.truetype-autohint
      maple-mono.NF
      sketchybar-app-font
    ];

    # System packages
    environment.systemPackages = with pkgs; [
      _1password-cli
      alejandra
      bvi
      curl
      deadnix
      discord-ptb
      entr
      ffmpeg
      gcc
      gh
      ghq
      gnumake
      gnupg
      hexfiend
      iina
      imagemagick
      inputs.determinate.packages.${pkgs.stdenv.hostPlatform.system}.default
      # inputs.tidaLuna.packages.${system}.default
      jq
      just
      keka
      macpm
      magic-wormhole-rs
      man-pages
      man-pages-posix
      mas
      moonlight-qt
      netcat
      nh
      nix-output-monitor
      nix-tree
      nmap
      nvd
      obsidian
      pandoc
      ripgrep
      skimpdf
      sops
      sshpass
      statix
      switchaudio-osx
      termshark
      unp
      utm
      uv
      vscode
      wget
      whisky
      wtfis
    ];

    # Home Manager
    home-manager.users.${user} = _: {
      home = {
        stateVersion = "23.11";
        username = user;
        homeDirectory = "/Users/${user}";
        sessionVariables = {
          NH_FLAKE = "$HOME/${defaults.paths.flake}";
          EDITOR = "nvim";
        };
      };
      programs.home-manager.enable = true;
    };
  };
}
