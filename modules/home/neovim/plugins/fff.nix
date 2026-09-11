_: {
  flake.homeManagerModules.neovim-plugin-fff = {
    pkgs,
    inputs,
    ...
  }: {
    programs.nvf.settings.vim.lazy.plugins."fff.nvim" = {
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
          key = "<leader>f";
          mode = "n";
          lua = true;
          action = "function() require('fff').find_files() end";
        }
        {
          key = "<leader>F";
          mode = "n";
          lua = true;
          action = "function() require('fff').live_grep() end";
        }
      ];
    };
  };
}
