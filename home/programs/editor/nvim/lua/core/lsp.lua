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

-- set up rounded border
local border = {
    { "╭", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╮", "FloatBorder" },
    { "│", "FloatBorder" },
    { "╯", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╰", "FloatBorder" },
    { "│", "FloatBorder" },
}
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = border
    }
)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = border
    }
)

-- set default capabilities for every lsp server
vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
    root_markers = { '.git' }
})

-- configure diagnostics design
vim.diagnostic.config({
    update_in_insert = true,
    virtual_lines = false, -- disable if you dont want multiline diagnostics as virtual lines
    -- enable if you want previous diagnostics behaviour
    -- virtual_text = false,
    virtual_text = {
        spacing = 4,
        source = "if_many",
    },
    codelens = {
        enabled = true,
    },
    document_highlight = {
        enabled = true,
    },
    underline_style = {
        [vim.diagnostic.severity.ERROR] = "curly",
        [vim.diagnostic.severity.WARN] = "curly",
        [vim.diagnostic.severity.INFO] = "underline",
        [vim.diagnostic.severity.HINT] = "underline",
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
            [vim.diagnostic.severity.INFO] = " ",
        },
        numhl = {
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
    },
    underline = {
        severity = {
            min = vim.diagnostic.severity.HINT,
        },
    },
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = border,
        source = "if_many",
        header = "",
        prefix = "",
    },
})

-- enable lsp completion
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
    end,
})

-- LSP Progress
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params
            .value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        if not client or type(value) ~= "table" then
            return
        end
        local p = progress[client.id]
        for i = 1, #p + 1 do
            if i == #p + 1 or p[i].token == ev.data.params.token then
                p[i] = {
                    token = ev.data.params.token,
                    msg = ("[%3d%%] %s%s"):format(
                        value.kind == "end" and 100 or value.percentage or 100,
                        value.title or "",
                        value.message and (" **%s**"):format(value.message) or ""
                    ),
                    done = value.kind == "end",
                }
                break
            end
        end

        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v)
            return table.insert(msg, v.msg) or not v.done
        end, p)

        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(table.concat(msg, "\n"), "info", {
            id = "lsp_progress",
            title = client.name,
            opts = function(notif)
                notif.icon = #progress[client.id] == 0 and " "
                    or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
        })
    end,
})
