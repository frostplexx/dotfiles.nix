_: {
  flake.homeManagerModules.zen_browser = {
    pkgs,
    lib,
    config,
    inputs,
    ...
  }: {
    targets.darwin.defaults = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "app.zen-browser.zen" =
        {
          EnterprisePoliciesEnabled = true;
        }
        // config.programs.zen-browser.policies;
    };

    # https://github.com/0xc000022070/zen-browser-flake
    programs.zen-browser = {
      # Zen is replaced by Firefox when the Aero setup is active on Linux
      enable = true;
      setAsDefaultBrowser = true;
      darwinDefaultsId = "app.zen-browser.zen";
      nativeMessagingHosts = [
        inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      profiles."default" = {
        settings = {
          # Zen-specific preferences
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

          "privacy.resistFingerprinting" = true;

          # Never clear history or site data when Zen closes
          "privacy.sanitize.sanitizeOnShutdown" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.formdata" = false;
          "privacy.clearOnShutdown_v2.siteSettings" = false;

          # Backup
          "browser.backup.archive.enabled" = true;
          "browser.backup.enabled" = true;
          "browser.backup.scheduled.enabled" = true;
          "browser.backup.scheduled.minimum-time-between-backups-seconds" = 86400;
          "browser.backup.location" = "/Users/daniel/Library/Mobile Documents/com~apple~CloudDocs/Documents/03 Resources/Backups/Zen/Restore Firefox";
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
        # Disable features
        DisableFirefoxStudies = true;
        DisableFirefoxScreenshots = true;
        DisableMasterPasswordCreation = true;
        DisableTelemetry = true;
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
      };
    };
  };
}
