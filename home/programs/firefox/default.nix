{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      # https://nur.nix-community.org/repos/rycee/
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        onepassword-password-manager
        darkreader
        don-t-fuck-with-paste
        facebook-container
        return-youtube-dislikes
        sponsorblock
        ublock-origin
        vimium
      ];
      settings = {
        "app.update.auto" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.warnOnQuit" = false;
        "browser.quitShortcut.disabled" =
          if pkgs.stdenv.isLinux
          then true
          else false;
        "browser.theme.dark-private-windows" = true;
        "browser.toolbars.bookmarks.visibility" = false;
        "browser.startup.page" = 3; # Restore previous session
        "browser.newtabpage.enabled" = false; # Make new tabs blank
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
        "svg.context-properties.content.enabled" = true; # Sidebery styling
        "browser.tabs.hoverPreview.enabled" = false; # Disable tab previews
        "browser.tabs.hoverPreview.showThumbnails" = false; # Disable tab previews
        "sidebar.verticalTabs" = true; # Enable vertical tabs
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
      userChrome =
        if pkgs.stdenv.isDarwin
        then ''
          #TabsToolbar {
            visibility: collapse;
          }

          #titlebar {
            display: none !important;
          }

          .titlebar-buttonbox-container {
            display: none !important;
          }

          /* Calculate width based on viewport height to maintain 16:9 ratio */
          :root {
            --sixteen-nine-width: calc(100vh * (16/9));
          }

          #navigator-toolbox {
            position: fixed;
            z-index: 1000;
            height: 5px;
            /* Center the toolbar and constrain width to 16:9 ratio */
            width: min(100%, var(--sixteen-nine-width));
            left: 50%;
            transform: translateX(-50%);
            overflow: var(--is-bar-visible);
            transition: 0.1s !important;
            background-color: transparent !important;
            border-color: transparent !important;
            /* Center the toolbar contents */
            display: flex;
            justify-content: center;
            align-items: center;
          }

          #navigator-toolbox:not(:hover) {
            --is-bar-visible: hidden;
            height: 5px;
            opacity: 0 !important;
            transition: height 200ms ease-in-out, opacity 175ms ease-in-out;
          }

          #navigator-toolbox:hover {
            height: 40px;
            z-index: 1000 !important;
            opacity: 1 !important;
            transition: opacity 175ms ease-in-out;
          }

          #navigator-toolbox:focus-within {
            height: 40px;
            opacity: 1 !important;
            transition: opacity 175ms ease-in-out;
            --is-bar-visible: visible;
          }

          #PersonalToolbar {
            display: none;
          }

          toolbarbutton[open="true"] {
            --is-bar-visible: visible !important;
          }

          /* Ensure nav-bar fills the constrained width */
          #nav-bar {
            width: 100% !important;
            margin: 0 !important;
          }
        ''
        else "";
      userContent = '''';

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
