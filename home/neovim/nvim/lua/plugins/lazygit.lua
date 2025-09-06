return {
    src = "https://github.com/kdheepak/lazygit.nvim",
    defer = true,
    dependencies = {
        {
            src = "https://github.com/nvim-lua/plenary.nvim",
        }
    },
    config = function()
        -- Keymaps
        vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
    end
}
