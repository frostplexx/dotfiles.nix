return {
    {
        "saghen/blink.cmp",
        lazy = true,
        enabled = true,
event = "InsertEnter",
        version = '*',
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        opts = {
            sources = {
                default = { 'lsp', 'buffer', 'snippets', 'path' },
                providers = {
                    snippets = {
                        name = 'Snippets',
                        module = 'blink.cmp.sources.snippets',
                        opts = {
                            friendly_snippets = true,
                            search_paths = { vim.fn.stdpath('config') .. '/snippets' },
                            global_snippets = { 'all' },
                            extended_filetypes = {},
                            ignored_filetypes = {},
                            get_filetype = function()
                                return vim.bo.filetype
                            end,
                            clipboard_register = nil,
                        }
                    },
                }
            },
            appearance = {
            },
            keymap = { preset = 'super-tab' },
            completion = {
                menu = { border = 'rounded' },
                documentation = { window = { border = 'rounded' } },
            },
            signature = { window = { border = 'rounded' } },

        },
    },
}
