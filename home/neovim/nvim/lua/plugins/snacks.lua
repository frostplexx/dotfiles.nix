return {
    src = "https://github.com/folke/snacks.nvim",
    defer = true,
    config = function()
        require("snacks").setup {
            lazygit = {},
            notifier = {},
            input = {},
            picker = {},
            terminal = {},
        }
        vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Open Lazygit", silent = true })
        vim.keymap.set("n", "<leader>n", function() Snacks.picker.notifications() end,
            { desc = "Notification History", silent = true })
    end
}
