{
  config,
  pkgs,
  vars,
  ...
}: let
  themeFile = "midnight-catppuccin-macchiato.theme.css";
  themeUrl = "https://raw.githubusercontent.com/refact0r/midnight-discord/master/flavors/midnight-catppuccin-macchiato.theme.css";

  # Define theme path based on operating system
  themePath =
    if pkgs.stdenv.isDarwin
    then "/Users/${vars.user}/Library/Application Support/Vencord/themes/${themeFile}"
    else "${config.xdg.configHome}/vesktop/themes/${themeFile}";
in {
  stylix.targets.vesktop.enable = false; # Deactivate stylix because it doesnt work on macos
  programs.nixcord = {
    enable = true;
    discord.enable = true;
    vesktop.enable = false;
    config = {
      useQuickCss = false;
      enableReactDevtools = true;
      disableMinSize = true;
      frameless = if pkgs.stdenv.isDarwin then true else false;
      enabledThemes = [ themeFile ];
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

  # Download theme file
  home.file = {
    ${themePath} = {
      source = builtins.fetchurl {
        url = themeUrl;
        sha256 = "17k26qv8f87ryqz9c04ra96122b4kqijv4mnbakgrng4ji3himgn";
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
