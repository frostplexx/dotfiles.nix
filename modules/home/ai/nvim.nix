_: {
  # sidekick.nvim is the AI sidekick that integrates Copilot LSP's "Next Edit
  # Suggestions" with a built-in terminal for any AI CLI. This module configures
  # both the claude-code CLI (themes, skills, statusline) and sidekick.nvim
  # (folke/sidekick.nvim) as the editor integration.
  flake.homeManagerModules.neovim-plugin-claudecode = {pkgs, ...}: {
    programs = {
      nvf.settings.vim = {
        extraPackages = [
          pkgs.nodejs # needed for pi coding agent
        ];

        assistant = {
          copilot = {
            enable =
              if pkgs.stdenv.isDarwin
              then true
              else false;

            mappings.suggestion.accept = "<C-cr>";
            setupOpts = {
              suggestion = {
                enabled = true;
                auto_trigger = true;
              };
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
        keymaps = [
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

        lazy.plugins."sidekick.nvim" = {
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
                pi = {
                  cmd = ["pi"];
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
              key = "<leader>aa";
              mode = "n";
              lua = true;
              action = ''function() require("sidekick.cli").toggle({ name = "pi", focus = true }) end'';
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
  };
}
