# Configuration for Lyra MacBook
{
    pkgs,
    user,
    assets,
    ...
}: {
    imports = [
        ../shared.nix # Base configuration
        ./apps.nix # Lyra-specific apps
        ./aerospace.nix
        ./custom_icons.nix
    ];

    services.lazykeys = {
        enable = true;
        normalQuickPress = true; # Quick press of Caps Lock will send Escape
        includeShift = false; # Hyper key will be Cmd+Ctrl+Alt (without Shift)
        mode = "custom";
        customKey = "escape";
    };

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
            postActivation = {
                text = ''
                    echo "running activate settings..."
                    # Disable mouse acceleration
                    defaults write NSGlobalDomain com.apple.mouse.linear -bool true
                    defaults write "Apple Global Domain" AppleHighlightColor -string "0.7421875 0.53515625 1.000000 Other"

                    # Other for custom color or nothing
                    # defaults write "Apple Global Domain" AppleIconAppearanceTintColor Other
                    # can be either TintedDark, TintedLight, RegularLight, RegularDark, ClearDark, ClearLight or empty for automatic colors
                    # defaults write "Apple Global Domain" AppleIconAppearanceTheme ClearDark
                    # Affects Icons, Folders and widgets. Needs to have AppleIconAppearanceTintColor set to Other
                    # Color is rgba value divided by 256 so its between 0 and 1
                    # defaults write "Apple Global Domain" AppleIconAppearanceCustomTintColor -string "0.7421875 0.53515625 1.000000 1.000000"

                    # No idea what it doe
                    defaults write "com.apple.Appearance-Settings.extension" AppleOtherHighlightColor -string "0.7686274509803921 0.6549019607843137 0.9058823529411765"

                    # Reload settings
                    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
                    # osascript -e 'tell application "System Events" to set picture of every desktop to "${assets}/wallpapers/denis-istomin-midnight-gazing.png"'
                    killall Finder
                    killall Dock
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
                AppleInterfaceStyleSwitchesAutomatically = true;
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
                    "/Applications/Zen.app/"
                    # "/Applications/Firefox.app"
                    # "/Applications/Safari.app"
                    "${pkgs.kitty}/Applications/kitty.app"
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
