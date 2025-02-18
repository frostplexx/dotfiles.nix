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

autocmd("BufWritePre", {
    desc = "Format the file using LSP or vim's built-in formatter",
    callback = function()
        -- Save the cursor position
        local cursor_pos = vim.fn.getpos(".")
        local has_lsp = next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil

        if has_lsp then
            vim.lsp.buf.format()
        else
            -- Save the current view (scroll position, etc.)
            local view = vim.fn.winsaveview()
            vim.cmd("normal! gg=G")
            -- Restore the view
            vim.fn.winrestview(view)
        end

        -- Restore the cursor position
        vim.fn.setpos(".", cursor_pos)
    end
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


-- Create sign for TODOs
vim.fn.sign_define('todo', {
    text = '✓',
    texthl = 'TodoSign'
})

-- Setup highlight groups
vim.api.nvim_set_hl(0, "TodoKeyword", {
    fg = "#1e1e2e", -- Dark foreground for better readability
    bg = "#89b4fa",
    bold = true,
    underline = true
})

vim.api.nvim_set_hl(0, "TodoLine", {
    fg = "#89b4fa",
    underline = true
})

vim.api.nvim_set_hl(0, "TodoSign", {
    fg = "#89b4fa"
})

autocmd({ "BufEnter", "BufWinEnter" }, {
    desc = 'Highlight TODO lines and add signs',
    pattern = "*",
    callback = function()
        -- Match and highlight just the TODO keyword, excluding comment characters
        vim.fn.matchadd("TodoKeyword", "\\(//\\s*\\)\\@<=TODO:")
        -- Match and highlight the rest of the line after TODO:
        vim.fn.matchadd("TodoLine", "^.*//\\s*TODO:\\zs.*$")

        -- Add signs for lines containing TODO
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        for i, line in ipairs(lines) do
            if line:match("//%s*TODO:") then
                vim.fn.sign_place(0, 'todo_signs', 'todo', bufnr, { lnum = i })
            end
        end
    end
})

-- Clean up signs when leaving buffer
autocmd("BufLeave", {
    desc = 'Clean up TODO signs',
    pattern = "*",
    callback = function()
        vim.fn.sign_unplace('todo_signs')
    end
})
