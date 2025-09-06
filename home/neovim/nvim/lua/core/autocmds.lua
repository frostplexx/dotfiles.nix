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

autocmd("PackChanged", {
    callback = function(args)
        local kind = args.data.kind ---@type string

        if kind == "install" or kind == "update" then
            local spec = args.data.spec ---@type UnPack.Spec

            commands.build({ spec })
        end
    end,
    group = group,
})
