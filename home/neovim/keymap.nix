_: {
  keymaps = [
    {
      mode = "n";
      key = "U";
      action = "<c-r>";
      noremap = false;
      desc = "redo";
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
      key = "<leader>ff";
      mode = "n";
      silent = true;
      noremap = false;
      lua = true;
      action = "function() MiniPick.builtin.files() end";
      desc = "Open file picker";
    }
    {
      key = "<leader>fg";
      mode = "n";
      noremap = false;
      lua = true;
      silent = true;
      action = "function() MiniPick.builtin.grep_live() end";
      desc = "Live grep across project";
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
      key = "<leader>s";
      mode = "v";
      silent = true;
      action = "y:%s/<C-r>/\"//gc<Left><Left><Left>";
      desc = "Search and replace selected text across file";
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
