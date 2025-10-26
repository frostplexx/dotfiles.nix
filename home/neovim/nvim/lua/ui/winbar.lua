local miniicons_ok, miniicons = pcall(require, "mini.icons")
local folder_icon = "%#Conditional#" .. tools.ui.kind_icons.Folder .. "%#Normal#"
local file_icon = tools.ui.kind_icons.File

-- Cache highlights setup
local highlights_setup = false
local function setup_highlights()
    if highlights_setup then return end
    local ok, palettes = pcall(require, "catppuccin.palettes")
    if ok then
        local mocha = palettes.get_palette("mocha")
        vim.api.nvim_set_hl(0, "WinbarSeparator", { fg = mocha.green, bold = true })
        vim.api.nvim_set_hl(0, "WinBarDir", { fg = mocha.mauve, italic = true })
        vim.api.nvim_set_hl(0, "Winbar", { fg = mocha.subtext0 })
    end
    highlights_setup = true
end

-- LSP SymbolKind mapping to icons from globals
-- See: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
local kind_icons = {
    "%#File#" .. tools.ui.kind_icons.File .. "%#Normal#",           -- 1: File
    "%#Module#" .. tools.ui.kind_icons.Module .. "%#Normal#",       -- 2: Module
    "%#Structure#" .. tools.ui.kind_icons.Namespace .. "%#Normal#", -- 3: Namespace
    "%#Keyword#" .. tools.ui.kind_icons.Keyword .. "%#Normal#",     -- 4: Package (using Keyword)
    "%#Class#" .. tools.ui.kind_icons.Class .. "%#Normal#",         -- 5: Class
    "%#Method#" .. tools.ui.kind_icons.Method .. "%#Normal#",       -- 6: Method
    "%#Property#" .. tools.ui.kind_icons.Property .. "%#Normal#",   -- 7: Property
    "%#Field#" .. tools.ui.kind_icons.Field .. "%#Normal#",         -- 8: Field
    "%#Function#" .. tools.ui.kind_icons.Constructor .. "%#Normal#", -- 9: Constructor
    "%#Enum#" .. tools.ui.kind_icons.Enum .. "%#Normal#",           -- 10: Enum
    "%#Type#" .. tools.ui.kind_icons.Interface .. "%#Normal#",      -- 11: Interface
    "%#Function#" .. tools.ui.kind_icons.Function .. "%#Normal#",   -- 12: Function
    "%#None#" .. tools.ui.kind_icons.Variable .. "%#Normal#",       -- 13: Variable
    "%#Constant#" .. tools.ui.kind_icons.Constant .. "%#Normal#",   -- 14: Constant
    "%#String#" .. tools.ui.kind_icons.String .. "%#Normal#",       -- 15: String
    "%#Number#" .. tools.ui.kind_icons.Number .. "%#Normal#",       -- 16: Number
    "%#Boolean#" .. tools.ui.kind_icons.Boolean .. "%#Normal#",     -- 17: Boolean
    "%#Array#" .. tools.ui.kind_icons.Array .. "%#Normal#",         -- 18: Array
    "%#Class#" .. tools.ui.kind_icons.Object .. "%#Normal#",        -- 19: Object
    tools.ui.kind_icons.Package,                                    -- 20: Key (using Package)
    tools.ui.kind_icons.Null,                                       -- 21: Null
    tools.ui.kind_icons.EnumMember,                                 -- 22: EnumMember
    "%#Struct#" .. tools.ui.kind_icons.Struct .. "%#Normal#",       -- 23: Struct
    tools.ui.kind_icons.Event,                                      -- 24: Event
    tools.ui.kind_icons.Operator,                                   -- 25: Operator
    tools.ui.kind_icons.TypeParameter,                              -- 26: TypeParameter
}

local function range_contains_pos(range, line, char)
    local start = range.start
    local stop = range['end']

    if line < start.line or line > stop.line then
        return false
    end

    if line == start.line and char < start.character then
        return false
    end

    if line == stop.line and char > stop.character then
        return false
    end

    return true
end

local function find_symbol_path(symbol_list, line, char, path)
    if not symbol_list or #symbol_list == 0 then
        return false
    end

    for _, symbol in ipairs(symbol_list) do
        if range_contains_pos(symbol.range, line, char) then
            local icon = kind_icons[symbol.kind] or ""
            table.insert(path, icon .. " " .. symbol.name)
            find_symbol_path(symbol.children, line, char, path)
            return true
        end
    end
    return false
end

local function lsp_callback(err, symbols, ctx, config)
    if err or not symbols then
        vim.o.winbar = ""
        return
    end

    local winnr = vim.api.nvim_get_current_win()
    local pos = vim.api.nvim_win_get_cursor(0)
    local cursor_line = pos[1] - 1
    local cursor_char = pos[2]

    local file_path = vim.fn.bufname(ctx.bufnr)
    if not file_path or file_path == "" then
        vim.o.winbar = "[No Name]"
        return
    end

    local relative_path

    local clients = vim.lsp.get_clients({ bufnr = ctx.bufnr })

    if #clients > 0 and clients[1].root_dir then
        local root_dir = clients[1].root_dir
        if root_dir == nil then
            relative_path = file_path
        else
            relative_path = vim.fs.relpath(root_dir, file_path)
        end
    else
        local root_dir = vim.fn.getcwd(0)
        relative_path = vim.fs.relpath(root_dir, file_path)
    end

    local breadcrumbs = {}

    -- Check for special directories to abbreviate
    local prefix = ""
    local special_dirs = {
        CODE = vim.g.projects_dir,
        DOTS = vim.env.HOME .. '/dotfiles.nix',
        HOME = vim.env.HOME,
    }

    local normalized_path = vim.fs.normalize(file_path)
    local prefix_path = ""

    for dir_name, dir_path in pairs(special_dirs) do
        if dir_path and vim.startswith(normalized_path, vim.fs.normalize(dir_path)) and #dir_path > #prefix_path then
            prefix = dir_name
            prefix_path = dir_path
        end
    end

    if prefix ~= "" then
        -- Add special directory prefix as first breadcrumb
        table.insert(breadcrumbs, "%#WinBarDir#" .. folder_icon .. " " .. prefix .. "%#Normal#")
        -- Adjust relative_path to be relative to the special directory
        relative_path = normalized_path:gsub("^" .. vim.pesc(vim.fs.normalize(prefix_path)) .. "/?", "")
    end

    local path_components = vim.split(relative_path, "[/\\]", { trimempty = true })
    local num_components = #path_components

    for i, component in ipairs(path_components) do
        if i == num_components then
            local icon
            local icon_hl

            if miniicons_ok then
                icon, icon_hl = miniicons.get("file", component)
            end
            table.insert(breadcrumbs,
                "%#" .. (icon_hl or "Normal") .. "#" .. (icon or file_icon) .. "%#Normal#" .. " " .. component)
        else
            table.insert(breadcrumbs, folder_icon .. " " .. component)
        end
    end
    find_symbol_path(symbols, cursor_line, cursor_char, breadcrumbs)

    local breadcrumb_string = table.concat(breadcrumbs, "%#WinbarSeparator#%#Normal# ")

    if breadcrumb_string ~= "" then
        vim.api.nvim_set_option_value('winbar', breadcrumb_string, { win = winnr })
    else
        vim.api.nvim_set_option_value('winbar', " ", { win = winnr })
    end
end

local function breadcrumbs_set()
    local _ = setup_highlights()

    local bufnr = vim.api.nvim_get_current_buf()
    local winnr = vim.api.nvim_get_current_buf()
    ---@type string
    local uri = vim.lsp.util.make_text_document_params(bufnr)["uri"]
    if not uri then
        vim.print("Error: Could not get URI for buffer. Is it saved?")
        return
    end

    local params = {
        textDocument = {
            uri = uri
        }
    }

    local buf_src = uri:sub(1, uri:find(":") - 1)
    if buf_src ~= "file" then
        vim.o.winbar = ""
        return
    end

    vim.lsp.buf_request(
        bufnr,
        'textDocument/documentSymbol',
        params,
        lsp_callback
    )
end

local breadcrumbs_augroup = vim.api.nvim_create_augroup("Breadcrumbs", { clear = true })

vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    group = breadcrumbs_augroup,
    callback = breadcrumbs_set,
    desc = "Set breadcrumbs.",
})

vim.api.nvim_create_autocmd({ "WinLeave" }, {
    group = breadcrumbs_augroup,
    callback = function()
        vim.o.winbar = ""
    end,
    desc = "Clear breadcrumbs when leaving window.",
})
