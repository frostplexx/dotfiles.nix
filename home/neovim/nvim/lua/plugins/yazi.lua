return {
    "mikavilpas/yazi.nvim",
    lazy = true,
    version = "*", -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
        { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
        {
            -- Open in the current working directory
            "<leader>e",
            "<cmd>Yazi toggle<cr>",
            desc = "Open the file manager in nvim's working directory",
        },
    },
    opts = {
        open_for_directories = true,
        yazi_floating_window_border = 'rounded',
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
        -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
        -- Block netrw plugin load
        -- vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,
}
