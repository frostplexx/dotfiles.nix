_: {
  keymaps = [
    {
      mode = "n";
      key = "<A-j>";
      action = "function() require('smart-splits').resize_down() end";
      noremap = true;
      lua = true;
      desc = "resize down";
    }
    {
      mode = "n";
      key = "<A-l>";
      action = "function() require('smart-splits').resize_right() end";
      noremap = true;
      lua = true;
      desc = "resize left";
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "function() require('smart-splits').resize_up() end";
      noremap = true;
      lua = true;
      desc = "resize up";
    }
    {
      mode = "n";
      key = "<A-h>";
      action = "function() require('smart-splits').resize_left() end";
      noremap = true;
      lua = true;
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
  ];
}
