local M = {}

-- Create autocmd group for our plugin
local rename_group = vim.api.nvim_create_augroup('RenameUI', { clear = true })

-- Configuration with defaults
local config = {
    highlight = 'DiffText', -- Highlight group for the rename area
    border = 'rounded',     -- Border style for the floating window
    width = 30,             -- Default width of rename window
}

-- Function to calculate window width based on current word
local function calculate_width(word)
    return math.max(config.width, #word + 10)
end

-- Create the rename UI window
local function create_rename_window(curr_name)
    local bufnr = vim.api.nvim_create_buf(false, true)
    local width = calculate_width(curr_name)

    -- Get current cursor and window position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor_pos[1]
    local cursor_col = cursor_pos[2]
    local win_height = vim.api.nvim_win_get_height(0)

    -- Determine if we should show above or below
    -- Show above if we're in the bottom half of the window
    local row_offset = cursor_row > (win_height / 2) and -2 or 1

    -- Window configuration
    local win_config = {
        relative = 'cursor',
        row = row_offset,
        col = -cursor_col, -- Align with the start of the line
        width = width,
        height = 1,
        style = 'minimal',
        border = config.border,
    }

    -- Create the window
    local winnr = vim.api.nvim_open_win(bufnr, true, win_config)

    -- Set window options
    vim.wo[winnr].winblend = 0
    vim.wo[winnr].wrap = false

    -- Set buffer options
    vim.bo[bufnr].buftype = 'prompt'
    vim.bo[bufnr].bufhidden = 'wipe'

    -- Set the prompt prefix
    vim.fn.prompt_setprompt(bufnr, 'New Name: ')

    -- Add highlighting
    local ns_id = vim.api.nvim_create_namespace('RenameUI')
    vim.api.nvim_buf_add_highlight(bufnr, ns_id, config.highlight, 0, 0, -1)

    -- Set initial text to current name
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { curr_name })

    -- Set cursor to end of current name
    vim.api.nvim_win_set_cursor(winnr, { 1, #curr_name + 10 })

    return bufnr, winnr
end

function M.rename(new_name, opts)
    opts = opts or {}

    -- If new_name is provided, use LSP rename directly
    if new_name then
        return vim.lsp.buf.rename(new_name, opts)
    end

    -- Get current word
    local curr_name = vim.fn.expand('<cword>')
    if curr_name == '' then
        vim.notify('No word under cursor', vim.log.levels.ERROR)
        return
    end

    local bufnr, winnr = create_rename_window(curr_name)

    -- Set up the prompt callback
    vim.fn.prompt_setcallback(bufnr, function(new_name)
        -- Close the window
        vim.api.nvim_win_close(winnr, true)

        -- If name wasn't changed or is empty, do nothing
        if new_name == '' or new_name == curr_name then
            return
        end

        -- Call LSP rename with new name
        vim.lsp.buf.rename(new_name, opts)
    end)

    -- Handle Escape key
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(winnr, true)
    end, { buffer = bufnr, nowait = true })

    vim.keymap.set('i', '<Esc>', function()
        vim.api.nvim_win_close(winnr, true)
    end, { buffer = bufnr, nowait = true })

    -- Handle window close
    vim.api.nvim_create_autocmd('BufLeave', {
        group = rename_group,
        buffer = bufnr,
        callback = function()
            vim.api.nvim_win_close(winnr, true)
        end,
        once = true,
    })
end

-- Configuration function
function M.setup(opts)
    config = vim.tbl_deep_extend('force', config, opts or {})

    -- Override the default rename keymap
    vim.keymap.set('n', 'gr', M.rename, { desc = 'Rename symbol under cursor' })
end

return M
