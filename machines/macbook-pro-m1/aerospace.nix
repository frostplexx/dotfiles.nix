_: {
  services = {
    jankyborders = {
      enable = true;
      style = "round";
      width = 3.0;
      hidpi = true;
      active_color = "0xffcba6f7";
      inactive_color = "0xff7f849c";
    };

    aerospace = {
      enable = true;
      settings = {
        # Start AeroSpace at login
        # You dont need this when running it using nix-darwin.services
        # start-at-login = true;

        # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
        # The 'accordion-padding' specifies the size of accordion padding
        # You can set 0 to disable the padding feature
        accordion-padding = 10;

        # Possible values: tiles|accordion
        default-root-container-layout = "tiles";

        # Possible values: horizontal|vertical|auto
        # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
        #               tall monitor (anything higher than wide) gets vertical orientation
        default-root-container-orientation = "auto";

        # Mouse follows focus when focused monitor changes
        # Drop it from your config, "if" you don't like this behavior
        # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
        # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
        # Fallback value ("if" you omit the key): on-focused-monitor-changed = []
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

        # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
        # Useful "if" you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
        # Also see: https://nikitabobko.github.io/AeroSpace/goodness#disable-hide-app
        automatically-unhide-macos-hidden-apps = true;

        # Possible values: (qwerty|dvorak)
        # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
        key-mapping.preset = "qwerty";

        # Gaps between windows (inner-*) and between monitor edges (outer-*).
        # Possible values:
        # - Constant:     gaps.outer.top = 8
        # - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
        #                 In this example, 24 is a default value when there is no match.
        #                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
        #                 See: https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
        gaps = {
          inner = {
            horizontal = 5;
            vertical = 5;
          };
          outer = {
            left = 5;
            bottom = 5;
            top = 5;
            right = 5;
          };
        };

        # 'main' binding mode declaration
        # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
        # 'main' binding mode must be always presented
        # Fallback value ("if" you omit the key): mode.main.binding = {}
        mode.main.binding = {
          ctrl-alt-cmd-t = "layout tiles horizontal vertical";
          ctrl-alt-cmd-s = ["layout accordion" "layout vertical"];

          ctrl-alt-cmd-f = "fullscreen";
          alt-shift-f = ["layout floating tiling" "mode main"]; # Toggle between floating and tiling layout

          cmd-m = "macos-native-minimize";
          # cmd-shift-m = '''exec-and-forget osascript -e '
          # tell application (path to frontmost application as text)
          #     try
          #         set miniaturized of windows to false -- most applications
          #     end try
          #     try
          #         set collapsed of windows to false -- at least Finder
          #     end try
          # end tell
          # '''

          # See: https://nikitabobko.github.io/AeroSpace/commands#focus
          ctrl-alt-cmd-h = "focus left";
          ctrl-alt-cmd-j = "focus down";
          ctrl-alt-cmd-k = "focus up";
          ctrl-alt-cmd-l = "focus right";

          # See: https://nikitabobko.github.io/AeroSpace/commands#move
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          # See: https://nikitabobko.github.io/AeroSpace/commands#resize
          ctrl-alt-shift-cmd-minus = "resize smart -50";
          ctrl-alt-shift-cmd-equal = "resize smart +50";

          # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
          ctrl-alt-cmd-1 = "workspace 1";
          ctrl-alt-cmd-2 = "workspace 2";
          ctrl-alt-cmd-3 = "workspace 3";
          ctrl-alt-cmd-4 = "workspace 4";
          ctrl-alt-cmd-5 = "workspace 5";
          ctrl-alt-cmd-6 = "workspace 6";
          ctrl-alt-cmd-7 = "workspace 7";
          ctrl-alt-cmd-8 = "workspace 8";
          ctrl-alt-cmd-9 = "workspace 9";
          ctrl-alt-cmd-0 = "workspace 10";

          # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
          ctrl-alt-shift-cmd-1 = ["move-node-to-workspace 1" "workspace 1"];
          ctrl-alt-shift-cmd-2 = ["move-node-to-workspace 2" "workspace 2"];
          ctrl-alt-shift-cmd-3 = ["move-node-to-workspace 3" "workspace 3"];
          ctrl-alt-shift-cmd-4 = ["move-node-to-workspace 4" "workspace 4"];
          ctrl-alt-shift-cmd-5 = ["move-node-to-workspace 5" "workspace 5"];
          ctrl-alt-shift-cmd-6 = ["move-node-to-workspace 6" "workspace 6"];
          ctrl-alt-shift-cmd-7 = ["move-node-to-workspace 7" "workspace 7"];
          ctrl-alt-shift-cmd-8 = ["move-node-to-workspace 8" "workspace 8"];
          ctrl-alt-shift-cmd-9 = ["move-node-to-workspace 9" "workspace 9"];

          # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
          alt-tab = "focus-back-and-forth";
          # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
          # alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

          # See: https://nikitabobko.github.io/AeroSpace/commands#mode
          alt-shift-semicolon = "mode service";
        };
        mode.service.binding = {
          esc = ["reload-config" "mode main"];
          r = ["flatten-workspace-tree" "mode main"]; # reset layout

          backspace = ["enable toggle"];

          # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
          #s = ['layout sticky tiling', 'mode main']

          alt-shift-h = ["join-with left" "mode main"];
          alt-shift-j = ["join-with down" "mode main"];
          alt-shift-k = ["join-with up" "mode main"];
          alt-shift-l = ["join-with right" "mode main"];

          ctrl-alt-shift-cmd-h = ["join-with left" "layout accordion" "mode main"];
          ctrl-alt-shift-cmd-j = ["join-with down" "layout accordion" "mode main"];
          ctrl-alt-shift-cmd-k = ["join-with up" "layout accordion" "mode main"];
          ctrl-alt-shift-cmd-l = ["join-with right" "layout accordion" "mode main"];
        };
        on-window-detected = [
          {
            "if".app-id = "org.mozilla.firefox";
            run = "move-node-to-workspace 1";
          }
          {
            "if".app-id = "app.zen-browser.zen";
            run = "move-node-to-workspace 1";
          }
          {
            "if".app-id = "com.jetbrains.intellij";
            run = "move-node-to-workspace 2";
          }
          {
            "if".app-id = "com.github.wez.wezterm";
            run = "move-node-to-workspace 2";
          }
          {
            "if".app-id = "com.termius-beta.mac";
            run = "move-node-to-workspace 2";
          }
          {
            "if".app-id = "com.goodnotesapp.x";
            run = "move-node-to-workspace 3";
          }
          {
            "if".app-id = "md.obsidian";
            run = "move-node-to-workspace 3";
          }
          {
            "if".app-id = "com.culturedcode.ThingsMac";
            run = "move-node-to-workspace 3";
          }
          {
            "if".app-id = "dev.vencord.vesktop";
            run = "move-node-to-workspace 4";
          }
          {
            "if".app-id = "us.zoom.xos";
            run = "move-node-to-workspace 4";
          }
          {
            "if".app-id = "com.hnc.Discord";
            run = "move-node-to-workspace 4";
          }
          {
            "if".app-id = "com.spotify.client";
            run = "move-node-to-workspace 5";
          }
          {
            "if".app-id = "com.apple.finder";
            run = "layout floating";
          }
          {
            "if".app-id = "com.1password.1password";
            run = "layout floating";
          }
          {
            "if".app-id = "pl.maketheweb.cleanshotx";
            run = "layout floating";
          }
          # Order matters here!
          # Callbacks are run in order and the firt match counts
          {
            "if".window-title-regex-substring = "kittyfloat";
            run = "layout floating";
          }
          {
            "if".app-id = "net.kovidgoyal.kitty";
            run = "move-node-to-workspace 2";
          }
        ];
      };
    };
  };
}
