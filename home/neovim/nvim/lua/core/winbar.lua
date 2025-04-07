local folder_icon = require('core.icons').symbol_kinds.Folder

local function setup_highlights()
    local mocha = require("catppuccin.palettes").get_palette "mocha"
    vim.api.nvim_set_hl(0, "WinbarSeparator", { fg = mocha.green, bold = true })
    vim.api.nvim_set_hl(0, "WinBarDir", { fg = mocha.mauve, italic = true })
    vim.api.nvim_set_hl(0, "Winbar", { fg = mocha.subtext0 })
end


local M = {}

--- Window bar that shows the current file path (in a fancy way).
---@return string
function M.render()
    setup_highlights()
    -- Get the path and expand variables.
    local path = vim.fs.normalize(vim.fn.expand '%:p' --[[@as string]])

    -- No special styling for diff views.
    if vim.startswith(path, 'diffview') then
        return string.format('%%#Winbar#%s', path)
    end

    -- Replace slashes by arrows.
    local separator = ' %#WinbarSeparator# '

    local prefix, prefix_path = '', ''

    -- If the window gets too narrow, shorten the path and drop the prefix.
    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
        path = vim.fn.pathshorten(path)
    else
        -- For some special folders, add a prefix instead of the full path (making
        -- sure to pick the longest prefix).
        ---@type table<string, string>
        local special_dirs = {
            CODE = vim.g.projects_dir,
            DOTS = vim.env.HOME .. '/dotfiles.nix',
            HOME = vim.env.HOME,
        }
        for dir_name, dir_path in pairs(special_dirs) do
            if vim.startswith(path, vim.fs.normalize(dir_path)) and #dir_path > #prefix_path then
                prefix, prefix_path = dir_name, dir_path
            end
        end
        if prefix ~= '' then
            path = path:gsub('^' .. prefix_path, '')
            prefix = string.format('%%#WinBarDir#%s %s%s', folder_icon, prefix, separator)
        end
    end

    -- Remove leading slash.
    path = path:gsub('^/', '')

    return table.concat {
        ' ',
        prefix,
        table.concat(
            vim.iter(vim.split(path, '/'))
            :map(function(segment)
                return string.format('%%#Winbar#%s', segment)
            end)
            :totable(),
            separator
        ),
    }
end

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('frostplexx/winbar', { clear = true }),
    desc = 'Attach winbar',
    callback = function(args)
        if
            not vim.api.nvim_win_get_config(0).zindex     -- Not a floating window
            and vim.bo[args.buf].buftype == ''            -- Normal buffer
            and vim.api.nvim_buf_get_name(args.buf) ~= '' -- Has a file name
            and not vim.wo[0].diff                        -- Not in diff mode
        then
            vim.wo.winbar = "%{%v:lua.require'core.winbar'.render()%}"
        end
    end,
})

return M
