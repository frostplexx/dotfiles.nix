-- [[ Vim options ]]
vim.cmd.colorscheme("catppuccin-macchiato")

-- Make current line number brighter than the rest
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#8087a2", bold = false })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#b4befe", bold = true })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#8087a2", bold = false })


vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.foldmethod = "manual"
vim.opt.hlsearch = false
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.completeopt = "menuone,noselect"
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.textwidth = 125
vim.opt.colorcolumn = "125"
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.g.vimtex_view_method = "skim"

vim.opt.numberwidth = 4                                  -- Minimal number of columns to use for the line number
vim.opt.signcolumn = "yes:1"                             -- Always show signcolumn (after line numbers)
vim.wo.statuscolumn = '%=%{v:relnum?v:relnum:v:lnum} %s' -- Custom format that places signs after numbers

vim.opt.shortmess:remove('S')                            -- Show search count
vim.opt.hlsearch = true                                  -- Highlight all matches

-- Indentation and tab settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true


-- diff mopde settings
-- show merged at the bottom
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
  vim.o.guifont = "JetbrainsMono Nerd Font:h13"
  vim.g.neovide_padding_top = 15
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
  vim.g.neovide_floating_shadow = false
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_scroll_animation_far_lines = 5
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_refresh_rate = 144
  vim.g.neovide_refresh_rate_idle = 1
  vim.g.neovide_no_idle = false
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
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
