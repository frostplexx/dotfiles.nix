return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "mocha",             -- latte, frappe, macchiato, mocha
        transparent_background = true, -- disables setting the background color.
        float = {
            transparent = true,        -- enable transparent floating windows
            solid = false,             -- use solid styling for floating windows, see |winborder|
        },
        integrations = {
            blink_cmp = true,
            gitsigns = true,
            lsp_trouble = true,
            treesitter = true,
            dap = true,
            dap_ui = true,
            snacks = true,
        },
    }
}
