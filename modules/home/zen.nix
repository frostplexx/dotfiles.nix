_: {
    flake.modules.homeManager.zen_browser = {
        pkgs,
        lib,
        ...
    }: let
        #===========================================================================
        # CONFIGURATION
        #===========================================================================
        # Theme configuration
        enableCustomTheme = false;
        catppuccinPalette = "Mocha";
        catppuccinAccent = "Mauve";

        # Platform-specific paths
        policyJsonPathZen =
            if pkgs.stdenv.isDarwin
            then "/Applications/Zen.app/Contents/Resources/distribution"
            else "/etc/zen/policies";

        zenProfilesPath =
            if pkgs.stdenv.isDarwin
            then "$HOME/Library/Application Support/zen/Profiles"
            else "$HOME/.zen";

        #===========================================================================
        # EXTENSIONS
        #===========================================================================

        extensions = {
            "uBlock0@raymondhill.net" = {
                name = "uBlock Origin";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
                private_browsing = true;
            };

            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
                name = "1Password";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
                installation_mode = "force_installed";
                private_browsing = true;
            };
            "clipper@obsidian.md" = {
                name = "Obsidian Web Clipper";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/web-clipper-obsidian/latest.xpi";
                installation_mode = "force_installed";
            };
            "sponsorBlocker@ajay.app" = {
                name = "SponsorBlock";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
                installation_mode = "force_installed";
            };
            "addon@darkreader.org" = {
                name = "Dark Reader";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
                installation_mode = "force_installed";
            };
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
                name = "Vimium";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
                installation_mode = "force_installed";
            };
            "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
                name = "Refined GitHub";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}/latest.xpi";
                installation_mode = "force_installed";
            };
            "containerise@kinte.sh" = {
                name = "Containerise";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/containerise/latest.xpi";
                installation_mode = "force_installed";
            };
        };

        #===========================================================================
        # PREFERENCES
        #===========================================================================

        # Preferences that go into user.js (unrestricted, works for Zen-specific prefs)
        userPreferences = {
            # Zen-specific preferences
            "zen.glance.activation-method" = "shift";
            "zen.theme.gradient.show-custom-colors" = true;
            "zen.welcome-screen.seen" = true;
            "zen.theme.accent-color" = "#cba6f7";
            "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true;
            "zen.workspaces.continue-where-left-off" = true;
            "zen.workspaces.force-container-workspace" = true;
            "zen.view.compact.should-enable-at-startup" = true;
            "zen.view.compact.enable-at-startup" = true;

            # General preferences
            "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
            "browser.tabs.warnOnClose" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = enableCustomTheme;
        };

        # Preferences that go into policies.json (for locked/managed preferences)
        policyPreferences = {
            "browser.uiCustomization.state" = {
                Value = ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["ublock0_raymondhill_net-browser-action","sponsorblocker_ajay_app-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","addon_darkreader_org-browser-action","containerise_kinte_sh-browser-action","clipper_obsidian_md-browser-action","_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action","_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","customizableui-special-spring1","vertical-spacer","urlbar-container","customizableui-special-spring2","unified-extensions-button"],"TabsToolbar":["tabbrowser-tabs"],"vertical-tabs":[],"PersonalToolbar":["personal-bookmarks"],"zen-sidebar-top-buttons":["zen-toggle-compact-mode"],"zen-sidebar-foot-buttons":["downloads-button","zen-workspaces-button","zen-create-new-button"]},"seen":["developer-button","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","addon_darkreader_org-browser-action","containerise_kinte_sh-browser-action","clipper_obsidian_md-browser-action","_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action","sponsorblocker_ajay_app-browser-action","ublock0_raymondhill_net-browser-action","_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"],"dirtyAreaCache":["nav-bar","vertical-tabs","zen-sidebar-foot-buttons","unified-extensions-area","TabsToolbar","PersonalToolbar","zen-sidebar-top-buttons"],"currentVersion":23,"newElementCount":2}'';
                Status = "locked";
            };
        };

        #===========================================================================
        # THEME FILES
        #===========================================================================

        catppuccinZenTheme = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "zen-browser";
            rev = "c855685442c6040c4dda9c8d3ddc7b708de1cbaa";
            sha256 = "sha256-5A57Lyctq497SSph7B+ucuEyF1gGVTsuI3zuBItGfg4=";
        };

        themeFiles = pkgs.runCommand "catppuccin-zen-theme-${catppuccinPalette}-${catppuccinAccent}" {} ''
            mkdir -p $out
            theme_dir="${catppuccinZenTheme}/themes/${catppuccinPalette}/${catppuccinAccent}"

            if [ -d "$theme_dir" ]; then
                cp -r "$theme_dir"/* $out/
            else
                echo "Theme ${catppuccinPalette}/${catppuccinAccent} not found!"
                echo "Available themes:"
                find ${catppuccinZenTheme}/themes -name "*.css" | head -10
                exit 1
            fi
        '';

        #===========================================================================
        # HELPERS
        #===========================================================================

        # Convert a preference value to user.js format
        prefToUserJs = name: value: let
            valueStr =
                if builtins.isBool value
                then
                    (
                        if value
                        then "true"
                        else "false"
                    )
                else if builtins.isInt value
                then builtins.toString value
                else if builtins.isString value
                then ''"${value}"''
                else builtins.toJSON value;
        in ''user_pref("${name}", ${valueStr});'';

        # Generate user.js content from preferences
        userJsContent = let
            prefLines = lib.mapAttrsToList prefToUserJs userPreferences;
        in
            ''
                // User preferences for Zen Browser
                // Generated by Nix configuration

            ''
            + lib.concatStringsSep "\n" prefLines;

        # Build policy.json structure
        policyJson = {
            policies = {
                # Extension management
                ExtensionSettings = lib.mapAttrs (_id: ext: builtins.removeAttrs ext ["name"]) extensions;

                # Search engines
                SearchEngines = {
                    Default = "DuckDuckGo";
                    PreventInstalls = false;
                    Remove = [
                        "Bing"
                        "Ecosia"
                        "Google"
                        "Wikipedia (en)"
                    ];
                };
                SearchSuggestEnabled = true;

                # Disable features
                DisableBuiltinPDFViewer = true;
                DisableFirefoxStudies = true;
                DisableFirefoxAccounts = false;
                DisableFirefoxScreenshots = true;
                DisableForgetButton = true;
                DisableMasterPasswordCreation = true;
                DisableProfileImport = true;
                DisableProfileRefresh = true;
                DisableSetDesktopBackground = true;
                DisplayMenuBar = "default-off";
                DisableTelemetry = true;
                DisableFormHistory = true;
                DisablePasswordReveal = true;
                DontCheckDefaultBrowser = true;

                # Privacy settings
                OfferToSaveLogins = false;
                AutofillAddressEnabled = false;
                AutofillCreditCardEnabled = false;
                PasswordManagerEnabled = false;

                # Tracking protection
                # Needs to be disabled for AdNauseam to work
                # Stuff will still be blocked
                EnableTrackingProtection = {
                    Value = false;
                    Locked = true;
                    Cryptomining = false;
                    Fingerprinting = false;
                    EmailTracking = false;
                };

                # Firefox Suggest
                FirefoxSuggest = {
                    WebSuggestions = false;
                    SponsoredSuggestions = false;
                    ImproveSuggest = false;
                    Locked = true;
                };

                # Downloads and handlers
                DefaultDownloadDirectory = "$HOME/Downloads";
                PromptForDownloadLocation = false;
                Handlers = {
                    mimeTypes."application/pdf".action = "saveToDisk";
                };

                # First run
                OverrideFirstRunPage = "";
                OverridePostUpdatePage = "";
                ExtensionUpdate = false;
                SearchBar = "unified";

                # Cleanup on shutdown
                SanitizeOnShutdown = {
                    Cache = true;
                    Cookies = false;
                    Downloads = false;
                    FormData = true;
                    History = enableCustomTheme;
                    Sessions = false;
                    SiteSettings = false;
                    OfflineApps = true;
                    Locked = true;
                };

                # Preferences (managed via policies)
                Preferences = policyPreferences;
            };
        };

        # Import activation scripts
        activationScripts = import ./zen/_activation.nix {
            inherit lib;
            inherit
                policyJsonPathZen
                zenProfilesPath
                policyJson
                userJsContent
                ;
            inherit
                enableCustomTheme
                catppuccinPalette
                catppuccinAccent
                themeFiles
                ;
        };
        #===========================================================================
        # MODULE OUTPUT
        #===========================================================================
    in {
        programs.default-browser = {
            enable = true;
            browser = "zen";
        };

        home = {
            # Install theme files using Home Manager (only if enabled)
            file = lib.mkIf enableCustomTheme (
                let
                    profileGlob =
                        if pkgs.stdenv.isDarwin
                        then "Library/Application Support/zen/Profiles/*default*/chrome"
                        else ".zen/*default*/chrome";
                in {
                    "${profileGlob}/userChrome.css" = {
                        source = "${themeFiles}/userChrome.css";
                        recursive = false;
                    };

                    "${profileGlob}/zen-keyboard-shortcuts.json".text = ''
                        {"shortcuts":[{"id":"key_hideOtherAppsCmdMac","key":"h","keycode":null,"group":"other","l10nId":"zen-hide-other-apps-shortcut","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_hideThisAppCmdMac","key":"h","keycode":null,"group":"other","l10nId":"zen-hide-app-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_preferencesCmdMac","key":",","keycode":null,"group":"other","l10nId":"zen-preferences-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_minimizeWindow","key":"m","keycode":null,"group":"other","l10nId":"zen-window-minimize-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_minimizeWindow","disabled":false,"reserved":false,"internal":true},{"id":"key_wrToggleCaptureSequenceCmd","key":"6","keycode":null,"group":"other","l10nId":null,"modifiers":{"control":true,"alt":false,"shift":true,"meta":false,"accel":false},"action":"wrToggleCaptureSequenceCmd","disabled":false,"reserved":false,"internal":false},{"id":"key_wrCaptureCmd","key":"3","keycode":null,"group":"other","l10nId":null,"modifiers":{"control":true,"alt":false,"shift":true,"meta":false,"accel":false},"action":"wrCaptureCmd","disabled":false,"reserved":false,"internal":false},{"id":"key_selectLastTab","key":"9","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_selectTab8","key":"8","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_selectTab7","key":"7","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_selectTab6","key":"6","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_selectTab5","key":"5","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_selectTab4","key":"4","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_selectTab3","key":"3","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_selectTab2","key":"2","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_selectTab1","key":"1","keycode":null,"group":"windowAndTabManagement","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_undoCloseWindow","key":"","keycode":"","group":"windowAndTabManagement","l10nId":"zen-window-new-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false},"action":"History:UndoCloseWindow","disabled":true,"reserved":false,"internal":false},{"id":"key_restoreLastClosedTabOrWindowOrSession","key":"t","keycode":null,"group":"windowAndTabManagement","l10nId":"zen-restore-last-closed-tab-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"History:RestoreLastClosedTabOrWindowOrSession","disabled":false,"reserved":false,"internal":false},{"id":"key_quitApplication","key":"q","keycode":null,"group":"windowAndTabManagement","l10nId":"zen-quit-app-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":true,"internal":true},{"id":"key_sanitize_mac","keycode":"VK_BACK","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"Tools:Sanitize","disabled":false,"reserved":false,"internal":false},{"id":"key_sanitize","keycode":"VK_DELETE","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"Tools:Sanitize","disabled":false,"reserved":false,"internal":false},{"id":"key_screenshot","key":"s","keycode":null,"group":"mediaAndDisplay","l10nId":"zen-screenshot-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"Browser:Screenshot","disabled":false,"reserved":false,"internal":false},{"id":"key_privatebrowsing","key":"p","keycode":null,"group":"navigation","l10nId":"zen-private-browsing-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"Tools:PrivateBrowsing","disabled":false,"reserved":true,"internal":false},{"id":"key_switchTextDirection","key":"x","keycode":null,"group":"mediaAndDisplay","l10nId":"zen-bidi-switch-direction-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"cmd_switchTextDirection","disabled":false,"reserved":false,"internal":false},{"id":"key_showAllTabs","keycode":"VK_TAB","group":"other","l10nId":null,"modifiers":{"control":true,"alt":false,"shift":true,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":null,"key":"","keycode":null,"group":"other","l10nId":"zen-full-zoom-reset-shortcut-alt","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_fullZoomReset","disabled":false,"reserved":false,"internal":false},{"id":"key_fullZoomReset","key":"0","keycode":null,"group":"mediaAndDisplay","l10nId":"zen-full-zoom-reset-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_fullZoomReset","disabled":false,"reserved":false,"internal":false},{"id":null,"key":"","keycode":null,"group":"other","l10nId":"zen-full-zoom-enlarge-shortcut-alt2","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_fullZoomEnlarge","disabled":false,"reserved":false,"internal":false},{"id":null,"key":"=","keycode":null,"group":"other","l10nId":"zen-full-zoom-enlarge-shortcut-alt","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_fullZoomEnlarge","disabled":false,"reserved":false,"internal":false},{"id":"key_fullZoomEnlarge","key":"+","keycode":null,"group":"mediaAndDisplay","l10nId":"zen-full-zoom-enlarge-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_fullZoomEnlarge","disabled":false,"reserved":false,"internal":false},{"id":null,"key":"","keycode":null,"group":"other","l10nId":"zen-full-zoom-reduce-shortcut-alt-b","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_fullZoomReduce","disabled":false,"reserved":false,"internal":false},{"id":null,"key":"_","keycode":null,"group":"other","l10nId":"zen-full-zoom-reduce-shortcut-alt-a","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_fullZoomReduce","disabled":false,"reserved":false,"internal":false},{"id":"key_fullZoomReduce","key":"-","keycode":null,"group":"mediaAndDisplay","l10nId":"zen-full-zoom-reduce-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_fullZoomReduce","disabled":false,"reserved":false,"internal":false},{"id":"key_gotoHistory","key":"h","keycode":null,"group":"navigation","l10nId":"zen-history-sidebar-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"toggleSidebarKb","key":"z","keycode":null,"group":"other","l10nId":"zen-toggle-sidebar-shortcut","modifiers":{"control":true,"alt":false,"shift":false,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"viewGenaiChatSidebarKb","key":"x","keycode":null,"group":"other","l10nId":"zen-ai-chatbot-sidebar-shortcut","modifiers":{"control":true,"alt":false,"shift":false,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_stop_mac","key":".","keycode":null,"group":"other","l10nId":"zen-nav-stop-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:Stop","disabled":false,"reserved":false,"internal":false},{"id":"key_stop","key":"","keycode":"","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"Browser:Stop","disabled":false,"reserved":false,"internal":false},{"id":"viewBookmarksToolbarKb","key":"b","keycode":null,"group":"other","l10nId":"zen-bookmark-show-toolbar-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"viewBookmarksSidebarKb","key":"b","keycode":null,"group":"other","l10nId":"zen-bookmark-show-sidebar-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"manBookmarkKb","key":"o","keycode":null,"group":"historyAndBookmarks","l10nId":"zen-bookmark-show-library-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"Browser:ShowAllBookmarks","disabled":false,"reserved":false,"internal":false},{"id":"bookmarkAllTabsKb","key":"","keycode":"","group":"historyAndBookmarks","l10nId":"zen-bookmark-this-page-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"addBookmarkAsKb","key":"d","keycode":null,"group":"historyAndBookmarks","l10nId":"zen-bookmark-this-page-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:AddBookmarkAs","disabled":false,"reserved":false,"internal":false},{"id":null,"keycode":"VK_F3","group":"other","l10nId":"zen-search-find-again-shortcut-prev","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":false},"action":"cmd_findPrevious","disabled":false,"reserved":false,"internal":false},{"id":null,"keycode":"VK_F3","group":"other","l10nId":"zen-search-find-again-shortcut-alt","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_findAgain","disabled":false,"reserved":false,"internal":false},{"id":"key_findSelection","key":"e","keycode":null,"group":"other","l10nId":"zen-search-find-selection-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_findSelection","disabled":false,"reserved":false,"internal":false},{"id":"key_findPrevious","key":"g","keycode":null,"group":"searchAndFind","l10nId":"zen-search-find-again-shortcut-prev","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"cmd_findPrevious","disabled":false,"reserved":false,"internal":false},{"id":"key_findAgain","key":"g","keycode":null,"group":"searchAndFind","l10nId":"zen-search-find-again-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_findAgain","disabled":false,"reserved":false,"internal":false},{"id":"key_find","key":"f","keycode":null,"group":"searchAndFind","l10nId":"zen-find-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_find","disabled":false,"reserved":false,"internal":false},{"id":"key_viewInfo","key":"i","keycode":null,"group":"pageOperations","l10nId":"zen-page-info-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"View:PageInfo","disabled":false,"reserved":false,"internal":false},{"id":"key_viewSourceSafari","key":"u","keycode":null,"group":"other","l10nId":"zen-page-source-shortcut-safari","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"View:PageSource","disabled":false,"reserved":false,"internal":false},{"id":"key_viewSource","key":"u","keycode":null,"group":"pageOperations","l10nId":"zen-page-source-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"View:PageSource","disabled":false,"reserved":false,"internal":false},{"id":"key_aboutProcesses","keycode":"VK_ESCAPE","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":false},"action":"View:AboutProcesses","disabled":false,"reserved":false,"internal":false},{"id":"key_reload_skip_cache","key":"r","keycode":null,"group":"navigation","l10nId":"zen-nav-reload-shortcut-skip-cache","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"Browser:ReloadSkipCache","disabled":false,"reserved":false,"internal":false},{"id":"key_reload","key":"r","keycode":null,"group":"navigation","l10nId":"zen-nav-reload-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:Reload","disabled":false,"reserved":false,"internal":false},{"id":null,"key":"}","keycode":null,"group":"other","l10nId":"zen-picture-in-picture-toggle-shortcut-mac-alt","modifiers":{"control":false,"alt":true,"shift":true,"meta":false,"accel":true},"action":"View:PictureInPicture","disabled":false,"reserved":false,"internal":false},{"id":"key_togglePictureInPicture","key":"]","keycode":null,"group":"other","l10nId":"zen-picture-in-picture-toggle-shortcut-mac","modifiers":{"control":false,"alt":true,"shift":true,"meta":false,"accel":true},"action":"View:PictureInPicture","disabled":false,"reserved":false,"internal":false},{"id":"key_toggleReaderMode","key":"r","keycode":null,"group":"pageOperations","l10nId":"zen-reader-mode-toggle-shortcut-other","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"View:ReaderView","disabled":true,"reserved":false,"internal":false},{"id":"key_exitFullScreen_compat","keycode":"VK_F11","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"View:FullScreen","disabled":true,"reserved":true,"internal":false},{"id":"key_exitFullScreen_old","key":"f","keycode":null,"group":"other","l10nId":"zen-full-screen-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"View:FullScreen","disabled":true,"reserved":true,"internal":false},{"id":"key_exitFullScreen","key":"f","keycode":null,"group":"other","l10nId":"zen-full-screen-shortcut","modifiers":{"control":true,"alt":false,"shift":false,"meta":false,"accel":true},"action":"View:FullScreen","disabled":true,"reserved":true,"internal":false},{"id":"key_enterFullScreen_compat","keycode":"VK_F11","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"View:FullScreen","disabled":false,"reserved":false,"internal":false},{"id":"key_enterFullScreen_old","key":"f","keycode":null,"group":"other","l10nId":"zen-full-screen-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"View:FullScreen","disabled":false,"reserved":false,"internal":false},{"id":"key_enterFullScreen","key":"f","keycode":null,"group":"other","l10nId":"zen-full-screen-shortcut","modifiers":{"control":true,"alt":false,"shift":false,"meta":false,"accel":true},"action":"View:FullScreen","disabled":false,"reserved":false,"internal":false},{"id":"showAllHistoryKb","key":"y","keycode":null,"group":"other","l10nId":"zen-history-show-all-shortcut-mac","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:ShowAllHistory","disabled":false,"reserved":false,"internal":false},{"id":null,"keycode":"VK_F5","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"Browser:Reload","disabled":false,"reserved":false,"internal":false},{"id":"goHome","keycode":"VK_HOME","group":"navigation","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"goForwardKb2","key":"]","keycode":null,"group":"navigation","l10nId":"zen-nav-fwd-shortcut-alt","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:Forward","disabled":false,"reserved":false,"internal":false},{"id":"goBackKb2","key":"[","keycode":null,"group":"navigation","l10nId":"zen-nav-back-shortcut-alt","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:Back","disabled":false,"reserved":false,"internal":false},{"id":"goForwardKb","keycode":"VK_RIGHT","group":"navigation","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:Forward","disabled":false,"reserved":false,"internal":false},{"id":"goBackKb","keycode":"VK_LEFT","group":"navigation","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:Back","disabled":false,"reserved":false,"internal":false},{"id":null,"keycode":"VK_BACK","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":false},"action":"cmd_handleShiftBackspace","disabled":false,"reserved":false,"internal":false},{"id":null,"keycode":"VK_BACK","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_handleBackspace","disabled":false,"reserved":false,"internal":false},{"id":"key_selectAll","key":"a","keycode":null,"group":"other","l10nId":"zen-text-action-select-all-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_delete","keycode":"VK_DELETE","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_delete","disabled":false,"reserved":false,"internal":false},{"id":"key_paste","key":"v","keycode":null,"group":"other","l10nId":"zen-text-action-paste-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_copy","key":"c","keycode":null,"group":"other","l10nId":"zen-text-action-copy-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_cut","key":"x","keycode":null,"group":"other","l10nId":"zen-text-action-cut-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_redo","key":"z","keycode":null,"group":"other","l10nId":"zen-text-action-undo-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_undo","key":"z","keycode":null,"group":"other","l10nId":"zen-text-action-undo-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":true},{"id":"key_toggleMute","key":"m","keycode":null,"group":"mediaAndDisplay","l10nId":"zen-mute-toggle-shortcut","modifiers":{"control":true,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_toggleMute","disabled":false,"reserved":false,"internal":false},{"id":"key_closeWindow","key":"w","keycode":null,"group":"windowAndTabManagement","l10nId":"zen-close-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"cmd_closeWindow","disabled":false,"reserved":true,"internal":false},{"id":"key_close","key":"w","keycode":null,"group":"windowAndTabManagement","l10nId":"zen-close-tab-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_close","disabled":false,"reserved":true,"internal":false},{"id":"printKb","key":"p","keycode":null,"group":"pageOperations","l10nId":"zen-print-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_print","disabled":false,"reserved":false,"internal":false},{"id":"key_savePage","key":"s","keycode":null,"group":"pageOperations","l10nId":"zen-save-page-shortcut","modifiers":{"control":false,"alt":true,"shift":true,"meta":false,"accel":true},"action":"Browser:SavePage","disabled":false,"reserved":false,"internal":false},{"id":"openFileKb","key":"","keycode":"","group":"other","l10nId":"zen-file-open-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"Browser:OpenFile","disabled":false,"reserved":false,"internal":false},{"id":"key_openAddons","key":"a","keycode":null,"group":"other","l10nId":"zen-addons-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"Tools:Addons","disabled":false,"reserved":false,"internal":false},{"id":"key_openDownloads","key":"j","keycode":null,"group":"other","l10nId":"zen-downloads-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Tools:Downloads","disabled":false,"reserved":false,"internal":false},{"id":"key_search2","key":"f","keycode":null,"group":"searchAndFind","l10nId":"zen-find-shortcut","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"Tools:Search","disabled":false,"reserved":false,"internal":false},{"id":"key_search","key":"k","keycode":null,"group":"searchAndFind","l10nId":"zen-search-focus-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Tools:Search","disabled":false,"reserved":false,"internal":false},{"id":"focusURLBar","key":"l","keycode":null,"group":"pageOperations","l10nId":"zen-location-open-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"Browser:OpenLocation","disabled":false,"reserved":false,"internal":false},{"id":"key_newNavigatorTab","key":"t","keycode":null,"group":"windowAndTabManagement","l10nId":"zen-tab-new-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_newNavigatorTabNoEvent","disabled":false,"reserved":true,"internal":false},{"id":"key_newNavigator","key":"n","keycode":null,"group":"windowAndTabManagement","l10nId":"zen-window-new-shortcut","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_newNavigator","disabled":false,"reserved":true,"internal":false},{"id":"zen-compact-mode-toggle","key":"“","keycode":"","group":"zen-compact-mode","l10nId":"zen-compact-mode-shortcut-toggle","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":false},"action":"cmd_zenCompactModeToggle","disabled":false,"reserved":false,"internal":false},{"id":"zen-compact-mode-show-sidebar","key":"s","keycode":"","group":"zen-compact-mode","l10nId":"zen-compact-mode-shortcut-show-sidebar","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"cmd_zenCompactModeShowSidebar","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-10","key":"","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-10","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch10","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-9","key":"","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-9","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch9","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-8","key":"","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-8","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch8","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-7","key":"","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-7","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch7","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-6","key":"","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-6","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch6","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-5","key":"","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-5","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch5","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-4","key":"","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-4","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch4","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-3","key":"","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-3","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch3","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-2","key":"2","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-2","modifiers":{"control":true,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch2","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-switch-1","key":"1","keycode":"","group":"zen-workspace","l10nId":"zen-workspace-shortcut-switch-1","modifiers":{"control":true,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenWorkspaceSwitch1","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-forward","key":"","keycode":"VK_RIGHT","group":"zen-workspace","l10nId":"zen-workspace-shortcut-forward","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"cmd_zenWorkspaceForward","disabled":false,"reserved":false,"internal":false},{"id":"zen-workspace-backward","key":"","keycode":"VK_LEFT","group":"zen-workspace","l10nId":"zen-workspace-shortcut-backward","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"cmd_zenWorkspaceBackward","disabled":false,"reserved":false,"internal":false},{"id":"zen-split-view-grid","key":"g","keycode":"","group":"zen-split-view","l10nId":"zen-split-view-shortcut-grid","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"cmd_zenSplitViewGrid","disabled":false,"reserved":false,"internal":false},{"id":"zen-split-view-vertical","key":"+","keycode":"","group":"zen-split-view","l10nId":"zen-split-view-shortcut-vertical","modifiers":{"control":true,"alt":false,"shift":true,"meta":false,"accel":false},"action":"cmd_zenSplitViewVertical","disabled":false,"reserved":false,"internal":false},{"id":"zen-split-view-horizontal","key":"_","keycode":"","group":"zen-split-view","l10nId":"zen-split-view-shortcut-horizontal","modifiers":{"control":true,"alt":false,"shift":true,"meta":false,"accel":false},"action":"cmd_zenSplitViewHorizontal","disabled":false,"reserved":false,"internal":false},{"id":"zen-split-view-unsplit","key":"u","keycode":"","group":"zen-split-view","l10nId":"zen-split-view-shortcut-unsplit","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"cmd_zenSplitViewUnsplit","disabled":false,"reserved":false,"internal":false},{"id":"zen-pinned-tab-reset-shortcut","key":"","keycode":"","group":"zen-other","l10nId":"zen-pinned-tab-shortcut-reset","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenPinnedTabReset","disabled":false,"reserved":false,"internal":false},{"id":"zen-toggle-sidebar","key":"","keycode":"","group":"zen-other","l10nId":"zen-sidebar-shortcut-toggle","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"cmd_zenToggleSidebar","disabled":false,"reserved":false,"internal":false},{"id":"zen-copy-url","key":"c","keycode":"","group":"zen-other","l10nId":"zen-text-action-copy-url-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"cmd_zenCopyCurrentURL","disabled":false,"reserved":false,"internal":false},{"id":"zen-copy-url-markdown","key":"c","keycode":"","group":"zen-other","l10nId":"zen-text-action-copy-url-markdown-shortcut","modifiers":{"control":false,"alt":true,"shift":true,"meta":false,"accel":true},"action":"cmd_zenCopyCurrentURLMarkdown","disabled":false,"reserved":false,"internal":false},{"id":"zen-toggle-pin-tab","key":"d","keycode":"","group":"zen-other","l10nId":"zen-toggle-pin-tab-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"cmd_zenTogglePinTab","disabled":false,"reserved":false,"internal":false},{"id":"zen-glance-expand","key":"o","keycode":"","group":"zen-other","l10nId":"","modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":true},"action":"cmd_zenGlanceExpand","disabled":false,"reserved":false,"internal":false},{"id":"zen-new-empty-split-view","key":"*","keycode":"","group":"zen-split-view","l10nId":"zen-new-empty-split-view-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"cmd_zenNewEmptySplit","disabled":false,"reserved":false,"internal":false},{"id":"zen-close-all-unpinned-tabs","key":"k","keycode":"","group":"zen-workspace","l10nId":"zen-close-all-unpinned-tabs-shortcut","modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":"cmd_zenCloseUnpinnedTabs","disabled":false,"reserved":false,"internal":false},{"id":"key_inspectorMac","key":"l","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_accessibility","keycode":"VK_F12","group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_dom","key":"w","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_storage","keycode":"VK_F9","group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_performance","keycode":"VK_F5","group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_styleeditor","keycode":"VK_F7","group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":false},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_netmonitor","key":"e","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_jsdebugger","key":"z","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_webconsole","key":"k","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_inspector","key":"l","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_responsiveDesignMode","key":"m","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_browserConsole","key":"j","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":true,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_browserToolbox","key":"i","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":true,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"key_toggleToolbox","key":"i","keycode":null,"group":"devTools","l10nId":null,"modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":null,"disabled":false,"reserved":false,"internal":false},{"id":"zen-new-unsynced-window","key":"n","keycode":"","group":"zen-other","l10nId":"zen-new-unsynced-window-shortcut","modifiers":{"control":false,"alt":true,"shift":false,"meta":false,"accel":true},"action":"cmd_zenNewNavigatorUnsynced","disabled":false,"reserved":false,"internal":false},{"id":"key_reload2","keycode":"VK_F5","group":"other","l10nId":null,"modifiers":{"control":false,"alt":false,"shift":false,"meta":false,"accel":false},"action":"Browser:Reload","disabled":false,"reserved":false,"internal":false}]}
                    '';

                    "${profileGlob}/userContent.css" = lib.mkIf (builtins.pathExists "${themeFiles}/userContent.css") {
                        source = "${themeFiles}/userContent.css";
                        recursive = false;
                    };
                }
            );

            # Activation scripts
            activation = activationScripts;
        };
    };
}
