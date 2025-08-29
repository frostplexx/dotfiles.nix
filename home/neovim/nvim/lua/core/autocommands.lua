-- [[ Autocommands ]]

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup


autocmd("BufWritePre", {
    group = augroup('frostplexx/auto_format', { clear = true }),
    desc = "Format the file using LSP or vim's built-in formatter",
    callback = function(args)
        local ignore_ft = { "markdown", "text", "json" }
        if not vim.tbl_contains(ignore_ft, vim.bo.filetype) then
            vim.lsp.buf.format()
        end

        local save = vim.fn.winsaveview()
        vim.api.nvim_buf_set_lines(args.buf, 0, -1, false,
            vim.tbl_map(function(line)
                return line:gsub("%s+$", "")
            end, vim.api.nvim_buf_get_lines(args.buf, 0, -1, false))
        )
        vim.fn.winrestview(save)
    end
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
-- vim.fn.sign_define('todo', {
--     text = tools.ui.icons.ok,
--     texthl = 'TodoSign'
-- })
--
-- -- Setup highlight groups
-- vim.api.nvim_set_hl(0, "TodoKeyword", {
--     fg = "#1e1e2e", -- Dark foreground for better readability
--     bg = "#89b4fa",
--     bold = true,
--     underline = true
-- })
--
-- vim.api.nvim_set_hl(0, "TodoLine", {
--     fg = "#89b4fa",
--     underline = true
-- })
--
-- vim.api.nvim_set_hl(0, "TodoSign", {
--     fg = "#89b4fa"
-- })
--
-- autocmd({ "BufEnter", "BufWinEnter" }, {
--     desc = 'Highlight TODO lines and add signs',
--     pattern = "*",
--     callback = function()
--         -- Clear previous matches and signs
--         vim.fn.clearmatches()
--         vim.fn.sign_unplace('todo_signs')
--
--         -- Match and highlight just the TODO keyword, excluding comment characters
--         vim.fn.matchadd("TodoKeyword", "\\(\\s*\\)\\@<=TODO:")
--         -- Match and highlight the rest of the line after TODO:
--         vim.fn.matchadd("TodoLine", "^.*\\s*TODO:\\zs.*$")
--
--         -- Add signs for lines containing TODO (avoid duplicates)
--         local bufnr = vim.api.nvim_get_current_buf()
--         local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
--         for i, line in ipairs(lines) do
--             if line:match("%s*TODO:") then
--                 vim.fn.sign_place(0, 'todo_signs', 'todo', bufnr, { lnum = i, priority = 10 })
--             end
--         end
--     end
-- })
--
--
-- -- Clean up signs when leaving buffer
-- autocmd("BufLeave", {
--     desc = 'Clean up TODO signs',
--     pattern = "*",
--     callback = function()
--         vim.fn.sign_unplace('todo_signs')
--     end
-- })
