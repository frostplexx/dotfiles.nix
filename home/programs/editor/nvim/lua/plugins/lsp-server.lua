return {
    -- LSP client
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        dependencies = { "dundalek/lazy-lsp.nvim" },
        config = function()
            -- Update diagnostics in insert mode
            vim.diagnostic.config({
                underline = true,
                update_in_insert = true,
                -- virtual_text = {
                --     spacing = 4,
                --     source = "if_many",
                -- },
                -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
                -- Be aware that you also will need to properly configure your LSP server to
                -- provide the code lenses.
                codelens = {
                    enabled = true,
                },
                -- Enable lsp cursor word highlighting
                document_highlight = {
                    enabled = true,
                },
                severity_sort = true,
                float = {
                    focusable = true,
                    style = "minimal",
                    border = "rounded",
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })

            require("lazy-lsp").setup {}

            -- Set the sings
            local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end
        end,
    },
    -- {
    --     "williamboman/mason.nvim",
    --     event = "BufReadPre",
    --     config = function()
    --         require("mason").setup({
    --             ui = {
    --                 icons = {
    --                     package_installed = "✓",
    --                     package_pending = "➜",
    --                     package_uninstalled = "✗",
    --                 },
    --                 border = "rounded",
    --             },
    --         })
    --     end,
    -- },
    -- {
    --     "williamboman/mason-lspconfig.nvim",
    --     event = "BufReadPre",
    --     dependencies = {
    --         "williamboman/mason.nvim",
    --     },
    --     config = function()
    --         require("mason-lspconfig").setup({
    --             ensure_installed = {
    --                 "lua_ls",
    --                 "rust_analyzer",
    --                 "eslint",
    --                 "ts_ls",
    --                 "nil_ls",
    --             },
    --         })
    --
    --         -- set up rounded border
    --         local border = {
    --             { "╭", "FloatBorder" },
    --             { "─", "FloatBorder" },
    --             { "╮", "FloatBorder" },
    --             { "│", "FloatBorder" },
    --             { "╯", "FloatBorder" },
    --             { "─", "FloatBorder" },
    --             { "╰", "FloatBorder" },
    --             { "│", "FloatBorder" },
    --         }
    --
    --         -- LSP settings (for overriding per client)
    --         local handlers = {
    --             -- override border for hover and signature help
    --             ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
    --             ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
    --         }
    --
    --         -- on_attach function to set up keymaps. Runs when attaching LSP to a buffer
    --         local on_attach = function(_, bufnr)
    --             -- Keymaps
    --             local opts = { buffer = bufnr, noremap = true, silent = true }
    --             vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    --             vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    --             vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    --             vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    --             vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, opts)
    --             vim.keymap.set("n", "ca", vim.lsp.buf.code_action, opts)
    --             vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
    --
    --             -- Have floating diagnostics when hovering over error
    --             vim.api.nvim_create_autocmd("CursorHold", {
    --                 buffer = bufnr,
    --                 callback = function()
    --                     local options = {
    --                         focusable = false,
    --                         close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    --                         border = "rounded",
    --                         source = "always",
    --                         prefix = " ",
    --                         scope = "cursor",
    --                     }
    --                     vim.diagnostic.open_float(nil, options)
    --                 end,
    --             })
    --         end
    --
    --         -- Sets up handler for automatically starting LSP servers and attaching them to the current buffer
    --         require("mason-lspconfig").setup_handlers({
    --             function(server_name) -- default handler (optional)
    --                 require("lspconfig")[server_name].setup({
    --                     capabilities = require('blink.cmp').get_lsp_capabilities(),
    --                     handlers = handlers,
    --                     on_attach = on_attach,
    --                 })
    --             end,
    --
    --             -- special case for lua to remove the vim global warning
    --             ["lua_ls"] = function()
    --                 require("lspconfig").lua_ls.setup({
    --                     handlers = handlers,
    --                     on_attach = on_attach,
    --                     capabilities = require('blink.cmp').get_lsp_capabilities(),
    --                     settings = {
    --                         Lua = {
    --                             runtime = {
    --                                 -- Tell the language server which version of Lua you're using
    --                                 -- (most likely LuaJIT in the case of Neovim)
    --                                 version = "LuaJIT",
    --                             },
    --                             diagnostics = {
    --                                 -- Get the language server to recognize the `vim` global
    --                                 globals = {
    --                                     "vim",
    --                                     "require",
    --                                 },
    --                             },
    --                             workspace = {
    --                                 -- Make the server aware of Neovim runtime files
    --                                 library = vim.api.nvim_get_runtime_file("", true),
    --                             },
    --                             -- Do not send telemetry data containing a randomized but unique identifier
    --                             telemetry = {
    --                                 enable = false,
    --                             },
    --                         },
    --                     },
    --                 })
    --             end,
    --         })
    --     end,
    -- },
}
