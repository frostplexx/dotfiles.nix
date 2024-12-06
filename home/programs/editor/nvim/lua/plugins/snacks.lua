return {
    "folke/snacks.nvim",
    priority = 1000,
    -- A couple of plugins require snacks.nvim to be set-up early. Setup creates some autocmds and does not load any plugins.
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
            notification = {
                wo = { wrap = true } -- Wrap notifications
            }
        }
    },
    keys = {
        { "<leader>sC", function() Snacks.scratch() end,               desc = "Toggle Scratch Buffer" },
        { "<leader>sc", function() Snacks.scratch.select() end,        desc = "Select Scratch Buffer" },
        { "<leader>bd", function() Snacks.bufdelete.delete() end,      desc = "Delete Buffer" },
        { "<leader>gg", function() Snacks.lazygit() end,               desc = "Lazygit" },
        { "<leader>un", function() Snacks.notifier.hide() end,         desc = "Dismiss All Notifications" },
        { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    }
}
