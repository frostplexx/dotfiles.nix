-- [[ Autocommands ]]

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd('TextYankPost', {
    group = augroup('frostplexx/yank_highlight', { clear = true }),
    desc = 'Highlight on yank',
    callback = function()
        -- Setting a priority higher than the LSP references one.
        vim.hl.on_yank { higroup = 'Visual', priority = 250 }
    end,
})


autocmd('BufWinEnter', {
    group = augroup('frostplexx/marks', { clear = true }),
    desc = 'Show marks in signcolumn',
    callback = function(args)
        require("ui.marks").BufWinEnterHandler(args)
    end
})


autocmd('VimEnter', {
    group = augroup('frostplexx/enter', { clear = true }),
    desc = 'Open last used file',
    callback = function()
        -- Only restore if no files were opened and we're in the starting buffer
        if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == '' then
            -- Check if oldfiles exist and the first one is readable
            local oldfiles = vim.v.oldfiles
            if oldfiles and #oldfiles > 0 and vim.fn.filereadable(oldfiles[1]) == 1 then
                vim.cmd("edit " .. vim.fn.fnameescape(oldfiles[1]))
                -- Force filetype detection
                vim.cmd("filetype detect")
                -- Alternative: you could also use
                -- vim.bo.filetype = vim.filetype.match({ filename = oldfiles[1] })
            end
        end
    end
})
