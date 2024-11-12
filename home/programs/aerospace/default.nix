{ pkgs, lib, ... }:

let
  # Helper function to create binding mode configurations
  mkBindingMode = bindings: lib.mapAttrs
    (_key: value:
      if builtins.isList value
      then value
      else [ value ]
    )
    bindings;

  # Helper function to create window detection rules
  mkWindowRule = rules: map
    (rule: {
      condition = { inherit (rule.condition) app-id; };
      inherit (rule) run;
    })
    rules;

  # Main configuration
  config = {
    after-login-command = [ ];
    after-startup-command = [ ];
    start-at-login = true;

    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;

    accordion-padding = 10;
    default-root-container-layout = "tiles";
    default-root-container-orientation = "auto";

    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
    automatically-unhide-macos-hidden-apps = true;

    key-mapping = {
      preset = "qwerty";
    };

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

    mode = {
      main.binding = mkBindingMode {
        "alt-t" = "layout tiles horizontal vertical";
        "alt-s" = [ "layout accordion" "layout vertical" ];
        "alt-f" = "fullscreen";
        "alt-shift-f" = [ "layout floating tiling" "mode main" ];
        "cmd-m" = "macos-native-minimize";

        # Focus
        "alt-h" = "focus left";
        "alt-j" = "focus down";
        "alt-k" = "focus up";
        "alt-l" = "focus right";

        # Move
        "alt-shift-h" = "move left";
        "alt-shift-j" = "move down";
        "alt-shift-k" = "move up";
        "alt-shift-l" = "move right";

        # Resize
        "alt-shift-minus" = "resize smart -50";
        "alt-shift-equal" = "resize smart +50";

        # Workspaces
        "cmd-1" = "workspace 🌐";
        "cmd-2" = "workspace 💽";
        "cmd-3" = "workspace 💬";
        "cmd-4" = "workspace 🎵";
        "cmd-5" = "workspace 📕";
        "cmd-6" = "workspace 6";
        "cmd-7" = "workspace 7";
        "cmd-8" = "workspace 8";
        "cmd-9" = "workspace 9";
        "cmd-0" = "workspace 10";

        # Move to workspace
        "cmd-shift-1" = [ "move-node-to-workspace 🌐" "workspace 🌐" ];
        "cmd-shift-2" = [ "move-node-to-workspace 💽" "workspace 💽" ];
        "cmd-shift-3" = [ "move-node-to-workspace 💬" "workspace 💬" ];
        "cmd-shift-4" = [ "move-node-to-workspace 🎵" "workspace 🎵" ];
        "cmd-shift-5" = [ "move-node-to-workspace 📕" "workspace 📕" ];
        "cmd-shift-6" = [ "move-node-to-workspace 6" "workspace 6" ];
        "cmd-shift-7" = [ "move-node-to-workspace 7" "workspace 7" ];
        "cmd-shift-8" = [ "move-node-to-workspace 8" "workspace 8" ];
        "cmd-shift-9" = [ "move-node-to-workspace 9" "workspace 9" ];

        "alt-tab" = "focus-back-and-forth";
        "alt-shift-semicolon" = "mode service";
      };

      service.binding = mkBindingMode {
        "esc" = [ "reload-config" "mode main" ];
        "r" = [ "flatten-workspace-tree" "mode main" ];
        "backspace" = [ "close-all-windows-but-current" "mode main" ];

        "alt-shift-h" = [ "join-with left" "mode main" ];
        "alt-shift-j" = [ "join-with down" "mode main" ];
        "alt-shift-k" = [ "join-with up" "mode main" ];
        "alt-shift-l" = [ "join-with right" "mode main" ];

        "ctrl-shift-h" = [ "join-with left" "layout accordion" "mode main" ];
        "ctrl-shift-j" = [ "join-with down" "layout accordion" "mode main" ];
        "ctrl-shift-k" = [ "join-with up" "layout accordion" "mode main" ];
        "ctrl-shift-l" = [ "join-with right" "layout accordion" "mode main" ];
      };
    };

    on-window-detected = mkWindowRule [
      {
        condition.app-id = "org.mozilla.firefox";
        run = "move-node-to-workspace 🌐";
      }
      {
        condition.app-id = "com.jetbrains.intellij";
        run = "move-node-to-workspace 💽";
      }
      {
        condition.app-id = "net.kovidgoyal.kitty";
        run = "move-node-to-workspace 💽";
      }
      {
        condition.app-id = "com.termius-beta.mac";
        run = "move-node-to-workspace 💽";
      }
      {
        condition.app-id = "dev.vencord.vesktop";
        run = "move-node-to-workspace 💬";
      }
      {
        condition.app-id = "us.zoom.xos";
        run = "move-node-to-workspace 💬";
      }
      {
        condition.app-id = "com.spotify.client";
        run = "move-node-to-workspace 🎵";
      }
      {
        condition.app-id = "com.goodnotesapp.x";
        run = "move-node-to-workspace 📕";
      }
      {
        condition.app-id = "md.obsidian";
        run = "move-node-to-workspace 📕";
      }
      {
        condition.app-id = "com.apple.finder";
        run = "layout floating";
      }
      {
        condition.app-id = "com.1password.1password";
        run = "layout floating";
      }
    ];
  };

  # Function to convert Nix config to TOML
  toToml = config:
    let
      indent = level: lib.concatStrings (builtins.genList (_x: "  ") level);

      printValue = value:
        if builtins.isBool value then (if value then "true" else "false")
        else if builtins.isString value then ''"${value}"''
        else if builtins.isInt value then toString value
        else if builtins.isList value then
          let items = map printValue value;
          in "[${builtins.concatStringsSep ", " items}]"
        else if builtins.isAttrs value then
          printAttrs value 0
        else throw "Unsupported type for value: ${builtins.typeOf value}";

      printAttrs = attrs: level:
        let
          pairs = lib.mapAttrsToList
            (name: value:
              if name == "condition" then "\n${indent level}if = ${printValue value}"
              else if builtins.isAttrs value && !builtins.isNull value
              then "\n${indent level}[${name}]\n${printAttrs value (level + 1)}"
              else "\n${indent level}${name} = ${printValue value}"
            )
            attrs;
        in
        lib.concatStrings pairs;
    in
    printAttrs config 0;
in
{
  xdg.configFile = lib.mkIf pkgs.stdenv.isDarwin {
    "aerospace/aerospace.toml".text = toToml config;
  };
}
