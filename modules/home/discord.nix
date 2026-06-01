_: {
  flake.homeManagerModules.nixcord = {
    pkgs,
    config,
    defaults,
    ...
  }: let
    useVesktop = true;
    themeFile = "catppuccin-mocha.theme.css";
    catppuccinUrl = "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/mocha.theme.css";
    rosePineUrl = "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-rose-pine.theme.css";

    vekstopPath =
      if pkgs.stdenv.isDarwin
      then "/Users/${defaults.user}/Library/Application Support/vesktop/themes/${themeFile}"
      else "${config.xdg.configHome}/vesktop/themes/${themeFile}";

    discordPath =
      if pkgs.stdenv.isDarwin
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
        frameless = pkgs.stdenv.isDarwin;
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
          {
            "catppuccin" = builtins.fetchurl {
              url = catppuccinUrl;
              sha256 = "1w921c6zg5xvkf52x642psnqpaannbd28cc37dfzasbplw7ghl2x";
            };

            "rose-pine" = builtins.fetchurl {
              url = rosePineUrl;
              sha256 = "10ca7jj8rlwh9v64kdlgz5w1sm72kgm75zikwnwl01azrxzc638j";
            };
          }
            .${
            defaults.settings.theme
          };

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
          customTitleBar = pkgs.stdenv.isDarwin;
        };
        force = true;
      };
    };
  };
}
