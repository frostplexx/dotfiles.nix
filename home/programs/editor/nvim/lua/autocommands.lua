-- [[ Autocommands ]]
--
local fn = vim.fn

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight the yanked text
autocmd("TextYankPost", {
    desc = "Highlight the selection on yank.",
    callback = function()
        vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
    end,
})

-- Open the file at the last position it was edited earlier
autocmd("BufReadPost", {
    desc = "Open file at the last position it was edited earlier",
    group = augroup("open_file_at_last_position", { clear = true }),
    pattern = "*",
    command = 'silent! normal! g`"zv',
})


-- Ensures tabs are used on Makefiles instead of spaces
autocmd('FileType', {
    desc = 'Ensures tabs are used on Makefiles instead of spaces',
    callback = function(event)
        if event.match == 'make' then
            vim.o.expandtab = false
        end
    end
})


vim.api.nvim_set_hl(0, "Todo", { fg = "#f9e2af", bold = true }) -- Red and bold
autocmd({ "BufEnter", "BufWinEnter" }, {
    desc = 'Highlight TODOs',
    pattern = "*",
    callback = function()
        vim.fn.matchadd("Todo", "^TODO:")
    end
})
