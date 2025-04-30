{
    pkgs,
    inputs,
    ...
}: {
    imports = [inputs.betterfox.homeManagerModules.betterfox];
    # Enable and configure the default browser
    programs.default-browser = {
        enable = true;
        browser = "firefox";
    };
    programs.firefox = {
        enable = true;
        betterfox = {
            enable = true;
        };
        # Managed using homebrew on macos
        package =
            if pkgs.stdenv.isLinux
            then pkgs.firefox-bin
            else null;
        policies = {
            AppAutoUpdate = false;
            BackgroundAppUpdate = false;

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
            DisplayBookmarksToolbar = "default-off";
            DisablePocket = true;
            DisableTelemetry = true;
            DisableFormHistory = true;
            DisablePasswordReveal = true;
            DontCheckDefaultBrowser = true;

            OfferToSaveLogins = false;
            EnableTrackingProtection = {
                Value = true;
                Locked = true;
                Cryptomining = true;
                Fingerprinting = true;
                EmailTracking = true;
            };
            DefaultDownloadDirectory = "$HOME/Downloads";
            OverrideFirstRunPage = "";
            OverridePostUpdatePage = "";
            ExtensionUpdate = false;
            SearchBar = "unified";

            FirefoxSuggest = {
                WebSuggestions = false;
                SponsoredSuggestions = false;
                ImproveSuggest = false;
                Locked = true;
            };

            Handlers = {
                mimeTypes."application/pdf".action = "saveToDisk";
            };
            PasswordManagerEnabled = false;
            PromptForDownloadLocation = false;

            SanitizeOnShutdown = {
                Cache = true;
                Cookies = false;
                Downloads = false;
                FormData = true;
                History = false;
                Sessions = false;
                SiteSettings = false;
                OfflineApps = true;
                Locked = true;
            };

            SearchEngines = {
                PreventInstalls = true;
                Remove = [
                    "Bing"
                ];
                Default = "DuckDuckGo";
            };
            SearchSuggestEnabled = false;
        };
        profiles.default = {
            id = 0;
            name = "default";
            isDefault = true;
            betterfox = {
                enable = true;
                enableAllSections = true;
            };
            # https://nur.nix-community.org/repos/rycee/
            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
                onepassword-password-manager
                # darkreader
                refined-github
                don-t-fuck-with-paste
                return-youtube-dislikes
                sponsorblock
                ublock-origin
                vimium
            ];
            # containers = {
            #     "Default" = {
            #         id = 1;
            #         color = "blue";
            #         icon = "chill";
            #     };
            #     "Uni" = {
            #         id = 2;
            #         color = "green";
            #         icon = "fence";
            #     };
            # };
            settings = {
                #Dark reader settings
                "extensions.darkreader.enabled" = true;

                # Enable new UI
                "extensions.darkreader.experimental.enableNewUI" = true;
                "extensions.darkreader.experimental.previewNewDesign" = true;
                "extensions.darkreader.enableContextMenus" = true;

                # Set auto time mode
                "extensions.darkreader.automation.enabled" = true;
                "extensions.darkreader.automation.start" = "18:00";
                "extensions.darkreader.automation.end" = "9:00";

                "extensions.darkreader.changeBrowserTheme" = false;

                # Basic theme settings (recommended defaults)
                "extensions.darkreader.theme.brightness" = 100;
                "extensions.darkreader.theme.contrast" = 100;
                "extensions.darkreader.theme.sepia" = 0;

                # Make sidebar not shit
                "sidebar.verticalTabs" = true;
                "browser.uiCustomization.navBarWhenVerticalTabs" = [
                    "back-button"
                    "forward-button"
                    "urlbar-container"
                    "vertical-spacer"
                    "ublock0_raymondhill_net-browser-action"
                    "unified-extensions-button"
                    "reset-pbm-toolbar-button"
                ];
                "browser.ml.chat.sidebar" = false;
                "sidebar.main.tools" = "";
                "browser.shopping.experience2023.shoppingSidebar" = false;
                "sidebar.expandOnHover" = true;
                "sidebar.animation.expand-on-hover.duration-ms" = 50;
                "sidebar.revamp.round-content-area" = true;

                "browser.tabs.groups.enabled" = true;
                "browser.tabs.groups.smart.enabled" = true;

                "browser.newtabpage.pinned" = [
                    {
                        title = "github";
                        url = "https://www.github.com/";
                    }
                    {
                        title = "search.nixos";
                        url = "https://search.nixos.org/";
                    }
                    {
                        title = "gitlab";
                        url = "https://gitlab.lrz.de/";
                    }
                    {
                        title = "cyberchef";
                        url = "https://cyberchef.org/";
                    }
                    {
                        title = "UniFi";
                        url = "https://unifi.ui.com/";
                    }
                    {
                        title = "Home Assistant";
                        url = "https://ha.hl.kuipr.de/";
                    }
                ];

                "${pkgs.nur.repos.rycee.firefox-addons.ublock-origin.addonId}".settings = {
                    userSettings = rec {
                        advancedUserEnabled = true;
                        cloudStorageEnabled = false;
                        # collapseBlocked = false;
                        uiAccentCustom = true;
                        uiAccentCustom0 = "#ACA0F7";
                        externalLists = pkgs.lib.concatStringsSep "\n" importedLists;
                        importedLists = [
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/anti.piracy.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/doh-vpn-proxy-bypass.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/dyndns.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/fake.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/gambling.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/hoster.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/nsfw.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.mini.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/spam-tlds-ublock.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt"
                        ];
                        largeMediaSize = 250;
                        # popupPanelSections = 31;
                        tooltipsDisabled = true;
                    };
                    dynamicFilteringString = ''
                        no-cosmetic-filtering: * true
                        no-cosmetic-filtering: appleid.apple.com false
                        no-cosmetic-filtering: bing.com false
                        no-cosmetic-filtering: cnn.com false
                        no-cosmetic-filtering: google.com false
                        no-cosmetic-filtering: www.notion.com false
                        no-cosmetic-filtering: www.notion.so false
                        no-cosmetic-filtering: old.reddit.com false
                        no-cosmetic-filtering: slack.com false
                        no-cosmetic-filtering: kadena-io.slack.com false
                        no-cosmetic-filtering: twitch.tv false
                        no-cosmetic-filtering: youtube.com false
                        no-csp-reports: * true
                        no-large-media: * true
                        no-large-media: www.amazon.com false
                        no-large-media: appleid.apple.com false
                        no-large-media: login.bmwusa.com false
                        no-large-media: www.ftb.ca.gov false
                        no-large-media: www.notion.com false
                        no-large-media: www.notion.so false
                        no-large-media: old.reddit.com false
                        no-large-media: client.schwab.com false
                        no-large-media: sws-gateway-nr.schwab.com false
                        no-large-media: slack.com false
                        no-large-media: kadena-io.slack.com false
                        no-large-media: www.youtube.com false
                        no-remote-fonts: * true
                        no-remote-fonts: www.amazon.com false
                        no-remote-fonts: appleid.apple.com false
                        no-remote-fonts: login.bmwusa.com false
                        no-remote-fonts: www.ftb.ca.gov false
                        no-remote-fonts: docs.google.com false
                        no-remote-fonts: drive.google.com false
                        no-remote-fonts: gemini.google.com false
                        no-remote-fonts: notebooklm.google.com false
                        no-remote-fonts: www.google.com false
                        no-remote-fonts: kadena.latticehq.com false
                        no-remote-fonts: www.notion.com false
                        no-remote-fonts: www.notion.so false
                        no-remote-fonts: usa.onlinesrp.org false
                        no-remote-fonts: old.reddit.com false
                        no-remote-fonts: client.schwab.com false
                        no-remote-fonts: sws-gateway-nr.schwab.com false
                        no-remote-fonts: slack.com false
                        no-remote-fonts: app.slack.com false
                        no-remote-fonts: kadena-io.slack.com false
                        no-remote-fonts: www.youtube.com false
                        * * 3p-frame block
                        * * 3p-script block
                        * cloudflare.com * noop
                        www.amazon.com * 3p noop
                        www.amazon.com * 3p-frame noop
                        www.amazon.com * 3p-script noop
                        console.anthropic.com * 3p-frame noop
                        console.anthropic.com * 3p-script noop
                        appleid.apple.com * 3p-frame noop
                        appleid.apple.com * 3p-script noop
                        app.asana.com * 3p-frame noop
                        app.asana.com * 3p-script noop
                        behind-the-scene * * noop
                        behind-the-scene * 1p-script noop
                        behind-the-scene * 3p noop
                        behind-the-scene * 3p-frame noop
                        behind-the-scene * 3p-script noop
                        behind-the-scene * image noop
                        behind-the-scene * inline-script noop
                        app01.us.bill.com * 3p-frame noop
                        app01.us.bill.com * 3p-script noop
                        login.bmwusa.com * 3p-frame noop
                        login.bmwusa.com * 3p-script noop
                        www.facebook.com * 3p noop
                        www.facebook.com * 3p-frame noop
                        www.facebook.com * 3p-script noop
                        www.fidium.net * 3p-frame noop
                        www.fidium.net * 3p-script noop
                        file-scheme * 3p-frame noop
                        file-scheme * 3p-script noop
                        github.com * 3p noop
                        github.com * 3p-frame noop
                        github.com * 3p-script noop
                        accounts.google.com * 3p-frame noop
                        accounts.google.com * 3p-script noop
                        docs.google.com * 3p-frame noop
                        docs.google.com * 3p-script noop
                        drive.google.com * 3p noop
                        drive.google.com * 3p-frame noop
                        drive.google.com * 3p-script noop
                        notebooklm.google.com * 3p noop
                        notebooklm.google.com * 3p-frame noop
                        notebooklm.google.com * 3p-script noop
                        huggingface.co * 3p-frame noop
                        huggingface.co * 3p-script noop
                        kadena.latticehq.com * 3p-frame noop
                        kadena.latticehq.com * 3p-script noop
                        www.linkedin.com * 3p noop
                        www.notion.com * 3p-frame noop
                        www.notion.com * 3p-script noop
                        www.notion.so * 3p-frame noop
                        www.notion.so * 3p-script noop
                        old.reddit.com * 3p noop
                        old.reddit.com * 3p-frame noop
                        old.reddit.com * 3p-script noop
                        www.reddit.com * 3p noop
                        www.reddit.com * 3p-frame noop
                        www.reddit.com * 3p-script noop
                        respected-meat-54f.notion.site * 3p noop
                        myprofile.saccounty.gov * 3p-frame noop
                        myprofile.saccounty.gov * 3p-script noop
                        myutilities.saccounty.gov * 3p-frame noop
                        myutilities.saccounty.gov * 3p-script noop
                        client.schwab.com * 3p-frame noop
                        client.schwab.com * 3p-script noop
                        sws-gateway-nr.schwab.com * 3p-frame noop
                        sws-gateway-nr.schwab.com * 3p-script noop
                        slack.com * 3p-frame noop
                        slack.com * 3p-script noop
                        app.slack.com * 3p noop
                        app.slack.com * 3p-frame noop
                        app.slack.com * 3p-script noop
                        kadena-io.slack.com * 3p-frame noop
                        kadena-io.slack.com * 3p-script noop
                        www.tripit.com * 3p noop
                        www.tripit.com * 3p-frame noop
                        www.tripit.com * 3p-script noop
                        www.usaa.com * 3p-frame noop
                        www.usaa.com * 3p-script noop
                        secure.verizon.com * 3p-frame noop
                        secure.verizon.com * 3p-script noop
                        www.verizon.com * 3p-frame noop
                        www.verizon.com * 3p-script noop
                        www.youtube.com * 3p-frame noop
                        www.youtube.com * 3p-script noop
                    '';
                    urlFilteringString = "";
                    hostnameSwitchesString = ''
                        no-remote-fonts: * true
                        no-large-media: * true
                        no-csp-reports: * true
                        no-remote-fonts: www.ftb.ca.gov false
                        no-large-media: www.ftb.ca.gov false
                        no-remote-fonts: app.slack.com false
                        no-remote-fonts: notebooklm.google.com false
                    '';
                    userFilters = "";
                    selectedFilterLists = [
                        "user-filters"
                        "ublock-filters"
                        "ublock-badware"
                        "ublock-privacy"
                        "ublock-quick-fixes"
                        "ublock-unbreak"
                        "easylist"
                        "easyprivacy"
                        "adguard-spyware"
                        "adguard-spyware-url"
                        "urlhaus-1"
                        "plowe-0"
                        "fanboy-cookiemonster"
                        "ublock-cookies-easylist"
                        "fanboy-social"
                        "easylist-chat"
                        "easylist-newsletters"
                        "easylist-notifications"
                        "easylist-annoyances"
                        "ublock-annoyances"
                        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/hoster.txt"
                        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/fake.txt"
                        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.mini.txt"
                        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/spam-tlds-ublock.txt"
                    ];
                    whitelist = [
                        "chrome-extension-scheme"
                        "moz-extension-scheme"
                    ];
                };
            };
            extraConfig = "";
        };
    };

    # Mimic nixpkgs package environment for read-only profiles.ini management
    # From: https://github.com/booxter/home-manager/commit/dd1602e306fec366280f5953c5e1b553e3d9672a
    home.sessionVariables = {
        MOZ_LEGACY_PROFILES = 1;
        MOZ_ALLOW_DOWNGRADE = 1;
        MOZ_NO_REMOTE = "1";
    };

    # launchd.user.envVariables = config.home-manager.users.${config.user}.home.sessionVariables;

    xdg.mimeApps = {
        associations.added = {
            "text/html" = ["firefox.desktop"];
        };
        defaultApplications = {
            "text/html" = ["firefox.desktop"];
        };
        associations.removed = {
            "text/html" = ["wine-extension-htm.desktop"];
        };
    };
}
