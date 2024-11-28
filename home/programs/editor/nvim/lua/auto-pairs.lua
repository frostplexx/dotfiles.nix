local M = {}

-- Map of opening characters to their closing pairs
local pair_matches = {
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['"'] = '"',
    ["'"] = "'",
    ['`'] = '`'
}


-- Helper function to check if we're in a string or comment
local function in_string_or_comment()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    local context = vim.treesitter.get_node_at_pos(0, vim.fn.line('.') - 1, col - 1)

    if context then
        local type = context:type()
        return type == 'string' or type == 'comment' or type == 'string_content'
    end
    return false
end

-- Helper function to get char at cursor
local function get_char_at_cursor()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return line:sub(col + 1, col + 1)
end

-- Helper function to get char before cursor
local function get_char_before_cursor()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return line:sub(col, col)
end

-- Check if we should auto-close
local function should_auto_close(char)
    -- Get current context
    local next_char = get_char_at_cursor()
    local prev_char = get_char_before_cursor()

    -- Don't auto-close if we're between the same characters (prevents doubling)
    if prev_char == char and next_char == pair_matches[char] then
        return false
    end

    -- Don't auto-close quotes in comments
    if (char == '"' or char == "'" or char == '`') and in_string_or_comment() then
        return false
    end

    -- Don't auto-close if next char is alphanumeric (likely in the middle of a word)
    if next_char:match('[%w_]') then
        return false
    end

    return true
end

-- Handle pair insertion
local function handle_pair(char)
    if not should_auto_close(char) then
        return char
    end

    local close = pair_matches[char]
    if close then
        -- Insert the pair and move cursor back one character
        return char .. close .. '<Left>'
    end
    return char
end

-- Handle backspace between pairs
local function handle_backspace()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_before = line:sub(col, col)
    local char_after = line:sub(col + 1, col + 1)

    -- Check if we're between a pair
    if pair_matches[char_before] == char_after then
        -- Delete both characters
        return '<BS><Del>'
    end
    return '<BS>'
end

function M.setup()
    -- Create the autocommand group
    local group = vim.api.nvim_create_augroup('AutoPairs', { clear = true })

    -- Set up mappings for each pair
    for open, _ in pairs(pair_matches) do
        vim.keymap.set('i', open, function()
            return handle_pair(open)
        end, { expr = true, buffer = true })
    end

    -- Handle backspace between pairs
    vim.keymap.set('i', '<BS>', function()
        return handle_backspace()
    end, { expr = true, buffer = true })

    -- Create autocommand for new buffers
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = '*',
        callback = function()
            -- Set up the mappings for this buffer
            for open, _ in pairs(pair_matches) do
                vim.keymap.set('i', open, function()
                    return handle_pair(open)
                end, { expr = true, buffer = true })
            end

            vim.keymap.set('i', '<BS>', function()
                return handle_backspace()
            end, { expr = true, buffer = true })
        end,
    })
end

return M
