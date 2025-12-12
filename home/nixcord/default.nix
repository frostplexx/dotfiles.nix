{
  config,
  pkgs,
  user,
  ...
}: let
  # === Modify this if you want to use vesktop ===
  useVesktop = false;

  themeFile = "catppuccin-mocha.theme.css";
  themeUrl = "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/mocha.theme.css";

  vekstopPath =
    if pkgs.stdenv.isDarwin
    then "/Users/${user}/Library/Application Support/vesktop/themes/${themeFile}"
    else "${config.xdg.configHome}/vesktop/themes/${themeFile}";

  discordPath =
    if pkgs.stdenv.isDarwin
    then "/Users/${user}/Library/Application Support/Vencord/themes/${themeFile}"
    else "${config.xdg.configHome}/Vencord/themes/${themeFile}";

  # Define theme path based on operating system
  themePath =
    if useVesktop
    then vekstopPath
    else discordPath;
in {
  programs.nixcord = {
    enable = true;
    discord = {
      enable =
        if useVesktop
        then false
        else true;
    };
    vesktop = {
      enable = useVesktop;
      package = pkgs.vesktop;
    };
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
        gifPaste.enable = true;
        petpet.enable = true;
        betterRoleContext.enable = true;
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        fakeProfileThemes.enable = true;
        # clearUrLs.enable = true;
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
        # shikiCodeblocks = {
        #   enable = true;
        #   theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/ecd9fb1b4a38381df95048c19cf9b8bdcbb1ec09/packages/tm-themes/themes/catppuccin-macchiato.json";
        # };
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
        sha256 = "1w921c6zg5xvkf52x642psnqpaannbd28cc37dfzasbplw7ghl2x";
      };
      force = true;
    };

    # Settings configuration
    "${config.programs.nixcord.vesktop.configDir}/settings.json" = {
      text = builtins.toJSON {
        discordBranch = "stable";
        minimizeToTray = true;
        appBadge = false;
        enableSplashScreen = false;
        splashTheming = true;
        arRPC = true;
        customTitleBar =
          if pkgs.stdenv.isDarwin
          then true
          else false;
      };
      force = true;
    };
  };
}
