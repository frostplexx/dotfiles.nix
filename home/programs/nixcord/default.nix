{
  # ...
  programs.nixcord = {
    enable = true; # enable Nixcord. Also installs discord package
    discord.enable = false; # enable Discord
    vesktop.enable = true; # enable Vesktop
    quickCss = ""; # quickCSS file
    config = {
      useQuickCss = true; # use out quickCSS
      enableReactDevtools = true;
      disableMinSize = true;
      themeLinks = [
        # or use an online theme
        "https://raw.githubusercontent.com/refact0r/midnight-discord/master/flavors/midnight-catppuccin-macchiato.theme.css"
      ];
      frameless = true;
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
        callTimer.enable = true;
        clearURLs.enable = true;
        crashHandler.enable = true;
        experiments.enable = true;
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
          theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/refs/heads/main/packages/tm-themes/themes/catppuccin-macchiato.json";
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
    extraConfig = {
      # Some extra JSON config here
      # ...
    };
  };
  # ...
}
