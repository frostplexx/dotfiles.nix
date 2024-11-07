-- [[ keymaps that (re)map vim functions ]]


vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>q", ":wqa<cr>", { desc = "quit", silent = true })
vim.keymap.set("n", "<leader>q", ":qa!<cr>", { desc = "quit without saving", silent = true })

vim.keymap.set("n", "<leader>bd", ":bd<cr>", { desc = "delete buffer", silent = true })

-- remap redo to u
vim.keymap.set("n", "U", "<c-r>", { desc = "redo", noremap = false })

-- scratchpad
vim.keymap.set("n", "sc", ":lua require('scratch').toggle()<cr>", { desc = "toggle scratchpad", silent = true })

-- lazygit
vim.keymap.set("n", "<leader>gg", function()
    vim.cmd("terminal lazygit")
    vim.cmd("startinsert")
    -- Autocmd to close the terminal when lazygit exits
    vim.cmd("autocmd TermClose * if &buftype == 'terminal' && expand('<afile>') =~ 'lazygit' | bd! | endif")
end, { desc = "open lazygit in terminal" })

vim.keymap.set("n", "<leader>gb", ":!git blame -c -- % <cr>", { desc = "git blame on current file" })

-- ctrl-a to select all
vim.keymap.set("n", "<c-a>", "ggvgo", { desc = "select all text" })

-- rearrange visually selected lines in normal mode
vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "rearrange selected lines" })

-- scroll up half a screen in normal mode, keeping the cursor in the same position
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "scroll up half a screen" })

-- move to the next search result and center the screen
vim.keymap.set("n", "n", "nzzzv", { desc = "move to next search result" })

-- move to the previous search result and center the screen
vim.keymap.set("n", "n", "nzzzv", { desc = "move to previous search result" })

-- delete selected text in visual mode and paste it at the cursor position
vim.keymap.set("x", "<leader>p", [["_dp]], { desc = "cut and paste selected text" })

-- delete selected text in normal and visual mode without affecting the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "delete without affecting clipboard" })

-- search and replace in the whole file with confirmation, case-insensitive, and whole-word
vim.keymap.set("n", "<leader>s", [[:%s/\<<c-r><c-w>\>/<c-r><c-w>/gi<left><left><left>]],
    { desc = "search and replace in file" })

-- diff mode keymap
vim.keymap.set({ "n", "v" }, "dpr", ":diffput REMOTE <cr>", { desc = "Diff Put Remote" })
vim.keymap.set({ "n", "v" }, "dpl", ":diffput LOCAL <cr>", { desc = "Diff Put Local" })
vim.keymap.set({ "n", "v" }, "dgr", ":diffget REMOTE <cr>", { desc = "Diff Get Remote" })
vim.keymap.set({ "n", "v" }, "dgl", ":diffget LOCAL <cr>", { desc = "Diff Get Local" })
