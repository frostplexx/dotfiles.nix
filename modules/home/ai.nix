_: {
  flake.homeManagerModules.ai = {pkgs, ...}: let
    agent-desktop = pkgs.stdenv.mkDerivation rec {
      pname = "agent-desktop";
      version = "0.1.13";

      src = pkgs.fetchurl {
        url = "https://github.com/lahfir/agent-desktop/releases/download/v${version}/agent-desktop-v${version}-aarch64-apple-darwin.tar.gz";
        sha256 = "sha256-cByMKFH3o4sOs+DKVHf3M74p5kMjloyTdRWujHnAfwU=";
      };

      sourceRoot = ".";

      installPhase = ''
        mkdir -p $out/bin
        cp agent-desktop $out/bin/
        chmod +x $out/bin/agent-desktop
      '';

      meta = with pkgs.lib; {
        description = "Native desktop automation CLI for AI agents";
        homepage = "https://github.com/lahfir/agent-desktop";
        license = licenses.asl20;
        platforms = platforms.darwin;
      };
    };
  in {
    home = {
      packages = [
        agent-desktop
      ];

      file.".claude/themes/catppuccin.json".text = builtins.toJSON {
        "$schema" = "https://raw.githubusercontent.com/matcra587/claude-themes/main/schemas/theme.schema.json";
        name = "Catppuccin Mocha";
        base = "dark";
        overrides = {
          text = "rgb(205,214,244)";
          inverseText = "rgb(30,30,46)";
          background = "rgb(30,30,46)";
          subtle = "rgb(127,132,156)";
          inactive = "rgb(88,91,112)";
          inactiveShimmer = "rgb(108,112,134)";
          userMessageBackground = "rgb(49,50,68)";
          userMessageBackgroundHover = "rgb(69,71,90)";
          messageActionsBackground = "rgb(24,24,37)";
          selectionBg = "rgb(69,71,90)";
          bashMessageBackgroundColor = "rgb(49,50,68)";
          memoryBackgroundColor = "rgb(49,50,68)";
          bashBorder = "rgb(243,139,168)";
          promptBorder = "rgb(137,180,250)";
          promptBorderShimmer = "rgb(116,168,252)";
          success = "rgb(166,227,161)";
          error = "rgb(243,139,168)";
          warning = "rgb(249,226,175)";
          warningShimmer = "rgb(235,211,145)";
          merged = "rgb(203,166,247)";
          suggestion = "rgb(148,226,213)";
          diffAdded = "rgb(166,227,161)";
          diffRemoved = "rgb(243,139,168)";
          diffAddedDimmed = "rgb(166,227,161)";
          diffRemovedDimmed = "rgb(243,139,168)";
          diffAddedWord = "rgb(166,227,161)";
          diffRemovedWord = "rgb(243,139,168)";
          autoAccept = "rgb(203,166,247)";
          claude = "rgb(250,179,135)";
          claudeShimmer = "rgb(236,165,121)";
          claudeBlue_FOR_SYSTEM_SPINNER = "rgb(137,180,250)";
          claudeBlueShimmer_FOR_SYSTEM_SPINNER = "rgb(116,168,252)";
          permission = "rgb(137,180,250)";
          permissionShimmer = "rgb(116,168,252)";
          planMode = "rgb(148,226,213)";
          ide = "rgb(137,180,250)";
          red_FOR_SUBAGENTS_ONLY = "rgb(243,139,168)";
          blue_FOR_SUBAGENTS_ONLY = "rgb(137,180,250)";
          green_FOR_SUBAGENTS_ONLY = "rgb(166,227,161)";
          yellow_FOR_SUBAGENTS_ONLY = "rgb(249,226,175)";
          purple_FOR_SUBAGENTS_ONLY = "rgb(203,166,247)";
          orange_FOR_SUBAGENTS_ONLY = "rgb(250,179,135)";
          pink_FOR_SUBAGENTS_ONLY = "rgb(245,194,231)";
          cyan_FOR_SUBAGENTS_ONLY = "rgb(137,220,235)";
          professionalBlue = "rgb(137,180,250)";
          chromeYellow = "rgb(249,226,175)";
          fastMode = "rgb(166,227,161)";
          fastModeShimmer = "rgb(88,91,112)";
          briefLabelYou = "rgb(250,179,135)";
          briefLabelClaude = "rgb(137,180,250)";
          rate_limit_fill = "rgb(243,139,168)";
          rate_limit_empty = "rgb(69,71,90)";
          rainbow_red = "rgb(243,139,168)";
          rainbow_orange = "rgb(250,179,135)";
          rainbow_yellow = "rgb(249,226,175)";
          rainbow_green = "rgb(166,227,161)";
          rainbow_blue = "rgb(137,180,250)";
          rainbow_indigo = "rgb(180,190,254)";
          rainbow_violet = "rgb(203,166,247)";
          rainbow_red_shimmer = "rgb(243,119,153)";
          rainbow_orange_shimmer = "rgb(250,179,135)";
          rainbow_yellow_shimmer = "rgb(235,211,145)";
          rainbow_green_shimmer = "rgb(137,216,139)";
          rainbow_blue_shimmer = "rgb(116,168,252)";
          rainbow_indigo_shimmer = "rgb(180,190,254)";
          rainbow_violet_shimmer = "rgb(203,166,247)";
        };
      };

      file.".claude/statusline.sh" = {
        text =
          /*
          bash
          */
          ''
              #!/bin/bash

              # Catppuccin Mocha Color Palette
              MAUVE="\033[38;2;203;166;247m"
              RED="\033[38;2;243;139;168m"
              PEACH="\033[38;2;250;179;135m"
              YELLOW="\033[38;2;249;226;175m"
              GREEN="\033[38;2;166;227;161m"
              TEAL="\033[38;2;148;226;213m"
              SKY="\033[38;2;137;220;235m"
              BLUE="\033[38;2;137;180;250m"
              LAVENDER="\033[38;2;180;190;254m"
              TEXT="\033[38;2;205;214;244m"
              SUBTEXT0="\033[38;2;166;173;200m"
              OVERLAY2="\033[38;2;147;153;178m"
              OVERLAY1="\033[38;2;127;132;156m"
              PINK="\033[38;2;245;194;231m"
              RESET="\033[0m"
              BOLD="\033[1m"

              # Read JSON input
              input=$(cat)

            # Extract data from JSON
            model=$(echo "$input" | jq -r '.model.display_name // .model.id')
            session_name=$(echo "$input" | jq -r '.session_name // empty')
            cwd=$(echo "$input" | jq -r '.workspace.current_dir')
            time=$(date +"%H:%M:%S")
            output_style=$(echo "$input" | jq -r '.output_style.name // empty')
            git_worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')

              # Context window info
              used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

            # Rate limits (Claude.ai subscription)
            five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
            seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

            # Extended thinking
            thinking_enabled=$(echo "$input" | jq -r '.thinking.enabled // false')

              # Vim mode
              vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

              # Build statusline
              out=""

            # Session name (if set) with bold mauve color
            if [ -n "$session_name" ]; then
              out=$(printf "''${BOLD}''${MAUVE}❖ %s''${RESET} ''${OVERLAY1}•''${RESET} " "$session_name")
            fi

            # Model name in blue
            out="''${out}$(printf "''${BLUE}󰧑 %s''${RESET}" "$model")"

            # Output style (if not default)
            if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
              out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${LAVENDER}%s''${RESET}" "$output_style")"
            fi

            # Extended thinking indicator
            if [ "$thinking_enabled" = "true" ]; then
              out="''${out}$(printf " ''${TEAL}󰋗''${RESET}")"
            fi

            # Context usage with color-coded percentage
            if [ -n "$used_pct" ]; then
              pct=$(printf "%.0f" "$used_pct")

              # Color based on usage
              if (( $(echo "$used_pct < 50" | bc -l) )); then
                ctx_color=$GREEN
              elif (( $(echo "$used_pct < 75" | bc -l) )); then
                ctx_color=$YELLOW
              elif (( $(echo "$used_pct < 90" | bc -l) )); then
                ctx_color=$PEACH
              else
                ctx_color=$RED
              fi

              out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${ctx_color}󱤔 %s%%''${RESET}" "$pct")"
            fi

            # Rate limits (if available)
            if [ -n "$five_hour_pct" ] || [ -n "$seven_day_pct" ]; then
              out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${PINK}󱫋''${RESET}")"

              if [ -n "$five_hour_pct" ]; then
                five_rounded=$(printf "%.0f" "$five_hour_pct")
                if (( $(echo "$five_hour_pct < 75" | bc -l) )); then
                  limit_color=$GREEN
                elif (( $(echo "$five_hour_pct < 90" | bc -l) )); then
                  limit_color=$YELLOW
                else
                  limit_color=$RED
                fi
                out="''${out}$(printf " ''${limit_color}5h:%s%%''${RESET}" "$five_rounded")"
              fi

              if [ -n "$seven_day_pct" ]; then
                seven_rounded=$(printf "%.0f" "$seven_day_pct")
                if (( $(echo "$seven_day_pct < 75" | bc -l) )); then
                  limit_color=$GREEN
                elif (( $(echo "$seven_day_pct < 90" | bc -l) )); then
                  limit_color=$YELLOW
                else
                  limit_color=$RED
                fi
                out="''${out}$(printf " ''${limit_color}7d:%s%%''${RESET}" "$seven_rounded")"
              fi
            fi

            # Git worktree indicator
            if [ -n "$git_worktree" ]; then
              out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${PEACH} %s''${RESET}" "$git_worktree")"
            fi

            # Vim mode (if enabled)
            if [ -n "$vim_mode" ]; then
              case "$vim_mode" in
                "INSERT")
                  vim_color=$GREEN
                  vim_icon="󰏫"
                  ;;
                "NORMAL")
                  vim_color=$BLUE
                  vim_icon="󰰓"
                  ;;
                "VISUAL"|"VISUAL LINE")
                  vim_color=$MAUVE
                  vim_icon="󰈈"
                  ;;
                *)
                  vim_color=$TEXT
                  vim_icon="󰰓"
                  ;;
              esac
              out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${vim_color}%s %s''${RESET}" "$vim_icon" "$vim_mode")"
            fi

            # Context usage with color-coded percentage
            if [ -n "$used_pct" ]; then
              pct=$(printf "%.0f" "$used_pct")

              # Color based on usage
              if (( $(echo "$used_pct < 50" | bc -l) )); then
                ctx_color=$GREEN
              elif (( $(echo "$used_pct < 75" | bc -l) )); then
                ctx_color=$YELLOW
              elif (( $(echo "$used_pct < 90" | bc -l) )); then
                ctx_color=$PEACH
              else
                ctx_color=$RED
              fi

              # Model name in blue
              out="''${out}$(printf "''${BLUE}󰧑 %s''${RESET}" "$model")"

            # Git worktree indicator
            if [ -n "$git_worktree" ]; then
              out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${PEACH} %s''${RESET}" "$git_worktree")"
            fi

              # Vim mode (if enabled)
              if [ -n "$vim_mode" ]; then
                case "$vim_mode" in
                  "INSERT")
                    vim_color=$GREEN
                    vim_icon="󰏫"
                    ;;
                  "NORMAL")
                    vim_color=$BLUE
                    vim_icon="󰰓"
                    ;;
                  "VISUAL"|"VISUAL LINE")
                    vim_color=$MAUVE
                    vim_icon="󰈈"
                    ;;
                  *)
                    vim_color=$TEXT
                    vim_icon="󰰓"
                    ;;
                esac
                out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${vim_color}%s %s''${RESET}" "$vim_icon" "$vim_mode")"
              fi

              # Current directory
              dir_short=$(basename "$cwd")
              out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${SUBTEXT0} %s''${RESET}" "$dir_short")"

              # Time
              out="''${out}$(printf " ''${OVERLAY1}•''${RESET} ''${OVERLAY2} %s''${RESET}" "$time")"

              printf "%b\n" "$out"
          '';
        executable = true;
      };
    };

    programs.claude-code = {
      enable = true;

      # LSP Configuration
      # TODO: Add more
      lspServers = {
        gopls = {
          command = ["${pkgs.gopls}/bin/gopls"];
          extensions = [".go"];
        };
        nixd = {
          command = ["${pkgs.nixd}/bin/nixd"];
          extensions = [".nix"];
        };
      };

      skills = let
        impeccable = pkgs.fetchzip {
          url = "https://github.com/pbakaus/impeccable/archive/15332dd293986e0a310fa54c103025d21142c3dd.tar.gz";
          sha256 = "1a6p5p1h3wk5w6qsvq2lb0dl2nm7y759xyngx7lqrgwdnb7zs1pw";
          stripRoot = true;
        };
        caveman = pkgs.fetchzip {
          url = "https://github.com/JuliusBrussee/caveman/archive/63e797cd753b301374947a5ed975c21775d962b9.tar.gz";
          sha256 = "1ad7k3kkky55dmw9jf4flwwh5asgnrwsirp0a3nfgzpxd90cqwx4";
          stripRoot = true;
        };
        agent-desktop-source = pkgs.fetchzip {
          url = "https://github.com/lahfir/agent-desktop/archive/v0.1.13.tar.gz";
          sha256 = "07lmnb98qab9s2gx7f2437c7xnq0d3lnd4snij6rxn8lb5kfizrn";
          stripRoot = true;
        };
        skillsDir = impeccable + "/source/skills";
        cavemanSkillsDir = caveman + "/skills";
        agentDesktopSkillsDir = agent-desktop-source + "/skills";
      in
        builtins.mapAttrs (name: _: skillsDir + "/${name}") (builtins.readDir skillsDir)
        // builtins.mapAttrs (name: _: cavemanSkillsDir + "/${name}") (builtins.readDir cavemanSkillsDir)
        // builtins.mapAttrs (name: _: agentDesktopSkillsDir + "/${name}") (builtins.readDir agentDesktopSkillsDir);

      settings = {
        # Anthropic model to use
        model = "claude-sonnet-4-5";

        # Enable ANSI colors in output
        useAnsiColors = true;
        theme = "custom:catppuccin";

        # Fancy Catppuccin Mocha themed statusline
        statusLine = {
          type = "command";
          command = "/Users/daniel/.claude/statusline.sh";
        };
      };
    };
  };
}
