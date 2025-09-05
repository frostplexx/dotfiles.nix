return {
    {
        src = "https://github.com/catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",             -- latte, frappe, macchiato, mocha
                transparent_background = true, -- disables setting the background color.
                show_end_of_buffer = false,   -- show the '~' characters after the end of buffers
                term_colors = true,
                no_italic = false,            -- Force no italic
                no_bold = false,              -- Force no bold
                no_underline = false,         -- Force no underline
                styles = {
                    comments = { "italic" },
                    conditionals = { "italic" },
                    loops = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = {},
                    properties = {},
                    types = {},
                    operators = {},
                },
                color_overrides = {},
                custom_highlights = {},
                default_integrations = true,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    treesitter = true,
                    notify = false,
                    mini = {
                        enabled = true,
                        indentscope_color = "",
                    },
                },
            })
        end
    }
}