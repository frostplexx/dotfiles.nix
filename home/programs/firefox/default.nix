{
  pkgs,
  lib,
  ...
}: let
  buildFirefoxXpiAddon = lib.makeOverridable ({
    stdenv ? pkgs.stdenv,
    fetchurl ? pkgs.fetchurl,
    pname,
    version,
    addonId,
    url,
    sha256,
    ...
  }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";
      src = fetchurl {inherit url sha256;};
      preferLocalBuild = true;
      allowSubstitutes = true;
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });

  extra-addons = {
    catppuccin = buildFirefoxXpiAddon {
      pname = "catppuccin";
      version = "2.0";
      addonId = "{8446b178-c865-4f5c-8ccc-1d7887811ae3}";
      url = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_lavender.xpi";
      sha256 = "cCkrC4ZSy6tAjRXSYdxRUPaQ+1u6+W9OcxclbH2beTM=";
    };
  };
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      # https://nur.nix-community.org/repos/rycee/
      extensions = with pkgs.nur.repos.rycee.firefox-addons // extra-addons; [
        onepassword-password-manager
        darkreader
        don-t-fuck-with-paste
        facebook-container
        return-youtube-dislikes
        sponsorblock
        ublock-origin
        vimium
        catppuccin
        # adaptive-tab-bar-colour
      ];
      settings = {
        "app.update.auto" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.warnOnQuit" = false;
        "browser.quitShortcut.disabled" = false;
        "browser.theme.dark-private-windows" = true;
        "browser.toolbars.bookmarks.visibility" = false;
        "browser.theme.toolbar-theme" = 0; # 0 for dark, 1 for light
        "browser.startup.page" = 3; # Restore previous session
        "trailhead.firstrun.didSeeAboutWelcome" = true; # Disable welcome splash
        "dom.forms.autocomplete.formautofill" = false; # Disable autofill
        "extensions.formautofill.creditCards.enabled" = false; # Disable credit cards
        "dom.payments.defaults.saveAddress" = false; # Disable address save
        "general.autoScroll" = true; # Drag middle-mouse to scroll
        "services.sync.prefs.sync.general.autoScroll" = false; # Prevent disabling autoscroll
        "extensions.pocket.enabled" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Allow userChrome.css
        "layout.css.color-mix.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true; # Enable hardware video acceleration
        "cookiebanners.ui.desktop.enabled" = true; # Reject cookie popups
        "devtools.command-button-screenshot.enabled" = true; # Scrolling screenshot of entire page
        "browser.tabs.hoverPreview.enabled" = true; # Enable tab previews
        "browser.tabs.hoverPreview.showThumbnails" = true; # Enable tab previews
        "sidebar.verticalTabs" = true; # Enable vertical tabs
        "browser.compactmode.show" = true; # Enable compact mode
        "browser.search.suggest.enabled" = true;
        "browser.search.suggest.enabled.private" = false;
        "browser.sessionstore.enabled" = true;
        "browser.sessionstore.resume_from_crash" = true;
        "browser.sessionstore.resume_session_once" = true;
        "general.smoothScroll" = true;
        "browser.tabs.tabmanager.enabled" = false;
        "browser.urlbar.suggest.searches" = true;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.addons" = false;
        "browser.urlbar.suggest.pocket" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.newtabpage.enabled" = true;
        "browser.newtabpage.activity-stream.showSearch" = true;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar" = false;
        "extensions.activeThemeID" = "{8446b178-c865-4f5c-8ccc-1d7887811ae3}";

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
        ];
      };
      search = {
        force = true;
        default = "Kagi";
        engines = {
          "Kagi" = {
            urls = [
              {
                template = "https://kagi.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@k"];
          };
        };
      };
      # userChrome =
      #   if pkgs.stdenv.isDarwin
      #   then builtins.readFile ./userChrome.css
      #   else "";
      # userContent =
      #   if pkgs.stdenv.isDarwin
      #   then builtins.readFile ./userContent.css
      #   else "";
      #
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
