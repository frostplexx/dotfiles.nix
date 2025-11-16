vim.pack.add({
    { src = "https://github.com/mikavilpas/yazi.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary.nvim" },
})
require("yazi").setup({
    open_for_directories = true,
    yazi_floating_window_border = "rounded",
})
-- Keymaps
vim.keymap.set(
    "n",
    "<leader>e",
    "<cmd>Yazi toggle<cr>",
    { desc = "Open the file manager in nvim's working directory" }
)
