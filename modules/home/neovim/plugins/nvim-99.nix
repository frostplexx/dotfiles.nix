_: {
  flake.homeManagerModules.neovim-plugin-nvim-99 = {
    pkgs,
    lib,
    ...
  }: {
    programs.nvf.settings.vim.lazy.plugins."nvim-99" = {
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
  };
}
