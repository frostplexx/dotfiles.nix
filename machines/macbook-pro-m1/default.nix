# Configuration for Lyra MacBook
{
    pkgs,
    user,
    ...
}: {
    imports = [
        ../shared.nix # Base configuration
        ./apps.nix # Lyra-specific apps
        ./aerospace.nix
        ./custom_icons/custom_icons.nix # Custom application icons
        ../../lib/custom-icons.nix
        ../../lib/copy-apps.nix
    ];

    services.hyperkey = {
        enable = true;
        normalQuickPress = true; # Quick press of Caps Lock will send Escape
        includeShift = false; # Hyper key will be Cmd+Ctrl+Alt (without Shift)
    };

    # services.lazykeys = {
    #     enable = true;
    #     normalQuickPress = true; # Quick press of Caps Lock will send Escape
    #     includeShift = false; # Hyper key will be Cmd+Ctrl+Alt (without Shift)
    # };

    # Basic system configuration
    networking = {
        hostName = "macbook-pro-m1";
        computerName = "macbook-pro-m1";
        dns = [
            "9.9.9.9"
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
            shell = "/run/current-system/sw/bin/fish";
        };
    };

    # System defaults and preferences
    system = {
        startup.chime = false;

        # Post-activation scripts
        activationScripts = {
            postUserActivation.text = ''
                # Disable mouse acceleration
                defaults write NSGlobalDomain com.apple.mouse.linear -bool true
                defaults write NSGlobalDomain AppleHighlightColor -string "0.537 0.706 0.98"
                # Title bar icons in finder
                # defaults write com.apple.universalaccess "showWindowTitlebarIcons" -bool "true"
                defaults write NSGlobalDomain NSColorSimulateHardwareAccent -bool YES;
                defaults write NSGlobalDomain NSColorSimulatedHardwareEnclosureNumber -int 11;
                defaults write NSGlobalDomain AppleAccentColor -int 10;

                #set wallpaper
                osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/daniel/dotfiles.nix/assets/wallpaper.png"'

                # Reload settings
                /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
                killall Finder
            '';

            # https://github.com/LnL7/nix-darwin/issues/811
            setFishAsShell.text = ''
                dscl . -create /Users/${user} UserShell /run/current-system/sw/bin/fish
            '';
        };

        defaults = {
            smb.NetBIOSName = "pc-dev-lyra";
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

                # File dialogs
                NSNavPanelExpandedStateForSaveMode = true;
                NSNavPanelExpandedStateForSaveMode2 = true;

                # Font rendering
                AppleFontSmoothing = 1;

                "com.apple.sound.beep.feedback" = 0;
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
                    # "/Applications/Safari.app"
                    # "${pkgs.wezterm}/Applications/WezTerm.app"
                    "${pkgs.kitty}/Applications/kitty.app"
                    "${pkgs.obsidian}/Applications/Obsidian.app"
                ];
            };

            # Other system settings
            trackpad.FirstClickThreshold = 0;
            WindowManager = {
                AutoHide = true;
                EnableStandardClickToShowDesktop = false;
                EnableTilingByEdgeDrag = true;
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

                "com.apple.finder" = {
                    ShowExternalHardDrivesOnDesktop = true;
                    ShowHardDrivesOnDesktop = false;
                    ShowMountedServersOnDesktop = true;
                    ShowRemovableMediaOnDesktop = true;
                    _FXSortFoldersFirst = true;
                    ShowTabView = false;
                    FXPreferredViewStyle = "Nlsv";
                    FXDefaultSearchScope = "SCcf";
                    NewWindowTargetPath = "file:///Users/${user}/Downloads/";
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
}
