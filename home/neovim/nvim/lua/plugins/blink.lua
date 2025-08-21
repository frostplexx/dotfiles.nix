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
            keymap = { preset = 'super-tab' },
            completion = {
                menu = { border = 'rounded' },
                documentation = { window = { border = 'rounded' } },
            },
            signature = { window = { border = 'rounded' } },

        }
    },
}
