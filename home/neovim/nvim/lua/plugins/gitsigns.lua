return {
    src = "https://github.com/lewis6991/gitsigns.nvim",
    defer = true,
    config = function()
        require("gitsigns").setup()

        -- Keymaps
        vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk_inline<cr>", { desc = "Git Preview changes" })
        vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<cr>",
            { desc = "Git Toggle Current Line Blame" })
        vim.keymap.set("n", "<leader>gb", ":Gitsigns blame<cr>", { desc = "Git Blame" })
        vim.keymap.set("n", "<leader>gd", ":Gitsigns diffthis<cr>", { desc = "Git Diff This" })
    end
}
