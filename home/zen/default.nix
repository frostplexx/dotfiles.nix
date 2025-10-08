{
  pkgs,
  lib,
  ...
}: let
  policyJsonPathZen =
    if pkgs.stdenv.isDarwin
    then "/Applications/Zen.app/Contents/Resources/distribution"
    else "/etc/zen/policies";

  zenProfilesPath =
    if pkgs.stdenv.isDarwin
    then "$HOME/Library/Application Support/zen/Profiles"
    else "$HOME/.zen";

  # Catppuccin theme configuration
  catppuccinPalette = "Mocha";
  catppuccinAccent = "Mauve";

  # Fetch the Catppuccin Zen Browser theme repository
  catppuccinZenTheme = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zen-browser";
    rev = "c855685442c6040c4dda9c8d3ddc7b708de1cbaa";
    sha256 = "sha256-5A57Lyctq497SSph7B+ucuEyF1gGVTsuI3zuBItGfg4=";
  };

  # Extract theme files for the specified palette/accent
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

        "toolkit.legacyUserProfileCustomizations.stylesheets" = {
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
  programs.default-browser = {
    enable = true;
    browser = "zen"; # Or any other browser name
  };

  # Create the policy directory and file using Home Manager activation
  home = {
    activation.zenBrowserPolicy = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${policyJsonPathZen}
      echo '${builtins.toJSON policyJson}' > ${policyJsonPathZen}/policies.json
    '';

    # Install Catppuccin theme files directly using Home Manager
    file = let
      profileGlob =
        if pkgs.stdenv.isDarwin
        then "Library/Application Support/zen/Profiles/*default*/chrome"
        else ".zen/*default*/chrome";
    in {
      # Install userChrome.css to all profiles
      "${profileGlob}/userChrome.css" = {
        source = "${themeFiles}/userChrome.css";
        recursive = false;
      };

      # Install userContent.css if it exists
      "${profileGlob}/userContent.css" = lib.mkIf (builtins.pathExists "${themeFiles}/userContent.css") {
        source = "${themeFiles}/userContent.css";
        recursive = false;
      };
    };

    # Alternative: Create a more precise profile installation
    activation.zenBrowserThemeInstall = lib.hm.dag.entryAfter ["linkGeneration"] ''
      echo "Installing Catppuccin ${catppuccinPalette}/${catppuccinAccent} theme for Zen Browser..."

      # Find all Zen profiles and install theme
      if [ -d "${zenProfilesPath}" ]; then
          find "${zenProfilesPath}" -maxdepth 1 -type d \( -name "*default*" -o -name "*Default*" \) 2>/dev/null | while read -r profile; do
              if [ -n "$profile" ] && [ -d "$profile" ]; then
                  chrome_dir="$profile/chrome"
                  mkdir -p "$chrome_dir"

                  # Copy theme files
                  cp "${themeFiles}/userChrome.css" "$chrome_dir/" 2>/dev/null || true

                  cp "${themeFiles}/zen-logo.svg" "$chrome_dir/" 2>/dev/null || true

                  if [ -f "${themeFiles}/userContent.css" ]; then
                      cp "${themeFiles}/userContent.css" "$chrome_dir/" 2>/dev/null || true
                  fi

                  echo "Theme installed for profile: $(basename "$profile")"
              fi
          done
      else
          echo "Zen Browser profiles directory not found. Theme will be installed when profiles are created."
      fi
    '';
  };
}
