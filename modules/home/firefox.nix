_: {
  flake.homeManagerModules.firefox = {
    lib,
    pkgs,
    ...
  } @ args: let
    aeroTheme = args.aeroTheme or false;
    enabled = !pkgs.stdenv.hostPlatform.isDarwin && aeroTheme;

    containers = {
      Personal = {
        color = "purple";
        icon = "fingerprint";
        id = 1;
      };
      Coding = {
        color = "green";
        icon = "circle";
        id = 3;
      };
      Work = {
        color = "blue";
        icon = "briefcase";
        id = 2;
      };
    };

    extensions = {
      "uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "normal_installed";
        private_browsing = true;
      };

      "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
        installation_mode = "normal_installed";
        private_browsing = true;
      };
      "clipper@obsidian.md" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/web-clipper-obsidian/latest.xpi";
        installation_mode = "normal_installed";
      };
      "sponsorBlocker@ajay.app" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        installation_mode = "normal_installed";
      };
      "addon@darkreader.org" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        installation_mode = "normal_installed";
      };
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
        installation_mode = "normal_installed";
      };
      "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}/latest.xpi";
        installation_mode = "normal_installed";
      };
    };

    # https://github.com/Glitchcode2447/Firefox-Australis-Theme
    # Read the file into a string: the firefox module's userChrome option
    # coerces store paths to their string form, which would write the path
    # instead of the CSS content.
    australisCss = builtins.readFile (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/Glitchcode2447/Firefox-Australis-Theme/master/userChrome.css";
      sha256 = "sha256-z6b0fqRzG9NMnFEkxhfCE9Ic48yTs/Pp6ZrsqW+7Rzw=";
    });
  in {
    programs.firefox = {
      enable = enabled;
      profiles."default" = {
        inherit containers;
        containersForce = true;
        userChrome = australisCss;

        settings = {
          # Required for userChrome.css to load
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          # Use server-side (KWin/Aero) window decorations instead of
          # Firefox's own GNOME-style titlebar.
          "browser.tabs.inTitlebar" = 0;

          # General preferences
          "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
          "browser.tabs.warnOnClose" = true;

          "privacy.resistFingerprinting" = true;

          # Never clear history or site data when Firefox closes
          "privacy.sanitize.sanitizeOnShutdown" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.formdata" = false;
          "privacy.clearOnShutdown_v2.siteSettings" = false;
        };

        search = {
          force = true; # Needed for nix to overwrite search settings on rebuild
          default = "unduckified"; # Aliased to duckduckgo, see other aliases in the link above
          engines = {
            duckai = {
              name = "DuckAI";
              urls = [
                {
                  template = "https://duckduckgo.com/?t=ffab&ia=chat&q=%s";
                  params = [
                  ];
                }
              ];
              definedAliases = ["@ai"];
            };

            unduckified = {
              name = "Unduckified";
              urls = [
                {
                  template = "https://s.dunkirk.sh?q={searchTerms}";
                  params = [
                    {
                      name = "query";
                      value = "searchTerms";
                    }
                  ];
                }
                {
                  type = "application/x-suggestions+json";
                  template = "https://s.dunkirk.sh/suggest?q={searchTerms}";
                }
              ];

              # icon = lg";
              definedAliases = ["@uddg"]; # Keep in mind that aliases defined here only work if they start with "@"
            };

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
              definedAliases = ["@nx"]; # Keep in mind that aliases defined here only work if they start with "@"
            };
          };
        };
      };

      policies = {
        ExtensionSettings = extensions;
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
          WebSuggestions = true;
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
        ExtensionUpdate = true;
        SearchBar = "unified";
      };
    };

    # Firefox draws its own GNOME-style titlebar on Wayland (and KDE X11)
    # because GetSystemGtkWindowDecoration() forces GTK_DECORATION_CLIENT.
    # `MOZ_GTK_TITLEBAR_DECORATION=system` is checked first and overrides to
    # server-side decorations, so KWin renders the Aero titlebar.
    # We set it through plasma-workspace/env because home.sessionVariables only
    # reaches login shells, not SDDM-launched graphical sessions.
    xdg.configFile."plasma-workspace/env/10-firefox-aero.sh" = lib.mkIf enabled {
      text = "export MOZ_GTK_TITLEBAR_DECORATION=system\n";
    };
  };
}
