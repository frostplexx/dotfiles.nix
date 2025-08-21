return {
    "mikavilpas/yazi.nvim",
    lazy = true,
    version = "*", -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
        -- check the installation instructions at
        -- https://github.com/folke/snacks.nvim
        "folke/snacks.nvim",
        { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
        {
            -- Open in the current working directory
            "<leader>e",
            "<cmd>Yazi<cr>",
            desc = "Open the file manager in nvim's working directory",
        },
        {
            '<c-up>',
            "<cmd>Yazi toggle<cr>",
            desc = "Resume the last yazi session",
        },
    },
    opts = {
        -- if you want to open yazi instead of netrw, see below for more info
        open_for_directories = true,
        keymaps = {
            show_help = 'g?',
        },
        open_multiple_tabs = true,
        -- window border is set in the yazi config see ~/dotfiles.nix/home/programs/shell/default.nix
        yazi_floating_window_border = 'rounded',
        yazi_floating_window_winblend = 0,
        floating_window_scaling_factor = 0.9,
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
        -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
        -- Block netrw plugin load
        -- vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,
}
