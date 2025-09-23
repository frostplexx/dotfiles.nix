vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


vim.pack.add({
    "https://github.com/catppuccin/nvim",
    "https://github.com/echasnovski/mini.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter"
})

require('mini.icons').setup()
require('mini.surround').setup()
require('mini.bufremove').setup()
require('mini.ai').setup()
require('mini.cursorword').setup()
require('mini.extra').setup()
require('mini.pick').setup()
require('mini.statusline').setup()
require('mini.completion').setup({
    window = {
        info = { border = rounded },
        signature = { border = rounded },
    },
})
require('mini.files').setup()

require('mini.move').setup({
    -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
    mappings = {
        left = '<S-h>',
        right = '<S-l>',
        down = '<S-j>',
        up = '<S-k>',
    },
})
require("nvim-treesitter.configs").setup({
    auto_install = true,
})

require("catppuccin").setup({
    transparent_background = true,
    float = {
        transparent = true, -- enable transparent floating windows
        solid = false,      -- use solid styling for floating windows, see |winborder|
    },
    integrations = {
        treesitter = true,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
    }
})

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.compatible = false
vim.cmd.colorscheme("catppuccin-mocha")

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.breakindent = true


vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.showmode = false
vim.opt.wildignore:append { '.DS_Store' }

vim.opt.signcolumn = "yes:1"
vim.opt.isfname:append("@-@")

vim.opt.winborder = "rounded"

vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.fileencoding = "utf-8"

vim.keymap.set('n', "<Tab>", ":bnext<cr>", { noremap = true, silent = true })
vim.keymap.set('n', "<S-Tab>", ":bprev<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- remap redo to shift-u
vim.keymap.set("n", "U", "<c-r>", { desc = "redo", noremap = false })

-- Key mappings for LSP actions
vim.keymap.set('n', '<leader>D', vim.diagnostic.setloclist)
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.references)
vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename)
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)
vim.keymap.set('n', 'ca', vim.lsp.buf.code_action)


-- scroll up half a screen in normal mode, keeping the cursor in the same position
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "scroll up half a screen" })
vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "scroll down half a screen" })

vim.keymap.set("n", "n", "nzzzv", { desc = "move to next search result" })     -- move to the next search result and center the screen
vim.keymap.set("n", "N", "Nzzzv", { desc = "move to previous search result" }) -- move to the previous search result and center the screen

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format file" })

vim.keymap.set('v', '<leader>s', 'y:%s/<C-r>"//gc<Left><Left><Left>',
    { desc = 'Search and replace selected text across file' })

vim.keymap.set("n", "<leader>d", function() MiniBufremove.delete() end,
    { desc = "Delete Buffer", remap = true, silent = true })
vim.keymap.set("n", "<leader><space>", function() MiniPick.builtin.files() end,
    { desc = "FFF Files", remap = true, silent = true })
vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end,
    { desc = "Live Grep", remap = true, silent = true })
vim.keymap.set("n", "<leader>ss", function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end,
    { desc = "Workspace Symbols", remap = true, silent = true })
vim.keymap.set("n", "<leader>tr", function() MiniExtra.pickers.diagnostic() end,
    { desc = "Diagnostics", remap = true, silent = true })
vim.keymap.set("n", "<leader>gi", function() MiniExtra.pickers.git_hunks() end,
    { desc = "Git Hunks", remap = true, silent = true })
vim.keymap.set("n", "<leader>bf", function() MiniPick.builtin.buffers() end,
    { desc = "Buffers", remap = true, silent = true })
vim.keymap.set("n", "<leader>ch", function() MiniExtra.pickers.history() end,
    { desc = "Command History", remap = true, silent = true })
vim.keymap.set("n", "<leader>mk", function() MiniExtra.pickers.keymaps() end,
    { desc = "Keymaps", remap = true, silent = true })
vim.keymap.set("n", "<leader>ms", function() MiniExtra.pickers.marks() end,
    { desc = "Marks", remap = true, silent = true })
vim.keymap.set("n", "<leader>e", function() MiniFiles.open() end,
    { desc = "Open the file manager in nvim's working directory" })


-- Set up autocommands to attach to lsp
local lsp_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h") .. '/lsp'

-- vim.print(vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h") .. 'lsp')

-- Load LSPs dynamically from the lsp directory
for _, file in ipairs(vim.fn.readdir(lsp_dir)) do
    local lsp_name = file:match("(.+)%.lua$")
    if lsp_name then
        local ok, err = pcall(vim.lsp.enable, lsp_name)
        if not ok then
            vim.notify(
                string.format("Failed to load LSP: %s\nError: %s", lsp_name, err),
                vim.log.levels.WARN,
                {
                    title = "LSP Load Error",
                    icon = "󰅚 ",
                    timeout = 5000
                }
            )
        end
    end
end


vim.lsp.inlay_hint.enable(true)
