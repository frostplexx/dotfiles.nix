_: {
  # Claude Code lives entirely with Neovim: this module configures both the
  # claude-code CLI (themes, skills, LSP servers, statusline) and the
  # claudecode.nvim editor integration (coder/claudecode.nvim) that drives it.
  flake.homeManagerModules.neovim-plugin-claudecode = {
    pkgs,
    lib,
    defaults,
    ...
  }: let
    # The claude-code CLI is intentionally NOT added to the shell PATH (see
    # `programs.claude-code.package = null` below). Neovim is the only place
    # Claude Code is meant to run, so the claudecode.nvim terminal_cmd points at
    # this package by absolute store path instead of relying on PATH.
    claudePackage = pkgs.claude-code;
  in {
    home = {
      file = {
        ".claude/themes/catppuccin.json".text = builtins.toJSON {
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
        ".claude/statusline.sh" = {
          source = ./statusline.sh;
          executable = true;
        };
      };
    };

    programs.claude-code = {
      enable = true;

      # Keep config-file generation (settings.json, themes, skills, statusline)
      # but do NOT install the CLI into home.packages / PATH. With package = null
      # the module's `home.packages = mkIf (cfg.package != null) ...` short-circuits,
      # so `claude` is unavailable in every shell. Neovim still drives the CLI via
      # claudePackage (terminal_cmd) by absolute store path.
      package = null;


      skills = let
        # https://github.com/multica-ai/andrej-karpathy-skills/
        andrej-karpathy-skills = pkgs.fetchzip {
          url = "https://github.com/multica-ai/andrej-karpathy-skills/archive/refs/heads/main.zip";
          sha256 = "sha256-4z/wRdYH7UXRzF8RJU0sw8xbpx0BW/7CBv5sVEC2knY=";
          stripRoot = true;
        };
        caveman = pkgs.fetchzip {
          url = "https://github.com/JuliusBrussee/caveman/archive/63e797cd753b301374947a5ed975c21775d962b9.tar.gz";
          sha256 = "1ad7k3kkky55dmw9jf4flwwh5asgnrwsirp0a3nfgzpxd90cqwx4";
          stripRoot = true;
        };

        cavemanSkillsDir = caveman + "/skills";
        andrej-karpathy-skillsDir = andrej-karpathy-skills + "/skills";
      in
        builtins.mapAttrs (name: _: cavemanSkillsDir + "/${name}") (builtins.readDir cavemanSkillsDir)
        // builtins.mapAttrs (name: _: andrej-karpathy-skillsDir + "/${name}") (
          builtins.readDir andrej-karpathy-skillsDir
        );

      settings = {
        # Enable ANSI colors in output
        useAnsiColors = true;
        theme =
          {
            "catppuccin" = "custom:catppuccin";
          }
            .${
            defaults.settings.theme
          };

        # Catppuccin Mocha lualine-style statusline (renders vim.mode
        # itself, so suppress the built-in -- INSERT -- indicator).
        statusLine = {
          type = "command";
          command = "$HOME/.claude/statusline.sh";
          padding = 0;
          hideVimModeIndicator = true;
        };
      };
    };

    programs.nvf.settings.vim.lazy.plugins."claudecode.nvim" = {
      package = pkgs.vimPlugins.claudecode-nvim;
      lazy = true;
      setupModule = "claudecode";
      setupOpts = {
        # Drive the exact claude-code CLI configured above, independent of PATH.
        # IS_DEMO / CLAUDE_CODE_HIDE_ACCOUNT_INFO suppress account info / welcome
        # banner size (the two names flip between releases).
        terminal_cmd = lib.getExe (
          pkgs.writeShellScriptBin "claude-nvim" ''
            export IS_DEMO=1
            export CLAUDE_CODE_HIDE_ACCOUNT_INFO=1
            # The nix-store binary is read-only, so its auto-updater can't patch
            # itself in place — instead it reinstalls into ~/.local/share/claude
            # and re-adds ~/.local/bin/claude to PATH, defeating the whole point
            # of scoping Claude Code to Neovim. Disable it so the only `claude`
            # that exists is this one, reachable solely from inside the editor.
            export DISABLE_AUTOUPDATER=1
            exec "${lib.getExe claudePackage}" "$@"
          ''
        );
        terminal = {
          split_side = "right"; # "left" or "right"
          provider = "native";
        };
      };

      # Create command stubs so the :ClaudeCode* commands are available before
      # any <leader>a* mapping is pressed (see coder/claudecode.nvim README).
      cmd = [
        "ClaudeCode"
        "ClaudeCodeFocus"
        "ClaudeCodeSelectModel"
        "ClaudeCodeAdd"
        "ClaudeCodeSend"
        "ClaudeCodeTreeAdd"
        "ClaudeCodeStatus"
        "ClaudeCodeStart"
        "ClaudeCodeStop"
        "ClaudeCodeOpen"
        "ClaudeCodeClose"
        "ClaudeCodeDiffAccept"
        "ClaudeCodeDiffDeny"
        "ClaudeCodeCloseAllDiffs"
      ];

      keys = [
        {
          key = "<leader>ac";
          mode = "n";
          lua = false;
          action = "<cmd>ClaudeCode<CR>";
        }
        {
          key = "<leader>af";
          mode = "n";
          lua = false;
          action = "<cmd>ClaudeCodeFocus<CR>";
        }
        {
          key = "<leader>ab";
          mode = "n";
          lua = false;
          action = "<cmd>ClaudeCodeAdd %<cr>";
        }

        {
          key = "<leader>aa";
          mode = "n";
          lua = false;
          action = "<cmd>ClaudeCodeDiffAccept<cr>";
        }

        {
          key = "<leader>ad";
          mode = "n";
          lua = false;
          action = "<cmd>ClaudeCodeDiffDeny<cr>";
        }
      ];
    };
  };
}
