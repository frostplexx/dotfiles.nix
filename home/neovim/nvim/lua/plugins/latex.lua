return {
    src = "https://github.com/lervag/vimtex",
    defer = true,
    config = function()
        -- Skim configuration for macOS
        vim.g.vimtex_view_method = "skim"
        vim.g.vimtex_quickfix_mode = 0
        vim.g.tex_flavor = 'latex'
    end
}
