return {
    {
        "lervag/vimtex",
        lazy = true,
        enabled = true,
        event = "BufRead *.tex",
        ft = { "tex" },
        config = function()
            -- Zathura configuration
            vim.g.vimtex_view_method = "skim"
            vim.g.vimtex_quickfix_mode = 0
            vim.g.tex_flavor = 'latex'
        end,
    },
}
