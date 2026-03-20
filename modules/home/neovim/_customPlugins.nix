{
  pkgs,
  lib,
  inputs,
  ...
}: {
  lazy = {
    enable = true;
    plugins = {
      "CopilotChat.nvim" = {
        package = pkgs.vimPlugins.CopilotChat-nvim;
        lazy = true;
        setupModule = "CopilotChat";
        event = [
          {
            event = "User";
            pattern = "LazyFile";
          }
        ];
        keys = [
          {
            key = "<leader>aa";
            mode = "n";
            lua = false;
            action = ":CopilotChatToggle<cr>";
          }
          {
            key = "<leader>am";
            mode = "n";
            lua = false;
            action = ":CopilotChatModels<cr>";
          }
        ];
      };

      "fff.nvim" = {
        package = inputs.fff-nvim.packages.${pkgs.stdenv.hostPlatform.system}.fff-nvim;
        lazy = true;
        setupModule = "fff";
        setupOpts = {
          prompt = "> ";
          max_threads = 8;
          preview = {
            line_numbers = true;
          };
        };
        keys = [
          {
            key = "<leader>ff";
            mode = "n";
            lua = true;
            action = "function() require('fff').find_files() end";
          }
          {
            key = "<leader>fg";
            mode = "n";
            lua = true;
            action = "function() require('fff').live_grep() end";
          }
          {
            key = "<leader>fz";
            mode = "n";
            lua = true;
            action = "function() require('fff').live_grep({grep = { modes = { 'fuzzy', 'plain' } }}) end";
          }
          {
            key = "<leader>fc";
            mode = "n";
            lua = true;
            action = ''function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end'';
          }
        ];
      };

      "cord.nvim" = {
        package = pkgs.vimPlugins.cord-nvim;
        lazy = true;
        event = [
          {
            event = "User";
            pattern = "LazyFile";
          }
        ];
        setupModule = "cord";
        setupOpts = {
          editor = {
            tooltip = "How do I exit this?";
          };
          idle = {
            details = lib.generators.mkLuaInline ''
              function(opts)
                  return string.format('Taking a break from %s', opts.workspace)
              end
            '';
          };
          text = {
            editing = lib.generators.mkLuaInline ''
                function(opts)
                  local errors = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
                  return string.format('Editing %s - %s errors', opts.filename, #errors)
              end
            '';
            workspace = lib.generators.mkLuaInline ''
                function(opts)
                  return string.format("Working on %s", opts.workspace)
              end
            '';
          };
        };

        # after = "print('cord loaded')";
      };
    };
  };
}
