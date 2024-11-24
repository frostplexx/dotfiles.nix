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
        "browser.compactmode.show" = true; # Enable compact mode

        # Smooth scrolling
        "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
        "general.smoothScroll.msdPhysics.enabled" = true;
        "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 200;
        "general.smoothScroll.msdPhysics.regularSpringConstant" = 250;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = 2.0;
        "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
        "general.smoothScroll.currentVelocityWeighting" = 1.0;
        "general.smoothScroll.stopDecelerationWeighting" = 1.0;
        "mousewheel.system_scroll_override.horizontal.factor" = 200;
        "mousewheel.system_scroll_override.vertical.factor" = 200;
        "mousewheel.system_scroll_override_on_root_content.enabled" = true;
        "mousewheel.system_scroll_override.enabled" = true;
        "mousewheel.default.delta_multiplier_x" = 100;
        "mousewheel.default.delta_multiplier_y" = 100;
        "mousewheel.default.delta_multiplier_z" = 100;
        "apz.allow_zooming" = true;
        "apz.force_disable_desktop_zooming_scrollbars" = false;
        "apz.paint_skipping.enabled" = true;
        "apz.windows.use_direct_manipulation" = true;
        "dom.event.wheel-deltaMode-lines.always-disabled" = false;
        "general.smoothScroll.durationToIntervalRatio" = 200;
        "general.smoothScroll.lines.durationMaxMS" = 150;
        "general.smoothScroll.lines.durationMinMS" = 150;
        "general.smoothScroll.other.durationMaxMS" = 150;
        "general.smoothScroll.other.durationMinMS" = 150;
        "general.smoothScroll.pages.durationMaxMS" = 150;
        "general.smoothScroll.pages.durationMinMS" = 150;
        "general.smoothScroll.pixels.durationMaxMS" = 150;
        "general.smoothScroll.pixels.durationMinMS" = 150;
        "general.smoothScroll.scrollbars.durationMaxMS" = 150;
        "general.smoothScroll.scrollbars.durationMinMS" = 150;
        "general.smoothScroll.mouseWheel.durationMaxMS" = 200;
        "general.smoothScroll.mouseWheel.durationMinMS" = 50;
        "layers.async-pan-zoom.enabled" = true;
        "layout.css.scroll-behavior.spring-constant" = 250;
        "mousewheel.transaction.timeout" = 1500;
        "mousewheel.acceleration.factor" = 10;
        "mousewheel.acceleration.start" = -1;
        "mousewheel.min_line_scroll_amount" = 5;
        "toolkit.scrollbox.horizontalScrollDistance" = 5;
        "toolkit.scrollbox.verticalScrollDistance" = 3;
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
        then builtins.readFile ./userChrome.css
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
