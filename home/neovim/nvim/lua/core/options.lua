vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.compatible = false


-- Show whitespace
vim.opt.list = true
vim.opt.listchars = { space = ' ', trail = '⋅', tab = '  ↦' }

vim.opt.foldmethod = "manual"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.breakindent = true

-- Case insensitive searching UNLESS /C or the search has capitals.
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.showmode = false
vim.opt.wildignore:append { '.DS_Store' }

-- Status line.
vim.opt.cmdheight = 0
vim.opt.laststatus = 2

vim.opt.textwidth = 160
vim.opt.colorcolumn = "0"


vim.opt.winborder = "rounded"

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes:1"
vim.opt.isfname:append("@-@")

vim.opt.numberwidth = 3
vim.opt.statuscolumn = ""

vim.opt.shortmess:remove('S')

-- Indentation and tab settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.fileencoding = "utf-8"

-- Diff mode settings
vim.opt.diffopt:append("algorithm:histogram,indent-heuristic")
vim.opt.diffopt:append("filler,closeoff,vertical")

-- File and backup settings
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.exrc = true
vim.opt.secure = true
local workspace_path = vim.fn.getcwd()
local cache_dir = vim.fn.stdpath("data")
local unique_id = vim.fn.fnamemodify(workspace_path, ":t") ..
    "_" .. vim.fn.sha256(workspace_path):sub(1, 8) ---@type string
local shadafile = cache_dir .. "/myshada/" .. unique_id .. ".shada"

vim.opt.shadafile = shadafile

vim.opt.switchbuf = "usetab"

-- Disable built-in plugins
vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tutor = 1
vim.g.loaded_spellfile = 1
vim.g.loaded_rplugin = 1
vim.g.loaded_net = 1
vim.g.loaded_osc52 = 1
vim.g.loaded_shada = 1
vim.g.loaded_tohtml = 1

-- [[ Filetypes ]]
vim.filetype.add({
    pattern = {
        [".*/templates/.*%.yaml"] = "helm",
        [".*%.base"] = "yaml",
        ["%.env%.[%w_.-]+"] = "conf",
    },
    filename = {
        [".env"] = "conf",
        ["tsconfig.json"] = "jsonc",
        [".yamlfmt"] = "yaml",
    },
    extension = {
        conf = "conf",
        env = "conf",
        tiltfile = "tiltfile",
        Tiltfile = "tiltfile",
    },
})
