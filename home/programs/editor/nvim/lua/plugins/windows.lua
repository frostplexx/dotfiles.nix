return {
    "anuvyklack/windows.nvim",
    enabled = true,
    lazy = true,
    event = "BufRead",
    config = function()
        require('windows').setup()
    end,
    dependencies = {
        "anuvyklack/middleclass"
    },
    keys = {
        { "<leader>wm", ":WindowsMaximize<cr>", desc = "Maximise Window", silent = true }
    },
}
