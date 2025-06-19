-- [[ Vim options ]]

-- Defer highlight setup to avoid startup delay
vim.schedule(function()
    vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#403d52", bold = false })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#c4a7e7", bold = true })
    vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#403d52", bold = false })
end)

-- Essential options first
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- Show whitespace (simplified)
vim.opt.list = true
vim.opt.listchars = { space = '⋅', trail = '⋅', tab = '  ↦' }

vim.opt.foldmethod = "manual"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.breakindent = true

-- Case insensitive searching UNLESS /C or the search has capitals.
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.showmode = false
vim.opt.wildignore:append { '.DS_Store' }
vim.o.completeopt = "menu,menuone,popup,fuzzy"

-- Status line.
vim.opt.cmdheight = 0
vim.o.laststatus = 3

vim.opt.textwidth = 160
vim.opt.colorcolumn = "160"

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes:1"
vim.opt.isfname:append("@-@")

-- Update times and timeouts.
vim.o.updatetime = 250 -- Faster updates
vim.o.timeoutlen = 300 -- Faster key timeout
vim.o.ttimeoutlen = 10

vim.g.vimtex_view_method = "skim"

vim.opt.numberwidth = 3
vim.o.statuscolumn = ""

vim.opt.shortmess:remove('S')

-- Indentation and tab settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Diff mode settings
vim.opt.diffopt:append("algorithm:histogram,indent-heuristic")
vim.opt.diffopt:append("filler,closeoff,vertical")

-- File and backup settings
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- [[ Neovide Config ]]
if vim.g.neovide then
    vim.o.guifont = "Maple Mono NF:h13"
    vim.g.neovide_padding_top = 15
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0
    vim.g.neovide_floating_shadow = false
    vim.g.neovide_cursor_animate_in_insert_mode = false -- Disable for speed
    vim.g.neovide_scroll_animation_far_lines = 1        -- Reduce animation
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_refresh_rate = 144
    vim.g.neovide_refresh_rate_idle = 5 -- Increase idle refresh
    vim.g.neovide_no_idle = false
    vim.g.neovide_cursor_antialiasing = true
    vim.g.neovide_cursor_vfx_mode = "" -- Disable VFX for performance
    vim.g.neovide_transparency = 0.0
    vim.g.transparency = 0.75
    vim.g.neovide_window_blurred = true
    vim.g.neovide_floating_blur_amount_x = 5.0
    vim.g.neovide_floating_blur_amount_y = 0.0
    local alpha = function()
        return string.format("%x", math.floor((255 * vim.g.transparency) or 0.8))
    end
    vim.g.neovide_background_color = "#24273A" .. alpha()
end

-- [[ Filetypes ]]
vim.filetype.add({
    pattern = {
        [".*/templates/.*%.yaml"] = "helm",
    },
})
