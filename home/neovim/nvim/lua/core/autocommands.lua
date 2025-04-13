-- [[ Autocommands ]]

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd('FileType', {
    group = augroup('frostplexx/close_with_q', { clear = true }),
    desc = 'Close with <q>',
    pattern = {
        'git',
        'help',
        'man',
        'qf',
        'query',
        'scratch',
    },
    callback = function(args)
        vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = args.buf })
    end,
})

-- Open the file at the last position it was edited earlier
autocmd('BufReadPost', {
    group = augroup('frostplexx/last_location', { clear = true }),
    desc = 'Go to the last location when opening a buffer',
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.cmd 'normal! g`"zz'
        end
    end,
})

autocmd("BufWritePre", {
    group = augroup('frostplexx/auto_format', { clear = true }),
    desc = "Format the file using LSP or vim's built-in formatter",
    callback = function()
            vim.lsp.buf.format()
    end
})


autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = augroup('frostplexx/wshada_on_buf_delete', { clear = true }),
    desc = 'Write to ShaDa when deleting/wiping out buffers',
    command = 'wshada',
})

autocmd('TextYankPost', {
    group = augroup('frostplexx/yank_highlight', { clear = true }),
    desc = 'Highlight on yank',
    callback = function()
        -- Setting a priority higher than the LSP references one.
        vim.hl.on_yank { higroup = 'Visual', priority = 250 }
    end,
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
        vim.fn.matchadd("TodoKeyword", "\\(\\s*\\)\\@<=TODO:")
        -- Match and highlight the rest of the line after TODO:
        vim.fn.matchadd("TodoLine", "^.*\\s*TODO:\\zs.*$")

        -- Add signs for lines containing TODO
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        for i, line in ipairs(lines) do
            if line:match("%s*TODO:") then
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
