{
  pkgs,
  lib,
  ...
}: let
  policyJsonPathZen =
    if pkgs.stdenv.isDarwin
    then "/Applications/Zen.app/Contents/Resources/distribution"
    else "/etc/zen/policies";

  policyJsonPathFirefox =
    if pkgs.stdenv.isDarwin
    then "/Applications/Firefox.app/Contents/Resources/distribution"
    else "/etc/firefox/policies";

  policyJson = {
    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          # 1Password
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
        "clipper@obsidian.md" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/web-clipper-obsidian/latest.xpi";
          installation_mode = "force_installed";
        };
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          # Vimium
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          installation_mode = "force_installed";
        };
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
          # Refined GitHub
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}/latest.xpi";
          installation_mode = "force_installed";
        };

        "containerise@kinte.sh" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/containerise/latest.xpi";
          installation_mode = "force_installed";
        };
      };
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

      OfferToSaveLogins = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
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

      Preferences = {
        "browser.tabs.warnOnClose" = {
          Value = true;
          Status = "locked";
        };

        # Some of these dont work because firefox stupid :(
        # Policies: Unable to set preference zen.glance.activation-method. Preference not allowed for stability reasons.
        # Policies: Unable to set preference zen.theme.accent-color. Preference not allowed for stability reasons.
        # ...
        "zen.glance.activation-method" = {
          Value = "shift";
          Status = "locked";
        };

        "zen.theme.gradient.show-custom-colors" = {
          Value = true;
          Status = "locked";
        };

        "zen.welcome-screen.seen" = {
          Value = true;
          Status = "locked";
        };

        "zen.theme.accent-color" = {
          Value = "#BE89FF";
          Status = "locked";
        };

        "zen.view.compact.should-enable-at-startup" = {
          Value = true;
          Status = "locked";
        };

        "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = {
          Value = true;
          Status = "locked";
        };
      };
    };
  };
in {
  # Create the policy directory and file using Home Manager activation
  home.activation.zenBrowserPolicy = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${policyJsonPathZen}
    echo '${builtins.toJSON policyJson}' > ${policyJsonPathZen}/policies.json

    mkdir -p ${policyJsonPathFirefox}
    echo '${builtins.toJSON policyJson}' > ${policyJsonPathFirefox}/policies.json
  '';
}
