-- [[ Vim options ]]

-- Defer highlight setup to avoid startup delay
vim.schedule(function()
    vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#403d52", bold = false })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#c4a7e7", bold = true })
    vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#403d52", bold = false })
end)

-- Essential options first
vim.o.nu = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.clipboard = "unnamedplus"


-- Show whitespace (simplified)
vim.o.list = true
vim.o.listchars = { space = '⋅', trail = '⋅', tab = '  ↦' }

vim.o.foldmethod = "manual"
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.breakindent = true

-- Case insensitive searching UNLESS /C or the search has capitals.
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.showmode = false
vim.o.wildignore:append { '.DS_Store' }
vim.o.completeopt = "menu,menuone,popup,fuzzy"

-- Status line.
vim.o.cmdheight = 0
vim.o.laststatus = 3

vim.o.textwidth = 160
vim.o.colorcolumn = "160"


vim.o.winborder = "rounded"

vim.o.scrolloff = 8
vim.o.signcolumn = "yes:1"
vim.o.isfname:append("@-@")

-- Update times and timeouts.
vim.o.updatetime = 250 -- Faster updates
vim.o.timeoutlen = 300 -- Faster key timeout
vim.o.ttimeoutlen = 10

vim.g.vimtex_view_method = "skim"

vim.o.numberwidth = 3
vim.o.statuscolumn = ""

vim.o.shortmess:remove('S')

-- Indentation and tab settings
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

-- Diff mode settings
vim.o.diffopt:append("algorithm:histogram,indent-heuristic")
vim.o.diffopt:append("filler,closeoff,vertical")

-- File and backup settings
vim.o.wrap = false
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true

-- [[ Filetypes ]]
vim.filetype.add({
    pattern = {
        [".*/templates/.*%.yaml"] = "helm",
    },
})
