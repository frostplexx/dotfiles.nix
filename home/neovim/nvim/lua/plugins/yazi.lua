return {
    "mikavilpas/yazi.nvim",
    lazy = true,
    -- event = "VeryLazy",
    dependencies = {
        -- check the installation instructions at
        -- https://github.com/folke/snacks.nvim
        "folke/snacks.nvim"
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
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
        -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
        -- Block netrw plugin load
        -- vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,
}
