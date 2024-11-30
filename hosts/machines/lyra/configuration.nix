# Configuration for Lyra MacBook
{
  pkgs,
  vars,
  mkHomeManagerConfiguration,
  ...
}: {
  imports = [
    ../../base # Base configuration
    ./apps.nix # Lyra-specific apps
    ./custom_icons/custom_icons.nix # Custom application icons
    ./stylix.nix
    ../../../nix/custom-icons.nix
  ];

  # Basic system configuration
  networking = {
    hostName = "pc-dev-lyra";
    computerName = "pc-dev-lyra";
  };
  time.timeZone = "Europe/Berlin";

  # System services
  services.nix-daemon.enable = true;

  # Security settings
  security.pam.enableSudoTouchIdAuth = true;
  nix.settings.trusted-users = [vars.user];

  # User configuration
  users.users.${vars.user} = {
    home = "/Users/${vars.user}";
    description = vars.user;
  };

  # Home Manager configuration
  home-manager.users.${vars.user} = mkHomeManagerConfiguration.withModules [
    "aerospace"
    "editor"
    "firefox"
    "kitty"
    "git"
    "shell"
    "nixcord"
    "spicetify"
    "ssh"
  ];

  # System defaults and preferences
  system = {
    startup.chime = false;

    # Post-activation scripts
    activationScripts.postUserActivation.text = ''
       # Disable mouse acceleration
       defaults write NSGlobalDomain com.apple.mouse.linear -bool true
       # Title bar icons in finder
       # defaults write com.apple.universalaccess "showWindowTitlebarIcons" -bool "true"

       #set wallpaper
      osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/${vars.user}/dotfiles.nix/home/programs/plasma/wallpaper.png"'

       # Reload settings
       /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
       killall Finder
    '';

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

      # Global system preferences
      NSGlobalDomain = {
        # Window behavior
        NSWindowShouldDragOnGesture = true;
        NSAutomaticWindowAnimationsEnabled = true;
        NSWindowResizeTime = 0.2;

        # Keyboard settings
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;

        # Interface preferences
        AppleShowAllExtensions = true;
        _HIHideMenuBar = true;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleICUForce24HourTime = true;
        NSAutomaticCapitalizationEnabled = false;
        AppleInterfaceStyle = "Dark";

        # File dialogs
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Font rendering
        AppleFontSmoothing = 1;
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
        expose-group-by-app = true;
        mru-spaces = false;
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.4;

        # Pinned apps
        persistent-apps = [
          "/Applications/Things3.app"
          # "${pkgs.arc-browser}/Applications/Arc.app"
          "/Users/daniel/Applications/Home Manager Apps/Firefox.app"
          "${pkgs.kitty}/Applications/kitty.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
        ];
      };

      # Other system settings
      trackpad.FirstClickThreshold = 0;
      WindowManager = {
        AutoHide = true;
        EnableStandardClickToShowDesktop = false;
      };
      spaces.spans-displays = false;
      ActivityMonitor.IconType = 6;

      # Login window settings
      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
        autoLoginUser = vars.user;
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
          NewWindowTargetPath = "file:///Users/${vars.user}/Downloads/";
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
