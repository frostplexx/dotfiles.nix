{
  pkgs,
  lib,
  ...
}: {
  lazy = {
    enable = false;
    plugins = {
      "cord.nvim" = {
        package = pkgs.vimPlugins.cord-nvim;
        lazy = true;
        event = ["LazyFile"];
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

      # "vimtex" = {
      #   package = pkgs.vimPlugins.vimtex;
      #   event = ["LazyFile"];
      #   # setupModule = "vimtex";
      #   ft = [
      #     "tex"
      #     "latex"
      #   ];
      #   lazy = true;
      #   after = ''
      #
      #     -- Skim configuration for macOS
      #     vim.g.vimtex_view_method = "skim"
      #
      #     -- Enable SyncTeX for forward/inverse search with Skim
      #     vim.g.vimtex_view_skim_sync = 1
      #     -- Activate Skim on cursor position change (scroll sync)
      #     vim.g.vimtex_view_skim_activate = 1
      #     -- Reading the output file to get sync info
      #     vim.g.vimtex_view_skim_reading_bar = 1
      #
      #     vim.g.vimtex_quickfix_mode = 0
      #     vim.g.tex_flavor = "latex"
      #
      #     -- Compiler settings for better SyncTeX support
      #     vim.g.vimtex_compiler_latexmk = {
      #     	options = {
      #     		"-pdf",
      #     		"-shell-escape",
      #     		"-verbose",
      #     		"-file-line-error",
      #     		"-synctex=1",
      #     		"-interaction=nonstopmode",
      #     	},
      #     }
      #
      #     -- Keymaps for forward search
      #     vim.api.nvim_create_autocmd("FileType", {
      #     	pattern = { "tex", "latex" },
      #     	callback = function()
      #     		vim.keymap.set(
      #     			"n",
      #     			"<leader>lv",
      #     			"<cmd>VimtexView<CR>",
      #     			{ buffer = true, desc = "VimTeX forward search to Skim" }
      #     		)
      #     		vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { buffer = true, desc = "VimTeX compile" })
      #     	end,
      #     })
      #   '';
      # };
    };
  };
}
