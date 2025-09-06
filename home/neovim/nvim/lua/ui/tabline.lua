local M = {}

vim.o.showtabline = 1
vim.o.tabline = "%!v:lua.require('ui.tabline').render()"


local function get_file_icon(filename, bufnr)
    if filename == "[No Name]" then
        return "󰎛 "
    end

    -- Try to get icon from Mini.icons
    local ok, mini_icons = pcall(require, "mini.icons")
    if ok then
        local icon, hl = mini_icons.get("file", filename)
        if icon then
            return "%#" .. hl .. "#" .. icon .. "%*" .. " "
        end
    end

    return "󰈙 "
end

local function get_modified_indicator(bufnr)
    if vim.fn.getbufvar(bufnr, "&modified") == 1 then
        return " ●"
    end
    return ""
end

function M.render()
    local current = vim.fn.tabpagenr()
    local total = vim.fn.tabpagenr("$")
    local out = {}

    for tab = 1, total do
        local is_current = tab == current
        local tab_hl = is_current and "%#TabLineSel#" or "%#TabLine#"

        local names = {}
        local modified = false

        for _, buf in ipairs(vim.fn.tabpagebuflist(tab)) do
            if vim.fn.buflisted(buf) == 1 then
                local n = vim.fn.bufname(buf)
                if n == "" then n = "[No Name]" end
                local filename = vim.fn.fnamemodify(n, ":t")
                local file_icon = get_file_icon(filename, buf)
                local mod_indicator = get_modified_indicator(buf)

                if mod_indicator ~= "" then
                    modified = true
                end

                table.insert(names, file_icon .. filename .. mod_indicator)
            end
        end
        local tab_content = table.concat(names, " ")
        local max_width = 50  -- Increased from 30 to give more space
        if #tab_content > max_width then
            tab_content = tab_content:sub(1, max_width - 3) .. "..."
        end

        table.insert(
            out,
            string.format("%s %s %s",
                tab_hl,
                tab_content,
                "%#TabLineFill#"
            )
        )
    end

    return "%#TabLineFill#" .. table.concat(out, "") .. "%#TabLineFill#"
end

return M
