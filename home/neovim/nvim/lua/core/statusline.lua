local fn = vim.fn
local api = vim.api

local M = {}

-- possible values are 'arrow' | 'rounded' | 'blank'
local active_sep = 'arrow'

-- Updated separators with arrow glyphs
M.separators = {
    arrow   = { "", "" },
    rounded = { "", "" },
    blank   = { "", "" },
}

-- Load Catppuccin mocha palette
local mocha = require("catppuccin.palettes").get_palette "mocha"

local function setup_highlights()
    vim.api.nvim_set_hl(0, "Mode", { fg = mocha.text, bg = mocha.surface0, bold = true })
    vim.api.nvim_set_hl(0, "ModeAlt", { fg = mocha.surface0, bg = mocha.surface1 })

    vim.api.nvim_set_hl(0, "Git", { fg = mocha.text, bg = mocha.surface1 })
    vim.api.nvim_set_hl(0, "GitAlt", { fg = mocha.surface1 })

    vim.api.nvim_set_hl(0, "Filetype", { bg = mocha.surface1, fg = mocha.text, italic = true })
    vim.api.nvim_set_hl(0, "FiletypeAlt", { fg = mocha.surface1 })

    vim.api.nvim_set_hl(0, "LineCol", { fg = mocha.text, bg = mocha.surface0, bold = true })
    vim.api.nvim_set_hl(0, "LineColAlt", { fg = mocha.surface0, bg = mocha.surface1 })

    vim.api.nvim_set_hl(0, "ModifiedIcon", { fg = mocha.red })
end

-- Run the setup function to create highlight groups
setup_highlights()

-- highlight groups for statusline
M.colors = {
    active       = '%#StatusLine#',
    inactive     = '%#StatuslineNC#',
    mode         = '%#Mode#',
    mode_alt     = '%#ModeAlt#',
    git          = '%#Git#',
    git_alt      = '%#GitAlt#',
    filetype     = '%#Filetype#',
    filetype_alt = '%#FiletypeAlt#',
    line_col     = '%#LineCol#',
    line_col_alt = '%#LineColAlt#',
}

M.trunc_width = setmetatable({
    mode       = 80,
    git_status = 90,
    filename   = 140,
    line_col   = 60,
}, {
    __index = function()
        return 80
    end
})

M.is_truncated = function(_, width)
    local current_width = api.nvim_win_get_width(0)
    return current_width < width
end

M.modes = setmetatable({
    ['n']  = { 'Normal', 'N' },
    ['no'] = { 'N·Pending', 'N·P' },
    ['v']  = { 'Visual', 'V' },
    ['V']  = { 'V·Line', 'V·L' },
    ['']   = { 'V·Block', 'V·B' },
    ['s']  = { 'Select', 'S' },
    ['S']  = { 'S·Line', 'S·L' },
    ['']   = { 'S·Block', 'S·B' },
    ['i']  = { 'Insert', 'I' },
    ['ic'] = { 'Insert', 'I' },
    ['R']  = { 'Replace', 'R' },
    ['Rv'] = { 'V·Replace', 'V·R' },
    ['c']  = { 'Command', 'C' },
    ['cv'] = { 'Vim·Ex ', 'V·E' },
    ['ce'] = { 'Ex ', 'E' },
    ['r']  = { 'Prompt ', 'P' },
    ['rm'] = { 'More ', 'M' },
    ['r?'] = { 'Confirm ', 'C' },
    ['!']  = { 'Shell ', 'S' },
    ['t']  = { 'Terminal ', 'T' },
}, {
    __index = function()
        return { 'Unknown', 'U' }
    end
})

M.get_current_mode = function(self)
    local current_mode = api.nvim_get_mode().mode
    return string.format(' %s ', self.modes[current_mode][2]):upper()
end

M.get_git_status = function(self)
    local signs = vim.b.gitsigns_status_dict or { head = '', added = 0, changed = 0, removed = 0 }
    local is_head_empty = signs.head ~= ''

    if self:is_truncated(self.trunc_width.git_status) then
        return is_head_empty and string.format('  %s ', signs.head or '') or ''
    end

    return is_head_empty and string.format(
        ' +%s ~%s -%s |  %s ',
        signs.added, signs.changed, signs.removed, signs.head
    ) or ''
end

-- Not used in active statusline anymore
M.get_filename = function(self)
    if self:is_truncated(self.trunc_width.filename) then return " %<%f " end
    return " %<%F "
end

-- M.get_filetype = function()
--     local file_name, file_ext = fn.expand("%:t"), fn.expand("%:e")
--     local icon = require 'nvim-web-devicons'.get_icon(file_name, file_ext, { default = true })
--     local filetype = vim.bo.filetype
--
--     if filetype == '' then return '' end
--     return string.format(' %s %s ', icon, filetype):lower()
-- end

M.get_line_col = function(self)
    if self:is_truncated(self.trunc_width.line_col) then return ' %l:%c ' end
    return ' Ln %l, Col %c '
end


M.get_filetype = function(self)
    local file_name, file_ext = fn.expand("%:t"), fn.expand("%:e")
    local icon = require('nvim-web-devicons').get_icon(file_name, file_ext, { default = true })
    local filetype = vim.bo.filetype

    if filetype == '' then return '' end

    local lsp_clients = vim.lsp.get_active_clients({ bufnr = 0 })
    local lsp_names = {}

    for _, client in ipairs(lsp_clients) do
        table.insert(lsp_names, client.name)
    end

    local lsp_info = ''
    if #lsp_names > 0 then
        lsp_info = ' • ' .. table.concat(lsp_names, ', ')
    end

    return string.format(' %s %s%s ', icon, filetype:lower(), lsp_info)
end

M.set_active = function(self)
    local colors       = self.colors

    local mode         = colors.mode .. self:get_current_mode()
    local mode_alt     = colors.mode_alt .. self.separators[active_sep][1]
    local git          = colors.git .. self:get_git_status()
    local git_alt      = colors.git_alt .. self.separators[active_sep][1]
    local modified     = vim.bo.modified and "%#ModifiedIcon# 󰈙 " or ""
    local filetype_alt = colors.filetype_alt .. self.separators[active_sep][2]
    local filetype     = colors.filetype .. self:get_filetype()
    -- local lsp_clients  = "" .. colors.filetype .. self:get_lsp_clients()
    local line_col     = colors.line_col .. self:get_line_col()
    local line_col_alt = colors.line_col_alt .. self.separators[active_sep][2]

    return table.concat({
        colors.active, mode, mode_alt, git, git_alt, modified,
        "%=", -- Left alignment
        "%=", -- Right alignment
        filetype_alt, filetype, line_col_alt, line_col
    })
end

M.set_inactive = function(self)
    return self.colors.inactive .. '%= %='
end

M.set_explorer = function(self)
    local title     = self.colors.mode .. '   '
    local title_alt = self.colors.mode_alt .. self.separators[active_sep][2]
    return table.concat({ self.colors.active, title, title_alt })
end

Statusline = setmetatable(M, {
    __call = function(statusline, mode)
        if mode == "active" then return statusline:set_active() end
        if mode == "inactive" then return statusline:set_inactive() end
        if mode == "explorer" then return statusline:set_explorer() end
    end
})

api.nvim_exec([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline('explorer')
  augroup END
]], false)

return M
