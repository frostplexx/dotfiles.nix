return {
    {
        "lervag/vimtex",
        lazy = true,
        enabled = true,
        event = "BufRead *.tex",
        ft = { "tex" },
        config = function()
            -- Zathura configuration
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_view_zathura_options = {
                "-x", "nvim --headless -c \"VimtexInverseSearch %{line} '%{input}'\"",
                "--synctex-forward", "%{line}:1:%{tex}",
                "--synctex-editor-command", "nvim --headless -c \"VimtexInverseSearch %{line} '%{input}'\""
            }
            
            -- Compilation settings for better zathura integration
            vim.g.vimtex_compiler_latexmk = {
                aux_dir = "build",
                out_dir = "build",
                callback = 1,
                continuous = 1,
                executable = "latexmk",
                hooks = {},
                options = {
                    "-verbose",
                    "-file-line-error",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                },
            }
            
            -- Disable automatic view opening for faster compilation
            vim.g.vimtex_view_automatic = 1
            vim.g.vimtex_view_forward_search_on_start = 0
            
            -- Better error handling
            vim.g.vimtex_quickfix_mode = 0
            
            -- Performance optimization
            vim.g.vimtex_compiler_progname = "nvim"
        end,
    },
}
