_: {
  flake.homeManagerModules.neovim-keymaps = _: {
    programs.nvf.settings.vim.keymaps = [
      {
        mode = "n";
        key = "<leader>tt";
        action = "function() require('snacks').terminal('/usr/bin/env fish') end";
        desc = "Open terminal in current directory";
        lua = true;
      }

      {
        mode = "n";
        key = "<leader>gi";
        action = "function() require('snacks').picker.gh_issue() end";
        desc = "GitHub Issues (open)";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "function() require('snacks').picker.gh_pr() end";
        desc = "GitHub Pull Requests (open)";
        lua = true;
      }

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
        key = "<leader>db";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() require('snacks').bufdelete() end";
        desc = "Delete current buffer without closing window";
      }
      {
        key = "<leader>fb";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() require('snacks').picker.buffers() end";
        desc = "List open buffers";
      }
      {
        key = "<leader>ss";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() require('snacks').picker.lsp_workspace_symbols() end";
        desc = "Search LSP workspace symbols";
      }
      {
        key = "<leader>tr";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() require('snacks').picker.diagnostic() end";
        desc = "Open diagnostics picker";
      }

      {
        key = "<leader>mk";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() require('snacks').picker.keymaps() end";
        desc = "Show registered keymaps";
      }
      {
        key = "<leader>ms";
        mode = "n";
        noremap = false;
        lua = true;
        silent = true;
        action = "function() require('snacks').picker.marks() end";
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
        action = "function() require('snacks').lazygit() end";
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

      # Tab navigation — unimpaired-style bracket mappings
      {
        key = "]t";
        mode = "n";
        noremap = true;
        action = "<cmd>tabnext<CR>";
        desc = "Next tab";
      }
      {
        key = "[t";
        mode = "n";
        noremap = true;
        action = "<cmd>tabprevious<CR>";
        desc = "Previous tab";
      }

      # Tab management
      {
        key = "<leader>tn";
        mode = "n";
        silent = true;
        action = "<cmd>tabnew<CR>";
        desc = "New tab";
      }
      {
        key = "<leader>tx";
        mode = "n";
        silent = true;
        action = "<cmd>tabclose<CR>";
        desc = "Close current tab";
      }
      {
        key = "<leader>to";
        mode = "n";
        silent = true;
        action = "<cmd>tabonly<CR>";
        desc = "Close other tabs";
      }

      # Jump to tab by number (browser-style Alt+N)
      {
        key = "<A-1>";
        mode = "n";
        action = "<cmd>tabnext 1<CR>";
        desc = "Go to tab 1";
      }
      {
        key = "<A-2>";
        mode = "n";
        action = "<cmd>tabnext 2<CR>";
        desc = "Go to tab 2";
      }
      {
        key = "<A-3>";
        mode = "n";
        action = "<cmd>tabnext 3<CR>";
        desc = "Go to tab 3";
      }
      {
        key = "<A-4>";
        mode = "n";
        action = "<cmd>tabnext 4<CR>";
        desc = "Go to tab 4";
      }
      {
        key = "<A-5>";
        mode = "n";
        action = "<cmd>tabnext 5<CR>";
        desc = "Go to tab 5";
      }
      {
        key = "<A-6>";
        mode = "n";
        action = "<cmd>tabnext 6<CR>";
        desc = "Go to tab 6";
      }
      {
        key = "<A-7>";
        mode = "n";
        action = "<cmd>tabnext 7<CR>";
        desc = "Go to tab 7";
      }
      {
        key = "<A-8>";
        mode = "n";
        action = "<cmd>tabnext 8<CR>";
        desc = "Go to tab 8";
      }
      {
        key = "<A-9>";
        mode = "n";
        action = "<cmd>tabnext 9<CR>";
        desc = "Go to tab 9 (last)";
      }
    ];
  };
}
