-- [[ Autocommands ]]

-- Highlight the yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight the selection on yank.",
    callback = function()
        vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
    end,
})

-- Open the file at the last position it was edited earlier
vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Open file at the last position it was edited earlier",
    group = vim.api.nvim_create_augroup("open_file_at_last_position", { clear = true }),
    pattern = "*",
    command = 'silent! normal! g`"zv',
})
