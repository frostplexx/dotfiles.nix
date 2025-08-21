vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- remap redo to shift-u
vim.keymap.set("n", "U", "<c-r>", { desc = "redo", noremap = false })

-- Key mappings for LSP actions
vim.keymap.set('n', '<leader>D', vim.diagnostic.setloclist)
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.references)
vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename)
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)
vim.keymap.set('n', 'ca', vim.lsp.buf.code_action)


vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Move selected lines with shift+j or shift+k
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines with shift+j", silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines with shift+k", silent = true })

-- Duplicate a line and comment out the first line
vim.keymap.set('n', 'yc', function() vim.api.nvim_feedkeys('yygccp', 'm', false) end,
    { desc = "Duplicate a line and comment out the first line", silent = true })

-- scroll up half a screen in normal mode, keeping the cursor in the same position
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "scroll up half a screen" })
vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "scroll down half a screen" })

-- move to the next search result and center the screen
vim.keymap.set("n", "n", "nzzzv", { desc = "move to next search result" })

-- move to the previous search result and center the screen
vim.keymap.set("n", "N", "Nzzzv", { desc = "move to previous search result" }) -- Fixed duplicate 'n' mapping

-- delete selected text in normal and visual mode without affecting the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "delete without affecting clipboard" })

-- search and replace in the whole file with confirmation, case-insensitive, and whole-word
vim.keymap.set("n", "<leader>s", [[:%s/\<<c-r><c-w>\>/<c-r><c-w>/gi<left><left><left>]],
    { desc = "search and replace in file" })


vim.keymap.set('n', "<leader>bf",
    function() Snacks.picker.buffers({ layout = { preset = "vscode", preview = "main" } }) end,
    { noremap = true, silent = true })


vim.keymap.set('n', "<Tab>", ":bnext<cr>", { noremap = true, silent = true })
vim.keymap.set('n', "<S-Tab>", ":bprev<cr>", { noremap = true, silent = true })

-- Tabs
vim.keymap.set('n', "<leader>t", ":tabnew<cr>", { desc = "New Tab", noremap = true, silent = true })
vim.keymap.set('n', "<leader>x", ":tabclose<cr>", { desc = "Close Tab", noremap = true, silent = true })
vim.keymap.set('n', "<leader>j", ":tabprevious<cr>", { desc = "Prev Tab", noremap = true, silent = true })
vim.keymap.set('n', "<leader>k", ":tabnext<cr>", { desc = "Next Tab", noremap = true, silent = true })

-- Toggle boolean values (true/false, True/False)
local function toggle_bool()
    local word = vim.fn.expand('<cword>')
    local line = vim.fn.getline('.')
    local col = vim.fn.col('.')

    -- Find the start and end of the current word
    local start_pos = vim.fn.searchpos('\\<' .. word .. '\\>', 'bcnW', vim.fn.line('.'))
    local end_pos = vim.fn.searchpos('\\<' .. word .. '\\>', 'cenW', vim.fn.line('.'))

    if start_pos[1] == 0 or start_pos[2] == 0 or end_pos[1] == 0 or end_pos[2] == 0 then
        print("No boolean word found under cursor")
        return
    end

    local replacement = ''

    -- Check what the current word is and set replacement
    if word == 'true' then
        replacement = 'false'
    elseif word == 'false' then
        replacement = 'true'
    elseif word == 'True' then
        replacement = 'False'
    elseif word == 'False' then
        replacement = 'True'
    else
        print("Word under cursor is not a boolean value")
        return
    end

    -- Replace the word
    local new_line = string.sub(line, 1, start_pos[2] - 1) .. replacement .. string.sub(line, end_pos[2] + 1)
    vim.fn.setline('.', new_line)

    -- Position cursor at the beginning of the replaced word
    vim.fn.cursor(vim.fn.line('.'), start_pos[2])
end

vim.keymap.set('n', 'yt', toggle_bool, { desc = 'Toggle boolean value' })


-- Function to populate quickfix list with LSP diagnostics
local function lsp_diagnostics_to_quickfix()
    -- Get all diagnostics from all buffers
    local diagnostics = vim.diagnostic.get()

    -- If no diagnostics found, show message and return
    if #diagnostics == 0 then
        print("No LSP diagnostics found")
        return
    end

    -- Sort diagnostics by severity, then by file, then by line
    table.sort(diagnostics, function(a, b)
        if a.severity ~= b.severity then
            return a.severity < b.severity -- Errors first (1), then warnings (2), etc.
        end
        local bufname_a = vim.api.nvim_buf_get_name(a.bufnr)
        local bufname_b = vim.api.nvim_buf_get_name(b.bufnr)
        if bufname_a ~= bufname_b then
            return bufname_a < bufname_b
        end
        return a.lnum < b.lnum
    end)

    -- Convert diagnostics to quickfix format with nice formatting
    local qf_items = {}
    local severity_icons = {
        [vim.diagnostic.severity.ERROR] = "󰅚", -- Error icon
        [vim.diagnostic.severity.WARN] = "󰀪", -- Warning icon
        [vim.diagnostic.severity.INFO] = "󰋽", -- Info icon
        [vim.diagnostic.severity.HINT] = "󰌶", -- Hint icon
    }

    local severity_names = {
        [vim.diagnostic.severity.ERROR] = "Error",
        [vim.diagnostic.severity.WARN] = "Warning",
        [vim.diagnostic.severity.INFO] = "Info",
        [vim.diagnostic.severity.HINT] = "Hint",
    }

    for _, diagnostic in ipairs(diagnostics) do
        local bufname = vim.api.nvim_buf_get_name(diagnostic.bufnr)
        local filename = vim.fn.fnamemodify(bufname, ':t')      -- Just the filename
        local relative_path = vim.fn.fnamemodify(bufname, ':.') -- Relative to cwd

        -- Get severity info
        local icon = severity_icons[diagnostic.severity] or "●"
        local severity_name = severity_names[diagnostic.severity] or "Unknown"

        -- Determine type for quickfix
        local type = "E" -- Default to error
        if diagnostic.severity == vim.diagnostic.severity.WARN then
            type = "W"
        elseif diagnostic.severity == vim.diagnostic.severity.INFO then
            type = "I"
        elseif diagnostic.severity == vim.diagnostic.severity.HINT then
            type = "N"
        end

        -- Format the text similar to trouble.nvim
        local source = diagnostic.source and string.format("[%s]", diagnostic.source) or ""
        local formatted_text = string.format(
            "%s %s:%d:%d %s %s %s",
            icon,
            filename,
            diagnostic.lnum + 1,
            diagnostic.col + 1,
            severity_name,
            source,
            diagnostic.message
        )

        table.insert(qf_items, {
            filename = bufname,
            lnum = diagnostic.lnum + 1, -- Convert to 1-indexed
            col = diagnostic.col + 1,   -- Convert to 1-indexed
            text = formatted_text,
            type = type,
            valid = 1
        })
    end

    -- Set the quickfix list with a custom title
    vim.fn.setqflist({}, 'r', {
        title = string.format("LSP Diagnostics (%d items)", #qf_items),
        items = qf_items
    })

    -- Open the quickfix window and resize it
    vim.cmd('copen')
    vim.cmd('wincmd J') -- Move quickfix to bottom
    vim.api.nvim_win_set_height(0, math.min(15, math.max(5, #qf_items + 1)))

    print(string.format("Added %d LSP diagnostics to quickfix list", #qf_items))
end

-- Create the key mapping
vim.keymap.set('n', '<leader>tr', lsp_diagnostics_to_quickfix, {
    desc = 'LSP diagnostics to quickfix',
    silent = true
})
