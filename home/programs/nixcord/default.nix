{ config, pkgs, ... }:
{
  programs.nixcord = {
    enable = true;
    discord.enable = false;
    vesktop = {
      enable = true;
    };
    config = {
      useQuickCss = true;
      enableReactDevtools = true;
      disableMinSize = true;
      themeLinks = [
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
  };


  # force the following json into vesktop.configDir/settings.json because you cant do that in the
  # nixcord config
  home.file."${config.programs.nixcord.vesktop.configDir}/settings.json" = {
    text = builtins.toJSON {
      discordBranch = "stable";
      minimizeToTray = true;
      arRPC = true;
      customTitleBar = if pkgs.stdenv.isDarwin then true else false;
    };
    force = true; # Force the file to be written so it overrides the settings nixvim creates
  };


  home.file."${config.programs.nixcord.vesktop.configDir}/settings/quickCss.css" = {
    text = ''
      .titleBar_a934d8 {
        display: none !important;
      }
    '';
    force = true;
  };
}
