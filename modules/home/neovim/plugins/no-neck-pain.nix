_: {
  flake.homeManagerModules.neovim-plugin-no-neck-pain = {pkgs, ...}: {
    # Centers the focused window by padding it with empty scratch windows.
    #
    # The obvious no-plugin alternative -- padding the 'statuscolumn' with
    # spaces -- cannot work here: Neovim refuses to render a statuscolumn wider
    # than 47 cells (and silently drops it entirely past that, snapping the
    # buffer hard left). Centering a 120 column buffer needs (width - 120) / 2
    # of padding, so that approach breaks on any window wider than ~214
    # columns. This screen is far wider, hence the side windows.
    #
    # Registered as a non-lazy plugin on purpose: the plugin enables itself from
    # a VimEnter autocmd, so its setup has to have run before VimEnter fires.
    programs.nvf.settings.vim.extraPlugins.no-neck-pain = {
      package = pkgs.vimPlugins.no-neck-pain-nvim;
      setup = ''
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

          buffers = {
            setNames = false,
            -- No `colors.background`: the default inherits the colorscheme, so
            -- the transparent catppuccin background carries into the padding.

            -- `:NoNeckPainScratchPad` (<leader>Z) turns the padding into a
            -- notepad that autosaves. Paths are set per side on purpose:
            -- setting one on `buffers` points both sides at the same file, so
            -- you get two windows onto one buffer.
            --
            -- Without an explicit path the plugin writes
            -- `no-neck-pain-{left,right}.norg` into the *current working
            -- directory*, littering whatever repo you happen to be in. Pinning
            -- it to stdpath("data") keeps one persistent pair of notes instead,
            -- and follows NVIM_APPNAME rather than hardcoding ~/.local/share.
            --
            -- `.md` rather than the plugin's `.norg` default: markdown is
            -- enabled in languages.nix (with render-markdown), neorg is not.
            -- The extension alone drives the filetype -- the plugin only falls
            -- back to norg when the buffer's filetype is empty -- so there is
            -- no need to override `bo.filetype` and reassign the padding
            -- buffers' own "no-neck-pain" filetype.
            left = {
              scratchPad = {
                pathToFile = vim.fn.stdpath("data") .. "/no-neck-pain-left.md",
              },
            },
            right = {
              scratchPad = {
                pathToFile = vim.fn.stdpath("data") .. "/no-neck-pain-right.md",
              },
            },
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
      {
        # Not <leader>zs: that would make <leader>z a prefix and add a
        # 'timeoutlen' delay to the toggle above, which is pressed far more.
        key = "<leader>Z";
        mode = "n";
        silent = true;
        action = "<cmd>NoNeckPainScratchPad<CR>";
        desc = "Toggle no-neck-pain scratchpad (side buffers as notepads)";
      }
    ];
  };
}
