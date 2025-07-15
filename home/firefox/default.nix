{pkgs, ...}: {
    # Enable and configure the default browser
    imports = [
        ./zen.nix
    ];
    programs = {
        # default-browser = {
        #     enable = true;
        #     browser = "zen";
        # };
        #

        firefox = {
            enable = true;
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

            ExtensionSettings = {
                "uBlock0@raymondhill.net" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                    installation_mode = "force_installed";
                    private_browsing = true;
                };
                "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
                    installation_mode = "force_installed";
                    private_browsing = true;
                };
                "clipper@obsidian.md" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/web-clipper-obsidian/latest.xpi";
                    installation_mode = "force_installed";
                };
                "jid1-ZAdIEUB7XOzOJw@jetpack" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
                    installation_mode = "force_installed";
                };
                "sponsorBlocker@ajay.app" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
                    installation_mode = "force_installed";
                };
                "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
                    installation_mode = "force_installed";
                };
                "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}/latest.xpi";
                    installation_mode = "force_installed";
                };
            };
            };
            profiles.default = {
                id = 0;
                name = "default";
                isDefault = true;
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

                };
                extraConfig = "";
            };
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
