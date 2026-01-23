{
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

    # "adnauseam@rednoise.org" = {
    #   name = "AdNauseam";
    #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/adnauseam/latest.xpi";
    #   installation_mode = "force_installed";
    #   private_browsing = true;
    # };
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
      ExtensionSettings = lib.mapAttrs (_id: ext:
        builtins.removeAttrs ext ["name"])
      extensions;

      # Search engines
      SearchEngines = {
        Default = "DuckDuckGo";
        PreventInstalls = false;
        Remove = ["Bing" "Ecosia" "Google" "Wikipedia (en)"];
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
  activationScripts = import ./activation.nix {
    inherit lib;
    inherit policyJsonPathZen zenProfilesPath policyJson userJsContent;
    inherit enableCustomTheme catppuccinPalette catppuccinAccent themeFiles;
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
    file = lib.mkIf enableCustomTheme (let
      profileGlob =
        if pkgs.stdenv.isDarwin
        then "Library/Application Support/zen/Profiles/*default*/chrome"
        else ".zen/*default*/chrome";
    in {
      "${profileGlob}/userChrome.css" = {
        source = "${themeFiles}/userChrome.css";
        recursive = false;
      };

      "${profileGlob}/userContent.css" = lib.mkIf (builtins.pathExists "${themeFiles}/userContent.css") {
        source = "${themeFiles}/userContent.css";
        recursive = false;
      };
    });

    # Activation scripts
    activation = activationScripts;
  };
}
