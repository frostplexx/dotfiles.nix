return {
    {
        src = "https://github.com/mikavilpas/yazi.nvim",
        name = "yazi",
        -- Keymaps (preserved from original keys table)
        keys = {
            {
                "<leader>e",
                "<cmd>Yazi toggle<cr>",
                desc = "Open the file manager in nvim's working directory",
            },
        },
        config = function()
            -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
            -- Block netrw plugin load
            -- vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            require("yazi").setup({
                open_for_directories = true,
                yazi_floating_window_border = 'rounded',
            })
        end
    },
    {
        src = "https://github.com/nvim-lua/plenary.nvim",
        name = "plenary.nvim",
    }
}