return {
    {
        src = "https://github.com/lewis6991/gitsigns.nvim",
        name = "gitsigns.nvim",
        keys = {
            { "<leader>gp", ":Gitsigns preview_hunk_inline<cr>", desc = "Git Preview changes" },
            { "<leader>gt", ":Gitsigns toggle_current_line_blame<cr>", desc = "Git Toggle Current Line Blame" },
            { "<leader>gb", ":Gitsigns blame<cr>", desc = "Git Blame" },
            { "<leader>gd", ":Gitsigns diffthis<cr>", desc = "Git Diff This" }
        },
        config = function()
            require("gitsigns").setup()
        end
    }
}