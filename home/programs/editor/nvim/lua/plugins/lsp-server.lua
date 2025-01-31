return {
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        dependencies = { "dundalek/lazy-lsp.nvim" },
        config = function()
            -- Update diagnostics in insert mode
            vim.diagnostic.config({
                underline = true,
                update_in_insert = true,
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
                severity_sort = true,
                float = {
                    focusable = true,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })

            -- Set the signs
            local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

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

            -- LSP settings (for overriding per client)
            local handlers = {
                ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
                ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
            }

            -- on_attach function to set up keymaps
            local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr, noremap = true, silent = true }
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

                -- Floating diagnostics on hover
                vim.api.nvim_create_autocmd("CursorHold", {
                    buffer = bufnr,
                    callback = function()
                        local options = {
                            focusable = false,
                            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                            border = "rounded",
                            source = "always",
                            prefix = " ",
                            scope = "cursor",
                        }
                        vim.diagnostic.open_float(nil, options)
                    end,
                })
            end

            require("lazy-lsp").setup {
                default_config = {
                    handlers = handlers,
                    on_attach = on_attach,
                    capabilities = require('blink.cmp').get_lsp_capabilities(),
                },
                excluded_servers = {
                    "ccls",            -- prefer clangd
                    "denols",          -- prefer eslint and ts_ls
                    "docker_compose_language_service", -- yamlls should be enough?
                    "flow",            -- prefer eslint and ts_ls
                    "ltex",            -- grammar tool using too much CPU
                    "quick_lint_js",   -- prefer eslint and ts_ls
                    "scry",            -- archived on Jun 1, 2023
                    "tailwindcss",     -- associates with too many filetypes
                    "biome",           -- not mature enough to be default
                },
                preferred_servers = {
                    markdown = {},
                    python = { "basedpyright", "ruff" },
                },
                configs = {
                    -- Special configuration for lua_ls
                    lua_ls = {
                        settings = {
                            Lua = {
                                runtime = {
                                    version = "LuaJIT",
                                },
                                diagnostics = {
                                    globals = {
                                        "vim",
                                        "require",
                                    },
                                },
                                workspace = {
                                    library = vim.api.nvim_get_runtime_file("", true),
                                },
                                telemetry = {
                                    enable = false,
                                },
                            },
                        },
                    },
                },
            }
        end,
    },
}
