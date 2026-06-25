_: {
  # sidekick.nvim is the AI sidekick that integrates Copilot LSP's "Next Edit
  # Suggestions" with a built-in terminal for any AI CLI. This module configures
  # both the claude-code CLI (themes, skills, statusline) and sidekick.nvim
  # (folke/sidekick.nvim) as the editor integration.
  flake.homeManagerModules.neovim-plugin-claudecode = {
    pkgs,
    lib,
    defaults,
    ...
  }: let
    # The claude-code CLI is intentionally NOT added to the shell PATH (see
    # `programs.claude-code.package = null` below). Neovim is the only place
    # Claude Code is meant to run, so sidekick.nvim's tool cmd points at this
    # package by absolute store path instead of relying on PATH.
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

    programs = {
      claude-code = {
        enable = true;

        # Keep config-file generation (settings.json, themes, skills, statusline)
        # but do NOT install the CLI into home.packages / PATH. With package = null
        # the module's `home.packages = mkIf (cfg.package != null) ...` short-circuits,
        # so `claude` is unavailable in every shell. Neovim still drives the CLI via
        # claudePackage (cmd) by absolute store path.
        package = null;

        skills = let
          caveman = pkgs.fetchzip {
            url = "https://github.com/JuliusBrussee/caveman/archive/63e797cd753b301374947a5ed975c21775d962b9.tar.gz";
            sha256 = "1ad7k3kkky55dmw9jf4flwwh5asgnrwsirp0a3nfgzpxd90cqwx4";
            stripRoot = true;
          };

          cavemanSkillsDir = caveman + "/skills";
        in
          builtins.mapAttrs (name: _: cavemanSkillsDir + "/${name}") (builtins.readDir cavemanSkillsDir)
          // {
            "ask-obsidian.md" = ./skills/ask-obsidian.md;
          };

        context = ''
          You are a collaborative coding companion. Your role is to help me understand, decide, and grow — not to generate complete solutions unilaterally.

          Default behavior:
          - When I describe a problem, ask clarifying questions before writing code unless the task is unambiguously defined.
          - For non-trivial changes, briefly surface 2-3 approaches with trade-offs and let me choose direction before you start writing.
          - Write code only when I explicitly ask ("implement this", "go ahead", "write it") or when the scope is already fully agreed.
          - For small, well-scoped edits (fix this typo, rename this variable), proceed directly.

          Explain your thinking:
          - Share the "why" behind your suggestions, not just the "what".
          - When you spot a better pattern, name it and ask if I want to apply it — don't apply it silently.
          - Surface any assumptions you are making before acting on them.

          Scope discipline:
          - Match your response scope exactly to the request: a question gets an explanation, not a rewrite.
          - Do not refactor, add features, or clean surrounding code beyond what was explicitly requested.
          - If you notice related issues while working, mention them in a sentence; do not fix them uninvited.

          Tone:
          - Treat me as the decision-maker; you are the advisor.
          - Keep responses short and direct unless I ask for depth.
          - Skip trailing summaries of what you just did — I can read the diff.

          Use the following thing as guidance for you responsens:
          Terse like caveman. Technical substance exact. Only fluff die.
          Drop: articles, filler (just/really/basically), pleasantries, hedging.
          Fragments OK. Short synonyms. Code unchanged.
          Pattern: [thing] [action] [reason]. [next step].
          ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
          Code/commits/PRs: normal.
        '';

        settings = {
          permissions = {
            allow = [
              "Read(~/Documents/Memex/**)"
              "Bash(rg *)"
              "Bash(cat *)"
            ];
          };

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

      # Normal-mode <Tab> applies/jumps the active Next Edit Suggestion.
      # NES suggestions are cleared on InsertEnter/TextChangedI, so they only
      # ever live in normal mode — this is where Tab needs to accept them
      # (insert-mode <Tab> is owned by blink.cmp's super-tab). expr + the
      # "<Tab>" return means a literal Tab is fed only when there is no edit.
      # sidekick is already loaded by the InsertEnter/BufReadPost events below,
      # so require() here is always live.
      nvf.settings.vim.keymaps = [
        {
          key = "<Tab>";
          mode = "n";
          lua = true;
          expr = true;
          silent = true;
          desc = "Sidekick: jump/apply Next Edit Suggestion";
          action = ''
            function()
              if not require("sidekick").nes_jump_or_apply() then
                return "<Tab>"
              end
            end
          '';
        }
      ];

      nvf.settings.vim.lazy.plugins."sidekick.nvim" = {
        package = pkgs.vimPlugins.sidekick-nvim;
        lazy = true;
        setupModule = "sidekick";
        setupOpts = {
          nes = {
            enabled = true;
            debounce = 100;
            trigger = {
              events = [
                "ModeChanged i:n"
                "TextChanged"
                "User SidekickNesDone"
              ];
            };
            clear = {
              events = [];
              esc = true;
            };
          };
          cli = {
            tools = {
              claude = {
                # Drive the exact claude-code CLI configured above, independent
                # of PATH. Env vars suppress account info / welcome banner
                # (the two names flip between releases) and prevent the
                # auto-updater from reinstalling into ~/.local/bin.
                cmd = [(lib.getExe claudePackage)];
                env = {
                  IS_DEMO = "1";
                  CLAUDE_CODE_HIDE_ACCOUNT_INFO = "1";
                  DISABLE_AUTOUPDATER = "1";
                };
              };
            };
            win = {
              layout = "right";
            };
          };
        };

        cmd = ["Sidekick"];

        # NES auto-suggestions are driven by autocmds registered in
        # require("sidekick").setup(). Loading only on cmd/keys means those
        # autocmds never arm during normal editing, so load on InsertEnter
        # (and when a buffer is read) to set sidekick up before the first
        # i:n / TextChanged trigger fires.
        event = [
          "InsertEnter"
          "BufReadPost"
        ];

        keys = [
          {
            key = "<leader>ac";
            mode = "n";
            lua = true;
            action = ''function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end'';
          }
          {
            key = "<leader>aa";
            mode = "n";
            lua = true;
            action = ''function() require("sidekick.cli").toggle() end'';
          }
          {
            key = "<leader>as";
            mode = "n";
            lua = true;
            action = ''function() require("sidekick.cli").select() end'';
          }
          {
            key = "<leader>ad";
            mode = "n";
            lua = true;
            action = ''function() require("sidekick.cli").close() end'';
          }
          {
            key = "<leader>ab";
            mode = "n";
            lua = true;
            action = ''function() require("sidekick.cli").send({ msg = "{file}" }) end'';
          }
          {
            key = "<leader>at";
            mode = [
              "x"
              "n"
            ];
            lua = true;
            action = ''function() require("sidekick.cli").send({ msg = "{this}" }) end'';
          }
          {
            key = "<leader>av";
            mode = "x";
            lua = true;
            action = ''function() require("sidekick.cli").send({ msg = "{selection}" }) end'';
          }
          {
            key = "<leader>ap";
            mode = [
              "n"
              "x"
            ];
            lua = true;
            action = ''function() require("sidekick.cli").prompt() end'';
          }
        ];
      };
    };
  };
}
