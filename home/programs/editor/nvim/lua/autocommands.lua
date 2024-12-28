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


-- LSP Progress
---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params
        .value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        if not client or type(value) ~= "table" then
            return
        end
        local p = progress[client.id]

        for i = 1, #p + 1 do
            if i == #p + 1 or p[i].token == ev.data.params.token then
                p[i] = {
                    token = ev.data.params.token,
                    msg = ("[%3d%%] %s%s"):format(
                        value.kind == "end" and 100 or value.percentage or 100,
                        value.title or "",
                        value.message and (" **%s**"):format(value.message) or ""
                    ),
                    done = value.kind == "end",
                }
                break
            end
        end

        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v)
            return table.insert(msg, v.msg) or not v.done
        end, p)

        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(table.concat(msg, "\n"), "info", {
            id = "lsp_progress",
            title = client.name,
            opts = function(notif)
                notif.icon = #progress[client.id] == 0 and " "
                    or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
        })
    end,
})
