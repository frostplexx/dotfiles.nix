return {
    {
        "saghen/blink.cmp",
        lazy = true,
        event = "InsertEnter",
        version = '*',
        dependencies = {
            "rafamadriz/friendly-snippets",
            "moyiz/blink-emoji.nvim",
        },
        opts = {
            sources = {
                default = {
                    'lsp',
                    'path',
                    'snippets',
                    'buffer',
                    "emoji",
                },
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
                    emoji = {
                        module = "blink-emoji",
                        name = "Emoji",
                        score_offset = 15,        -- Tune by preference
                        opts = { insert = true }, -- Insert emoji (default) or complete its name
                    }
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
