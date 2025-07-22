-- [[ keymaps that (re)map vim functions ]]

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




-- spotify_player
local function create_float_term()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded'
    })

    return buf
end

vim.keymap.set('n', '<leader>sp', function()
    create_float_term()
    vim.fn.termopen('spotify_player')
    vim.cmd("startinsert")
    vim.cmd("autocmd TermClose * if &buftype == 'terminal' && expand('<afile>') =~ 'spotify_player' | bd! | endif")
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>sn', function()
    vim.schedule(function()
        vim.fn.jobstart('spotify_player playback next', {
            detach = true
        })
    end)
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>sb', function()
    vim.schedule(function()
        vim.fn.jobstart('spotify_player playback previous', {
            detach = true
        })
    end)
end, { noremap = true, silent = true })

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

-- Function to surround current word with quotes
local function surround_word_with_quotes()
    -- Get current cursor position
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')

    -- Get the current line's content
    local current_line = vim.api.nvim_get_current_line()

    -- Find the actual start and end positions of the word
    local word_start_pos = vim.fn.searchpos('\\<' .. vim.fn.expand('<cword>') .. '\\>', 'bcn')
    local word_end_pos = vim.fn.searchpos('\\<' .. vim.fn.expand('<cword>') .. '\\>', 'cen')

    -- Add quotes around the word
    local new_line = string.sub(current_line, 1, word_start_pos[2] - 1)
        .. '"'
        .. string.sub(current_line, word_start_pos[2], word_end_pos[2])
        .. '"'
        .. string.sub(current_line, word_end_pos[2] + 1)

    -- Replace the current line with the modified one
    vim.api.nvim_set_current_line(new_line)

    -- Restore cursor position
    vim.fn.cursor(line, col)
end

-- Function to surround visual selection with quotes
local function surround_visual_with_quotes()
    -- Get visual selection boundaries
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local start_col = start_pos[3]
    local end_line = end_pos[2]
    local end_col = end_pos[3]

    -- If selection is on the same line
    if start_line == end_line then
        local current_line = vim.api.nvim_get_current_line()
        local new_line = string.sub(current_line, 1, start_col - 1)
            .. '"'
            .. string.sub(current_line, start_col, end_col)
            .. '"'
            .. string.sub(current_line, end_col + 1)

        vim.api.nvim_set_current_line(new_line)
    else
        -- Multi-line selection handling
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

        -- Add quotes to first and last line
        lines[1] = string.sub(lines[1], 1, start_col - 1)
            .. '"'
            .. string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
            .. '"'
            .. string.sub(lines[#lines], end_col + 1)

        -- Update buffer with modified lines
        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
    end
end

-- Set up keymaps
-- Normal mode: surround word under cursor with quotes
vim.keymap.set('n', '<leader>q', surround_word_with_quotes, { noremap = true, silent = true })

-- Visual mode: surround selection with quotes
vim.keymap.set('v', '<leader>q', surround_visual_with_quotes, { noremap = true, silent = true })

-- Switch to buffer using <leader>b<bufnr>
vim.keymap.set('n', '<leader>b', ':<C-u>b', { noremap = true, desc = "Switch to buffer by number" })

vim.keymap.set('n', '\'', '`', { noremap = true, desc = "Remap \' to `" })



vim.keymap.set('n', "<leader>bf",
    function() Snacks.picker.buffers({ layout = { preset = "vscode", preview = "main" } }) end,
    { noremap = true, silent = true })


vim.keymap.set('n', "<Tab>", ":bnext<cr>", { noremap = true, silent = true })
vim.keymap.set('n', "<S-Tab>", ":bprev<cr>", { noremap = true, silent = true })

-- Tabs
vim.keymap.set('n', "<leader>tn", ":tabnew<cr>", { desc = "New Tab", noremap = true, silent = true })
vim.keymap.set('n', "<leader>tc", ":tabclose<cr>", { desc = "New Tab", noremap = true, silent = true })

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
        local filename = vim.fn.fnamemodify(bufname, ':t')  -- Just the filename
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
            col = diagnostic.col + 1, -- Convert to 1-indexed
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
