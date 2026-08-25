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

        lazy.plugins = {
          "copilot-lsp" = {
            package = pkgs.vimPlugins.copilot-lsp;
            lazy = true;
            # Load on same events as copilot.lua
            event = [
              {
                event = "User";
                pattern = "LazyFile";
              }
            ];
            setupModule = "copilot-lsp";
            setupOpts.nes.move_count_threshold = 1000;
            keys = [
              {
                key = "<tab>";
                mode = "n";
                lua = true;
                expr = true;
                action = ''
                  function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local state = vim.b[bufnr].nes_state
                    if state then
                      local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
                          or (
                              require("copilot-lsp.nes").apply_pending_nes()
                              and require("copilot-lsp.nes").walk_cursor_end_edit()
                          )
                      return nil
                    else
                      return "<C-i>"
                    end
                  end
                '';
                desc = "Accept Copilot NES suggestion";
              }
            ];
          };
        };

        assistant = {
          copilot = {
            enable =
              if pkgs.stdenv.hostPlatform.isDarwin
              then true
              else false;

            mappings.suggestion.accept = "<C-cr>";
            setupOpts = {
              suggestion = {
                enabled = true;
                auto_trigger = true;
              };
              nes = {
                enabled = true;
                keymap = {
                  accept_and_goto = "<leader>p";
                  accept = false;
                  dismiss = "<Esc>";
                };
              };
            };
          };
        };
      };
    };
  };
}
