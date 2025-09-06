return {
    src = "https://github.com/catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = true,
            show_end_of_buffer = false,
            term_colors = true,
            no_italic = false,
            no_bold = false,
            no_underline = false,
            styles = {
                comments = { "italic" },
                conditionals = { "italic" },
            },
            default_integrations = true,
            integrations = {
                cmp = true,
                gitsigns = true,
                treesitter = true,
                mini = {
                    enabled = true,
                },
            },
        })

        vim.cmd.colorscheme("catppuccin-mocha")
    end
}
