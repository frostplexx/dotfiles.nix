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



-- Ensures tabs are used on Makefiles instead of spaces
vim.api.nvim_create_autocmd('FileType', {
    desc = 'Ensures tabs are used on Makefiles instead of spaces',
    callback = function(event)
        if event.match == 'make' then
            vim.o.expandtab = false
        end
    end
})


-- Autocommand to clear search highlight after various events
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'InsertEnter' }, {
    group = vim.api.nvim_create_augroup('SearchHighlight', { clear = true }),
    callback = function()
        -- Only clear if search highlighting is active
        if vim.v.hlsearch == 1 then
            vim.cmd('noh')
        end
    end,
})
