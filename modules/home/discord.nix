_: {
  flake.homeManagerModules.nixcord = {
    pkgs,
    config,
    defaults,
    inputs,
    ...
  } @ args: let
    aeroTheme = args.aeroTheme or false;
    useVesktop = true;
    skeuoCordFile = "SkeuoCord.theme.css";
    themeFile =
      if aeroTheme
      then skeuoCordFile
      else "catppuccin-mocha.theme.css";
    catppuccinTheme = "${inputs.catppuccin-discord}/themes/mocha.theme.css";
    skeuoCordTheme = "${inputs.skeuocord}/SkeuoCord.theme.css";

    vekstopPath =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "/Users/${defaults.user}/Library/Application Support/vesktop/themes/${themeFile}"
      else "${config.xdg.configHome}/vesktop/themes/${themeFile}";

    discordPath =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "/Users/${defaults.user}/Library/Application Support/Vencord/themes/${themeFile}"
      else "${config.xdg.configHome}/Vencord/themes/${themeFile}";

    themePath =
      if useVesktop
      then vekstopPath
      else discordPath;
  in {
    programs.nixcord = {
      enable = true;
      discord.enable = !useVesktop;
      vesktop = {
        enable = useVesktop;
        package = pkgs.vesktop;
      };
      config = {
        useQuickCss = true;
        enableReactDevtools = true;
        disableMinSize = true;
        frameless = pkgs.stdenv.hostPlatform.isDarwin;
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
          betterRoleContext.enable = true;
          betterSettings.enable = true;
          betterUploadButton.enable = true;
          biggerStreamPreview.enable = true;
          fakeProfileThemes.enable = true;
          crashHandler.enable = true;
          experiments = {
            enable = true;
            toolbarDevMenu = true;
          };
          musicRichPresence = {
            enable = false;
            useListeningStatus = true;
            showLogo = false;
            username = "challengerind";
          };
          fakeNitro.enable = true;
          fixImagesQuality.enable = true;
          favoriteEmojiFirst.enable = true;
          fullSearchContext.enable = true;
          gameActivityToggle.enable = true;
          imageZoom.enable = true;
          memberCount.enable = true;
          mentionAvatars.enable = true;
          noDevtoolsWarning.enable = true;
          noF1.enable = true;
          showHiddenThings.enable = true;
          permissionsViewer.enable = true;
          plainFolderIcon.enable = true;
          summaries.enable = true;
          quickMention.enable = true;
          readAllNotificationsButton.enable = true;
          sendTimestamps.enable = true;
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

    home.file = {
      ${themePath} = {
        source =
          if aeroTheme
          then skeuoCordTheme
          else catppuccinTheme;

        force = true;
      };

      "${config.programs.nixcord.vesktop.configDir}/settings.json" = {
        text = builtins.toJSON {
          discordBranch = "stable";
          minimizeToTray = true;
          appBadge = false;
          enableSplashScreen = false;
          splashTheming = true;
          arRPC = true;
          customTitleBar = pkgs.stdenv.hostPlatform.isDarwin;
        };
        force = true;
      };
    };
  };
}
