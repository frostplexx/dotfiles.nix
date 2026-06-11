{
  pkgs,
  lib,
  inputs,
  ...
}: {
  lazy = {
    enable = true;
    plugins = {
      "claudecode.nvim" = {
        package = pkgs.vimPlugins.claudecode-nvim;
        lazy = true;
        setupModule = "claudecode";
        setupOpts = {
          terminal = {
            split_side = "left"; # "left" or "right"
            provider = "native";
          };
        };

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

      "nvim-99" = {
        package = pkgs.vimPlugins.nvim-99;
        lazy = true;
        setupModule = "99";
        setupOpts = {
          provider = lib.generators.mkLuaInline ''require("99").Providers.ClaudeCodeProvider'';
          tmp_dir = "./tmp";
          source = "blink";
          model = "claude-sonnet-3-5";
        };

        keys = [
          {
            key = "<leader>9v";
            mode = "v";
            lua = true;
            action = "function() require('99').visual() end";
          }
          {
            key = "<leader>9p";
            mode = "n";
            lua = true;
            action = "function() require('99').vibe() end";
          }
          {
            key = "<leader>9s";
            mode = "n";
            lua = true;
            action = "function() require('99').search() end";
          }
          {
            key = "<leader>9o";
            mode = "n";
            lua = true;
            action = "function() require('99').open() end";
          }
          {
            key = "<leader>9x";
            mode = "n";
            lua = true;
            action = "function() require('99').stop_all_requests() end";
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
