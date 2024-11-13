{ pkgs, ... }:

###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#
###################################################################################
{
  system = {
    stateVersion = 5;
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    startup.chime = false;

    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock

      NSGlobalDomain = {
        NSWindowShouldDragOnGesture = true;
        NSAutomaticWindowAnimationsEnabled = true;
        NSWindowResizeTime = 0.2;
        AppleShowAllExtensions = true;
        _HIHideMenuBar = true;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleICUForce24HourTime = true;
        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = true; # enable press and hold

        NSAutomaticCapitalizationEnabled = false;

        NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default(保存文件时的路径选择/文件名输入页)
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = false;
        FXEnableExtensionChangeWarning = false;
        _FXSortFoldersFirst = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
      };
      dock = {

        # Disable Hot corners
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;

        tilesize = 45;
        expose-group-by-app = true;
        mru-spaces = false;
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.4;
        mineffect = "scale";
        show-recents = false;
        persistent-apps = [
          "/Applications/Things3.app"
          "${pkgs.firefox-bin}/Applications/Firefox.app"
          "/Applications/kitty.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
        ];
      };
      trackpad.FirstClickThreshold = 0;
      WindowManager = {
        AutoHide = true;
        EnableStandardClickToShowDesktop = false;
      };
      spaces.spans-displays = false;
      menuExtraClock.ShowDate = 2;



      CustomUserPreferences = {
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };

        # Run: open ~/Library/Preferences/com.apple.finder.plist
        # to see see what possible settings exist
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          ShowTabView = false;
          FXPreferredViewStyle = "Nlsv";
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
          NewWindowTargetPath = "file:///Users/daniel/Documents";
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

      loginwindow = {
        GuestEnabled = false; # disable guest user
        SHOWFULLNAME = true; # show full name in login window
      };

    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
}
