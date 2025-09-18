{
    config,
    pkgs,
    user,
    ...
}: let
in {
    programs.nixcord = {
        enable = true;
        discord = {
            enable = false;
        };
        vesktop = {
            enable = true;
            package = pkgs.vesktop;
        };
        config = {
            enableReactDevtools = true;
            disableMinSize = true;
            frameless =
                if pkgs.stdenv.isDarwin
                then true
                else false;
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
                fakeProfileThemes.enable = true;
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
                };
                translate.enable = true;
                typingIndicator.enable = true;
                typingTweaks.enable = true;
                validReply.enable = true;
                viewRaw.enable = true;
                voiceChatDoubleClick.enable = true;
                webScreenShareFixes.enable = true;
                whoReacted.enable = true;
                appleMusicRichPresence = {
                    enable = false;
                    activityType = "listening";
                };
            };
        };
    };

    # Download theme file
    home.file = {
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
