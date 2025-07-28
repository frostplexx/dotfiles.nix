-- [[ LSP ]]

-- Set up autocommands to attach to lsp
local lsp_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h") .. '/../../lsp'


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

-- enable lsp completion
-- vim.api.nvim_create_autocmd("LspAttach", {
--     group = vim.api.nvim_create_augroup("frostplexx/attach_lsp", { clear = true }),
--     callback = function(ev)
--         vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
--     end,
-- })


-- set default root marker
local capabilities = require('blink.cmp').get_lsp_capabilities()
vim.lsp.config('*', {
    root_markers = { '.git' },
    capabilities = capabilities
})

-- Define the diagnostic signs.
for severity, icon in pairs(tools.ui.diagnostics) do
    local hl = 'DiagnosticSign' .. severity:sub(1, 1) .. severity:sub(2):lower()
    vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

-- Diagnostic configuration.
vim.diagnostic.config {
    virtual_text = {
        prefix = '',
        spacing = 2,
        format = function(diagnostic)
            -- Use shorter, nicer names for some sources:
            local special_sources = {
                ['Lua Diagnostics.'] = 'lua',
                ['Lua Syntax Check.'] = 'lua',
            }
            local prefix = tools.ui.diagnostics[vim.diagnostic.severity[diagnostic.severity]]
            local message = diagnostic.message
            -- local source = ''
            -- if diagnostic.source then
            --     source = string.format(' (%s)', special_sources[diagnostic.source] or diagnostic.source)
            -- end
            -- local code = ''
            -- if diagnostic.code then
            --     code = string.format('[%s]', diagnostic.code)
            -- end
            -- return string.format('%s%s%s: %s', prefix, source, code, message)
            return string.format('%s %s', prefix, message)
        end,
    },
    float = {
        source = 'if_many',
        -- Show severity icons as prefixes.
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format(' %s ', diagnostic_icons[level])
            return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
        end,
    },
    -- Disable signs in the gutter.
    signs = false,
}



-- Override the virtual text diagnostic handler so that the most severe diagnostic is shown first.
local show_handler = vim.diagnostic.handlers.virtual_text.show
assert(show_handler)
local hide_handler = vim.diagnostic.handlers.virtual_text.hide
vim.diagnostic.handlers.virtual_text = {
    show = function(ns, bufnr, diagnostics, opts)
        table.sort(diagnostics, function(diag1, diag2)
            return diag1.severity > diag2.severity
        end)
        return show_handler(ns, bufnr, diagnostics, opts)
    end,
    hide = hide_handler,
}

local hover = vim.lsp.buf.hover
vim.lsp.buf.hover = function()
    return hover {
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

local signature_help = vim.lsp.buf.signature_help
vim.lsp.buf.signature_help = function()
    return signature_help {
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end
