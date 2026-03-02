_: {
  flake.modules.homeManager.zen_browser =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.default-browser = lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        browser = "zen";
      };

      # https://github.com/0xc000022070/zen-browser-flake
      programs.zen-browser =
        let

          # Use policy.json for installing extensions because its robuster and not dependent on a
          # third part flake
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
        in
        {
          enable = true;

          profiles."default" =
            let
              containers = {
                Personal = {
                  color = "purple";
                  icon = "fingerprint";
                  id = 1;
                };
                Work = {
                  color = "blue";
                  icon = "briefcase";
                  id = 2;
                };
              };

              spaces = {
                "Default" = {
                  id = "c6de089c-410d-4206-961d-ab11f988d40a";
                  icon = "chrome://browser/skin/zen-icons/selectable/squares.svg";
                  container = containers."Personal".id;
                  position = 1000;
                  theme = {
                    type = "gradient";
                    colors = [
                      {
                        red = 30;
                        green = 30;
                        blue = 27;
                        algorithm = "floating";
                        type = "explicit-lightness";
                      }
                    ];
                    opacity = 0.8;
                    texture = 0.1;
                  };
                };
                "Uni" = {
                  id = "cdd10fab-4fc5-494b-9041-325e5759195b";
                  icon = "chrome://browser/skin/zen-icons/selectable/school.svg";
                  container = containers."Work".id;
                  position = 2000;
                  theme = {
                    type = "gradient";
                    colors = [
                      {
                        red = 166;
                        green = 227;
                        blue = 161;
                        algorithm = "floating";
                        type = "explicit-lightness";
                      }
                    ];
                    opacity = 0.5;
                    texture = 0.5;
                  };
                };
              };

              pins = {
                "Github" = {
                  id = "9d8a8f91-7e29-4688-ae2e-da4e49d4a179";
                  container = containers.Personal.id;
                  workspace = spaces.Default.id;
                  url = "https://github.com";
                  isEssential = true;
                  position = 101;
                };
                "DuckAI" = {
                  id = "8af62707-0722-4049-9801-bedced343333";
                  container = containers.Personal.id;
                  workspace = spaces.Default.id;
                  url = "https://duck.ai";
                  isEssential = true;
                  position = 102;
                };
                "HomeAssistant" = {
                  id = "fb316d70-2b5e-4c46-bf42-f4e82d635153";
                  container = containers.Personal.id;
                  workspace = spaces.Default.id;
                  url = "http://homeassistant.local:8123";
                  isEssential = true;
                  position = 103;
                };

                "Moodle" = {
                  id = "d85a9026-1458-4db6-b115-346746bcc692";
                  container = containers.Work.id;
                  workspace = spaces."Uni".id;
                  url = "http://moodle.lmu.de";
                  isEssential = true;
                  position = 101;
                };

                "Raumfinder" = {
                  id = "FE9211FA-611B-446A-AC44-AB39D12DEE5E";
                  url = "https://www.lmu.de/raumfinder/index.html#/";
                  container = containers.Work.id;
                  workspace = spaces."Uni".id;
                  isEssential = true;
                  position = 102;
                };

                "LSF" = {
                  id = "596738FB-39B4-42E8-9BC2-826E71C06CAB";
                  url = "https://lsf.verwaltung.uni-muenchen.de";
                  container = containers.Work.id;
                  workspace = spaces."Uni".id;
                  isEssential = true;
                  position = 103;
                };
              };
            in
            {
              inherit containers spaces pins;
              spacesForce = true;
              containersForce = true;
              pinsForce = false;

              # Get Key IDs using jq -c '.shortcuts[] | {id, key, keycode, action}' ~/Library/Application\ Support/Zen/Profiles/default/zen-keyboard-shortcuts.json | fzf
              keyboardShortcuts = [
                # Change compact mode toggle to Ctrl+Alt+S
                {
                  id = "zen-compact-mode-toggle";
                  key = "[";
                  modifiers = {
                    control = false;
                    alt = true;
                  };
                }
                {
                  id = "zen-split-view-vertical";
                  key = "+";
                  modifiers = {
                    control = true;
                    alt = false;
                  };
                }

                {
                  id = "zen-split-view-horizontal";
                  key = "_";
                  modifiers = {
                    control = true;
                    alt = false;
                  };
                }
                # Disable the quit shortcut to prevent accidental closes
                {
                  id = "key_quitApplication";
                  disabled = true;
                }
              ];
              # Fails activation on schema changes to detect potential regressions
              # Find this in about:config or prefs.js of your profile
              keyboardShortcutsVersion = 16;

              settings = {
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
              };

              search = {
                force = true; # Needed for nix to overwrite search settings on rebuild
                default = "ddg"; # Aliased to duckduckgo, see other aliases in the link above
                engines = {
                  # My NixOS Option and package search shortcut
                  mynixos = {
                    name = "My NixOS";
                    urls = [
                      {
                        template = "https://mynixos.com/search?q={searchTerms}";
                        params = [
                          {
                            name = "query";
                            value = "searchTerms";
                          }
                        ];
                      }
                    ];

                    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    definedAliases = [ "@nx" ]; # Keep in mind that aliases defined here only work if they start with "@"
                  };
                };
              };
            };

          policies = {
            ExtensionSettings = lib.mapAttrs (_id: ext: builtins.removeAttrs ext [ "name" ]) extensions;
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
            EnableTrackingProtection = {
              Value = true;
              Locked = true;
              Cryptomining = true;
              Fingerprinting = true;
              EmailTracking = true;
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
              History = false;
              Sessions = false;
              SiteSettings = false;
              OfflineApps = true;
              Locked = true;
            };
          };
        };
    };
}
