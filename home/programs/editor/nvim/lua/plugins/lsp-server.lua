return {
    -- LSP client
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        config = function()
            -- Update diagnostics in insert mode
            vim.diagnostic.config({
                underline = true,
                update_in_insert = true,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                },
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


            -- Set the sings
            local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- Notify LSP integration
            local notif_utils = require("notify_utils")

            vim.lsp.handlers["$/progress"] = function(_, result, ctx)
                local client_id = ctx.client_id

                local val = result.value

                if not val.kind then
                    return
                end

                local notif_data = notif_utils.get_notif_data(client_id, result.token)

                if val.kind == "begin" then
                    local message = notif_utils.format_message(val.message, val.percentage)

                    notif_data.notification = vim.notify(message, "info", {
                        title = notif_utils.format_title(val.title, vim.lsp.get_client_by_id(client_id).name),
                        icon = notif_utils.spinner_frames[1],
                        timeout = false,
                        hide_from_history = false,
                    })

                    notif_data.spinner = 1
                    notif_utils.update_spinner(client_id, result.token)
                elseif val.kind == "report" and notif_data then
                    notif_data.notification =
                        vim.notify(notif_utils.format_message(val.message, val.percentage), "info", {
                            replace = notif_data.notification,
                            hide_from_history = false,
                        })
                elseif val.kind == "end" and notif_data then
                    notif_data.notification =
                        vim.notify(val.message and notif_utils.format_message(val.message) or "Complete", "info", {
                            icon = "",
                            replace = notif_data.notification,
                            timeout = 3000,
                        })

                    notif_data.spinner = nil
                end
            end

            -- table from lsp severity to vim severity.
            local severity = {
                "error",
                "warn",
                "info",
                "info", -- map both hint and info to info?
            }
            vim.lsp.handlers["window/showMessage"] = function(err, method, params, client_id)
                vim.notify(method.message, severity[params.type])
            end
        end,
    },
    {
        "williamboman/mason.nvim",
        event = "BufReadPre",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                    border = "rounded",
                },
            })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = "BufReadPre",
        dependencies = {
            "williamboman/mason.nvim",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "rust_analyzer",
                    "eslint",
                    "ts_ls",
                    "nil_ls",
                },
            })

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
                -- override border for hover and signature help
                ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
                ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
            }

            -- on_attach function to set up keymaps. Runs when attaching LSP to a buffer
            local on_attach = function(_, bufnr)
                -- Keymaps
                local opts = { buffer = bufnr, noremap = true, silent = true }
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

                -- Have floating diagnostics when hovering over error
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

            -- Sets up handler for automatically starting LSP servers and attaching them to the current buffer
            require("mason-lspconfig").setup_handlers({
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup({
                        -- capabilities = require("cmp_nvim_lsp").default_capabilities(),
                        handlers = handlers,
                        on_attach = on_attach,
                    })
                end,

                -- special case for lua to remove the vim global warning
                ["lua_ls"] = function()
                    require("lspconfig").lua_ls.setup({
                        handlers = handlers,
                        on_attach = on_attach,
                        -- capabilities = require("cmp_nvim_lsp").default_capabilities(),
                        settings = {
                            Lua = {
                                runtime = {
                                    -- Tell the language server which version of Lua you're using
                                    -- (most likely LuaJIT in the case of Neovim)
                                    version = "LuaJIT",
                                },
                                diagnostics = {
                                    -- Get the language server to recognize the `vim` global
                                    globals = {
                                        "vim",
                                        "require",
                                    },
                                },
                                workspace = {
                                    -- Make the server aware of Neovim runtime files
                                    library = vim.api.nvim_get_runtime_file("", true),
                                },
                                -- Do not send telemetry data containing a randomized but unique identifier
                                telemetry = {
                                    enable = false,
                                },
                            },
                        },
                    })
                end,
            })
        end,
    },
}
