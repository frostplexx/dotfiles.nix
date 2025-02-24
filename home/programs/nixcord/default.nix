{
  config,
  pkgs,
  vars,
  ...
}: let
  themeFile = "midnight-catppuccin-mocha.theme.css";
  # themeUrl = "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/flavors/midnight-catppuccin-mocha.theme.css";
  themeUrl = "https://raw.githubusercontent.com/rose-pine/discord/refs/heads/main/rose-pine.theme.css";

  # Define theme path based on operating system
  themePath =
    if pkgs.stdenv.isDarwin
    then "/Users/${vars.user}/Library/Application Support/vesktop/themes/${themeFile}"
    else "${config.xdg.configHome}/vesktop/themes/${themeFile}";
in {
  programs.nixcord = {
    enable = true;
    discord = {
      enable = false;
      openASAR.enable = true;
      vencord = {
        unstable = true;
      };
    };
    vesktop.enable = true;
    config = {
      useQuickCss = true;
      enableReactDevtools = true;
      disableMinSize = true;
      frameless =
        if pkgs.stdenv.isDarwin
        then true
        else false;
      enabledThemes = [themeFile];
      plugins = {
        alwaysAnimate.enable = true;
        betterFolders = {
          enable = true;
          sidebar = true;
          sidebarAnim = true;
          closeAllFolders = true;
          closeAllHomeButton = true;
          forceOpen = true;
        };
        betterGifPicker.enable = true;
        betterRoleContext.enable = true;
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        # callTimer.enable = true;
        clearURLs.enable = true;
        crashHandler.enable = true;
        experiments = {
          enable = true;
          toolbarDevMenu = true;
        };
        fakeNitro.enable = true;
        favoriteGifSearch.enable = true;
        fixImagesQuality.enable = true;
        favoriteEmojiFirst.enable = true;
        fullSearchContext.enable = true;
        gameActivityToggle.enable = true;
        imageZoom.enable = true;
        memberCount.enable = true;
        mentionAvatars.enable = true;
        noDevtoolsWarning.enable = true;
        noF1.enable = true;
        permissionsViewer.enable = true;
        pinDMs.enable = true;
        plainFolderIcon.enable = true;
        summaries.enable = true;
        quickMention.enable = true;
        readAllNotificationsButton.enable = true;
        sendTimestamps.enable = true;
        shikiCodeblocks = {
          enable = true;
          # theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/refs/heads/main/packages/tm-themes/themes/catppuccin-mocha.json";
          theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/refs/heads/main/packages/tm-themes/themes/rose-pine.json";
        };
        translate.enable = true;
        typingIndicator.enable = true;
        typingTweaks.enable = true;
        validReply.enable = true;
        viewRaw.enable = true;
        voiceChatDoubleClick.enable = true;
        webScreenShareFixes.enable = true;
        whoReacted.enable = true;
      };
    };
  };

  # Download theme file
  home.file = {
    ${themePath} = {
      source = builtins.fetchurl {
        url = themeUrl;
        # sha256 = "0rl39szkrjb1lgg7ig590pad9j4y23fg5cskghvb9nksdimv3px2";
        sha256 = "1asjy6j6csdy0r4cb5kar9j00ryh1r2az4k0axvxjz35qny43p05";
      };
      force = true;
    };

    # Settings configuration
    "${config.programs.nixcord.vesktop.configDir}/settings.json" = {
      text = builtins.toJSON {
        discordBranch = "stable";
        minimizeToTray = true;
        arRPC = true;
        customTitleBar =
          if pkgs.stdenv.isDarwin
          then true
          else false;
      };
      force = true;
    };
    # Quick CSS configuration
    "${config.programs.nixcord.vesktop.configDir}/settings/quickCss.css" = {
      text = ''
        .titleBar_a934d8 {
          display: none !important;
        }
      '';
      force = true;
    };
  };
}
