_: {
  flake.homeManagerModules.neovim-plugin-no-neck-pain = {pkgs, ...}: {
    programs.nvf.settings.vim.extraPlugins.no-neck-pain = {
      package = pkgs.vimPlugins.no-neck-pain-nvim;
      setup =
        /*
        lua
        */
        ''
          require("no-neck-pain").setup({
            -- Resolved once at setup from 'textwidth' (120, set in options.nix).
            -- nvf emits the options DAG before plugin setup, so it is already
            -- applied by the time this runs.
            width = "textwidth",

            -- Below this, side windows are noise rather than padding -- the
            -- window simply stays uncentered instead.
            minSideBufferWidth = 10,

            autocmds = {
              enableOnVimEnter = true,

              -- Deliberately off: diffview (and the OptionSet hook in
              -- neovim.nix) opens its own tabs, and centering those would
              -- squeeze the diff panes.
              enableOnTabEnter = false,

              -- Keeps <C-w>h/l usable -- navigating into a padding window
              -- passes straight through to the next real one.
              skipEnteringNoNeckPainBuffer = true,
            },
            -- The plugin's own mappings are all under <Leader>n, which would
            -- shadow <leader>n (NoiceHistory). Bound to <leader>z below instead.
            mappings = {enabled = false},
          })
        '';
    };

    programs.nvf.settings.vim.keymaps = [
      {
        key = "<leader>z";
        mode = "n";
        silent = true;
        action = "<cmd>NoNeckPain<CR>";
        desc = "Toggle centered buffer (no-neck-pain)";
      }
    ];
  };
}
