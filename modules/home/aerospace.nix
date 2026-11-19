_: {
  flake.homeManagerModules.aerospace = {
    pkgs,
    lib,
    ...
  }: let
    # Windows of these apps tile and are sent to their workspace; every other
    # window floats but still follows its workspace rule.
    tilingApps = [
      {
        id = "app.zen-browser.zen";
        space = "web";
      }
      {
        id = "com.superlogical.rex";
        space = "term";
      }
      {
        id = "md.obsidian";
        space = "notes";
      }
      {
        id = "dev.vencord.vesktop";
        space = "comms";
      }
      {
        id = "com.hnc.DiscordPTB";
        space = "comms";
      }
      {
        id = "com.culturedcode.ThingsMac";
        space = "tasks";
      }
      {
        id = "com.apple.mail";
        space = "mail";
      }
      {
        id = "com.tidal.desktop";
        space = "music";
      }
      {
        id = "dev.nolight.sonora";
        space = "music";
      }
      {
        id = "com.apple.dt.Xcode";
        space = "dev";
      }
    ];

    floatingApps = [
      {
        id = "us.zoom.xos";
        space = "comms";
      }
    ];

    moveRule = app: {
      "if".app-id = app.id;
      run = "move-node-to-workspace ${app.space}";
    };
  in {
    programs.aerospace = {
      enable = true;
      launchd.enable = true;
      # stdenv's fixupPhase strips the app bundle, which invalidates its code
      # signature (adhoc, Info.plist not bound). TCC then has no bundle identity
      # to prompt for, so AeroSpace never gets Accessibility permission.
      package = pkgs.aerospace.overrideAttrs (_: {
        dontFixup = true;
      });
      settings = {
        accordion-padding = 20;

        # Mouse follows focus when the focused monitor changes.
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

        gaps = {
          inner = {
            horizontal = 4;
            vertical = 4;
          };
          outer = {
            bottom = 2;
            left = 2;
            right = 2;
            top = 2;
          };
        };

        # The "big" screen is the external display when docked (it is the main
        # display), else the laptop. The built-in panel hosts tasks/mail/comms/music.
        workspace-to-monitor-force-assignment = {
          web = "main";
          term = "main";
          notes = "main";
          dev = "main";
          tasks = [
            "built-in"
            "main"
          ];
          mail = [
            "built-in"
            "main"
          ];
          comms = [
            "built-in"
            "main"
          ];
          music = [
            "built-in"
            "main"
          ];
        };

        mode.main.binding = {
          # Focus movement (i3-style hjkl).
          ctrl-alt-cmd-h = "focus left";
          ctrl-alt-cmd-j = "focus down";
          ctrl-alt-cmd-k = "focus up";
          ctrl-alt-cmd-l = "focus right";

          ctrl-alt-cmd-comma = "focus-monitor left";
          ctrl-alt-cmd-period = "focus-monitor right";

          ctrl-alt-cmd-shift-comma = "move-node-to-monitor left --focus-follows-window";
          ctrl-alt-cmd-shift-period = "move-node-to-monitor right --focus-follows-window";

          ctrl-alt-cmd-space = "fullscreen";

          # Toggle the widgets/notifications panel (clicks the menu bar clock).
          ctrl-alt-cmd-n = ''
            exec-and-forget osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item "Clock" of menu bar 1'
          '';

          # Move the focused window to an adjacent slot.
          ctrl-alt-cmd-shift-h = "move left";
          ctrl-alt-cmd-shift-j = "move down";
          ctrl-alt-cmd-shift-k = "move up";
          ctrl-alt-cmd-shift-l = "move right";

          # Layout control.
          ctrl-alt-cmd-b = "layout h_tiles";
          ctrl-alt-cmd-v = "layout v_tiles";
          ctrl-alt-cmd-e = "layout horizontal vertical";
          ctrl-alt-cmd-s = "layout v_accordion";
          ctrl-alt-cmd-shift-s = "layout h_accordion";

          # Toggle floating/tiling for the focused window.
          ctrl-alt-cmd-f = "layout floating tiling";

          # Combine the focused window with its right neighbour.
          ctrl-alt-cmd-g = "join-with right";
          ctrl-alt-cmd-shift-g = "join-with right; layout v_tiles";

          # Resize the focused tile.
          ctrl-alt-cmd-minus = "resize smart -50";
          ctrl-alt-cmd-equal = "resize smart +50";

          # Named workspaces: hyper+1 web (Zen), 2 term (rex), 3 notes
          # (Obsidian), 4 comms, 5 music, 6 tasks (Things), 7 mail, 8 dev.
          ctrl-alt-cmd-1 = "workspace web";
          ctrl-alt-cmd-2 = "workspace term";
          ctrl-alt-cmd-3 = "workspace notes";
          ctrl-alt-cmd-4 = "workspace comms";
          ctrl-alt-cmd-5 = "workspace music";
          ctrl-alt-cmd-6 = "workspace tasks";
          ctrl-alt-cmd-7 = "workspace mail";
          ctrl-alt-cmd-8 = "workspace dev";

          ctrl-alt-cmd-shift-1 = "move-node-to-workspace web; workspace web";
          ctrl-alt-cmd-shift-2 = "move-node-to-workspace term; workspace term";
          ctrl-alt-cmd-shift-3 = "move-node-to-workspace notes; workspace notes";
          ctrl-alt-cmd-shift-4 = "move-node-to-workspace comms; workspace comms";
          ctrl-alt-cmd-shift-5 = "move-node-to-workspace music; workspace music";
          ctrl-alt-cmd-shift-6 = "move-node-to-workspace tasks; workspace tasks";
          ctrl-alt-cmd-shift-7 = "move-node-to-workspace mail; workspace mail";
          ctrl-alt-cmd-shift-8 = "move-node-to-workspace dev; workspace dev";
        };

        on-window-detected =
          [
            {
              check-further-callbacks = true;
              run = "layout floating";
            }
            {
              check-further-callbacks = true;
              "if" = lib.concatMapStringsSep " || " (app: "test %{app-bundle-id} = ${app.id}") tilingApps;
              run = "layout tiling";
            }
          ]
          ++ map moveRule (tilingApps ++ floatingApps);
      };
    };
  };
}
