_: {
  flake.homeManagerModules.neovim-keymaps = _: {
    programs.nvf.settings.vim.keymaps = [
      # Use same keybinds in terminal mode for split navigation
      {
        mode = "t";
        key = "<C-h>";
        action = "<C-\\><C-N><C-w>h";
        lua = false;
        noremap = true;
        desc = "Navigate left in terminal mode";
      }
      {
        mode = "t";
        key = "<C-j>";
        action = "<C-\\><C-N><C-w>j";
        lua = false;
        noremap = true;
        desc = "Navigate down in terminal mode";
      }
      {
        mode = "t";
        key = "<C-k>";
        action = "<C-\\><C-N><C-w>k";
        lua = false;
        noremap = true;
        desc = "Navigate up in terminal mode";
      }
      {
        mode = "t";
        key = "<C-l>";
        action = "<C-\\><C-N><C-w>l";
        lua = false;
        noremap = true;
        desc = "Navigate right in terminal mode";
      }

      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        lua = false;
        noremap = true;
        desc = "Navigate left";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        lua = false;
        noremap = true;
        desc = "Navigate down";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        lua = false;
        noremap = true;
        desc = "Navigate up";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        lua = false;
        noremap = true;
        desc = "Navigate right";
      }

      # Remove smart splits dependency and use built-in window resizing
      {
        mode = "n";
        key = "<A-j>";
        action = "<C-w>+";
        noremap = true;
        lua = false;
        desc = "resize down";
      }
      {
        mode = "n";
        key = "<A-l>";
        action = "<C-w><";
        noremap = true;
        lua = false;
        desc = "resize left";
      }
      {
        mode = "n";
        key = "<A-k>";
        action = "<C-w>-";
        noremap = true;
        lua = false;
        desc = "resize up";
      }
      {
        mode = "n";
        key = "<A-h>";
        action = "<C-w>>";
        noremap = true;
        lua = false;
        desc = "resize right";
      }
      {
        mode = "n";
        key = "<C-d>";
        action = "<D-d>zz";
        noremap = false;
        desc = "redo";
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<D-u>zz";
        noremap = false;
        desc = "redo";
      }
      {
        mode = "n";
        key = "U";
        action = "<c-r>";
        noremap = false;
        desc = "redo";
      }
      {
        key = "<leader>tt";
        mode = "n";
        noremap = true;
        lua = false;
        silent = true;
        action = ":ToggleTerm<CR>";
        desc = "Toggle terminal";
      }
      {
        key = "<leader>go";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() MiniDiff.toggle_overlay() end";
        desc = "Toggle MiniDiff overlay";
      }
      {
        key = "<leader>d";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() MiniBufremove.delete() end";
        desc = "Delete current buffer without closing window";
      }
      {
        key = "<leader>fb";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() MiniPick.builtin.buffers() end";
        desc = "List open buffers";
      }
      {
        key = "<leader>ss";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() MiniExtra.pickers.lsp({ scope = 'workspace_symbol' }) end";
        desc = "Search LSP workspace symbols";
      }
      {
        key = "<leader>tr";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() MiniExtra.pickers.diagnostic() end";
        desc = "Open diagnostics picker";
      }

      {
        key = "<leader>mk";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() MiniExtra.pickers.keymaps() end";
        desc = "Show registered keymaps";
      }
      {
        key = "<leader>ms";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() MiniExtra.pickers.marks() end";
        desc = "List marks in current buffer";
      }
      {
        key = "yc";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() vim.api.nvim_feedkeys('yygccp', 'm', false) end";
        desc = "Duplicate a line and comment out the first line";
      }
      {
        key = "<Esc>";
        mode = "n";
        silent = true;
        action = "<cmd>nohlsearch<CR>";
        desc = "Clear search highlighting";
      }

      {
        key = "<c-u>";
        mode = "n";
        silent = true;
        action = "<c-u>zz";
        desc = "Scroll up half page and center";
      }
      {
        key = "<c-d>";
        mode = "n";
        silent = true;
        action = "<c-d>zz";
        desc = "Scroll down half page and center";
      }
      {
        key = "<leader>n";
        mode = "n";
        silent = true;
        action = ":NoiceHistory<cr>";
        desc = "Open Noice command history";
      }
      {
        key = "<leader>gg";
        mode = "n";
        silent = true;
        lua = true;
        action = "function() Snacks.lazygit() end";
        desc = "Open Lazygit";
      }
      {
        key = "<leader>gq";
        mode = "n";
        silent = true;
        lua = true;
        action = "function() require('gitsigns').setqflist('all') end";
        desc = "Git hunks → quickfix (all buffers)";
      }
    ];
  };
}
