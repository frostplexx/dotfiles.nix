-- lua/project99/init.lua
local M = {}

M.config = {
    -- The command to run opencode
    cmd = "opencode",

    -- Set the model here (e.g., "gpt-4o", "claude-3-5-sonnet").
    model = "gpt-4o",

    -- System instructions for the function-level trigger (Project 99)
    system_prompt_function = "You are a code generator. " ..
        "Output ONLY the raw code for the following function implementation. " ..
        "Do not use Markdown blocks (```). " ..
        "Do not include explanations or conversational text. " ..
        "Maintain the exact signature provided.",

    -- System instructions for the snippet-level trigger (Project 99 Snippet)
    system_prompt_snippet = "You are an expert coder. " ..
        "You have been given a selected snippet of code and a user instruction. " ..
        "Your task is to follow the instruction and provide the resulting code snippet. " ..
        "Output ONLY the raw, modified, or generated code snippet, ready to be pasted back. " ..
        "Do not use Markdown blocks (```) or add any conversational text.",
}

-- Language-specific node types (used for M.trigger)
local function_node_types = {
    lua = { "function_declaration", "local_function" },
    python = { "function_definition" },
    javascript = { "function_declaration", "arrow_function", "method_definition" },
    typescript = { "function_declaration", "arrow_function", "method_definition" },
    go = { "function_declaration", "method_declaration" },
    rust = { "function_item" },
    c = { "function_definition" },
    cpp = { "function_definition" },
    java = { "method_declaration" },
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})


    vim.keymap.set("n", "<C-c>", M.trigger, { desc = "Fill Function" })
    vim.keymap.set("v", "<C-a>", M.snippet_trigger,
        { noremap = true, silent = true, desc = "Process Snippet (Visual Mode)" })
end

--- Spinner Module ---
local spinner = {}
spinner.ns = vim.api.nvim_create_namespace("llm_spinner")
spinner.timer = nil
spinner.frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }
spinner.frame_idx = 1
spinner.line = -1 -- Line where the spinner is displayed (0-indexed)
spinner.buf = -1

local function update_spinner()
    if spinner.line < 0 or spinner.buf < 0 then
        spinner.frame_idx = 1
        return
    end

    local frame = spinner.frames[spinner.frame_idx]
    -- The spinner text uses the "Comment" highlight group for subtle coloring
    vim.api.nvim_buf_set_virtual_text(spinner.buf, spinner.ns, spinner.line, { { frame .. " Generating...", "Comment" } },
        {})

    spinner.frame_idx = spinner.frame_idx % #spinner.frames + 1
end

function spinner.start(buf, line)
    spinner.buf = buf
    spinner.line = line
    spinner.frame_idx = 1

    -- Clear any previous text
    vim.api.nvim_buf_clear_namespace(spinner.buf, spinner.ns, 0, -1)

    -- Create a new timer if one doesn't exist
    if not spinner.timer then
        spinner.timer = vim.loop.new_timer()
    end

    -- Check if the timer is already running (shouldn't be, but good practice)
    if spinner.timer:is_active() then
        spinner.timer:stop()
    end

    -- Start the timer asynchronously with a faster 60ms interval
    spinner.timer:start(0, 60, vim.schedule_wrap(update_spinner))
end

function spinner.stop()
    if spinner.timer then
        spinner.timer:stop()
    end
    if spinner.buf >= 0 then
        vim.api.nvim_buf_clear_namespace(spinner.buf, spinner.ns, 0, -1)
    end
    spinner.line = -1
    spinner.buf = -1
end

--- End Spinner Module ---

-- Helper to find the surrounding function node (used for the original trigger)
local function get_function_node()
    local node = vim.treesitter.get_node()
    local lang = vim.bo.filetype
    local valid_types = function_node_types[lang]

    if not valid_types then
        vim.notify("Language not mapped: " .. lang, vim.log.levels.WARN)
        return nil
    end

    while node do
        local type = node:type()
        for _, valid_type in ipairs(valid_types) do
            if type == valid_type then return node end
        end
        node = node:parent()
    end
    return nil
end

-- Helper to get the line ranges for a visual selection
local function get_visual_selection_range()
    local current_mode = vim.fn.mode()
    if not (current_mode == 'v' or current_mode == 'V' or current_mode == '') then
        vim.notify("Snippet: Must be in Visual mode ('v', 'V', or '<C-v>').", vim.log.levels.ERROR)
        return nil
    end

    local start_pos = vim.api.nvim_buf_get_mark(0, '<')
    local end_pos = vim.api.nvim_buf_get_mark(0, '>')

    local start_row = start_pos[1] - 1
    local start_col = start_pos[2]
    local end_row = end_pos[1] - 1
    local end_col = end_pos[2] + 1

    if current_mode == 'V' then
        start_col = 0
        end_col = -1 -- -1 means until the end of the line
    end

    return start_row, start_col, end_row, end_col
end

-- Shared logic for running opencode and replacing text
local function run_opencode_and_replace(start_row, start_col, end_row, end_col, prompt, system_prompt, buf)
    -- Display spinner on the first line of the targeted range
    spinner.start(buf, start_row)


    -- Construct the command arguments: opencode run --model <model> <prompt>
    local cmd_args = { M.config.cmd, "run" }

    if M.config.model and M.config.model ~= "" then
        table.insert(cmd_args, "--model")
        table.insert(cmd_args, M.config.model)
    end

    local full_prompt = system_prompt .. "\n\nTask:\n" .. prompt
    table.insert(cmd_args, full_prompt)

    -- Execute opencode
    vim.system(cmd_args, { text = true }, vim.schedule_wrap(function(obj)
        spinner.stop() -- Stop the spinner regardless of outcome

        if obj.code ~= 0 then
            vim.notify("OpenCode Failed\n" .. (obj.stderr or ""), vim.log.levels.ERROR)
            return
        end

        local content = obj.stdout

        -- Clean up potential conversational/markdown residue
        content = content:gsub("^```%w*\n", ""):gsub("\n```$", "")
        content = content:gsub("^Here is the code:[\r\n]*", "")

        local new_lines = {}
        for line in content:gmatch("([^\r\n]*)\r?\n?") do
            table.insert(new_lines, line)
        end
        if new_lines[#new_lines] == "" then table.remove(new_lines) end

        if #new_lines == 0 then
            vim.notify("OpenCode returned empty output. Check OpenCode config or key.", vim.log.levels.WARN)
            return
        end

        -- Use a safer method to manipulate the buffer and re-indent
        vim.api.nvim_buf_set_text(buf, start_row, start_col, end_row, end_col, new_lines)

        -- Determine the start and end 1-indexed lines for re-indentation
        local indent_start_line = start_row + 1
        local indent_end_line = start_row + #new_lines

        -- Use the Ex-command format directly via vim.cmd for re-indentation
        local cmd_string = string.format("%d,%d=", indent_start_line, indent_end_line)
        pcall(vim.cmd, cmd_string)

        -- Redraw and re-trigger filetype hooks
        vim.cmd 'doautocmd FileType'
    end))
end

--- The original function fill trigger (Normal mode) ---
function M.trigger()
    if vim.fn.executable(M.config.cmd) ~= 1 then
        vim.notify(M.config.cmd .. "' command not found in PATH.", vim.log.levels.ERROR)
        return
    end

    local node = get_function_node()
    if not node then
        vim.notify("No function found under cursor.", vim.log.levels.WARN)
        return
    end

    local start_row, start_col, end_row, end_col = node:range()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
    local function_text = table.concat(lines, "\n")

    local prompt = "Implement the logic for this function definition:\n" .. function_text

    run_opencode_and_replace(start_row, start_col, end_row, end_col, prompt, M.config.system_prompt_function, buf)
end

--- The new visual mode snippet trigger ---
function M.snippet_trigger()
    if vim.fn.executable(M.config.cmd) ~= 1 then
        vim.notify(M.config.cmd .. "' command not found in PATH.", vim.log.levels.ERROR)
        return
    end

    local start_row, start_col, end_row, end_col = get_visual_selection_range()
    if not start_row then return end

    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
    local selected_text = table.concat(lines, "\n")

    -- Exit visual mode before running the async call/prompt
    vim.cmd('normal! ' .. vim.fn.mode())

    -- Prompt the user for instructions
    vim.ui.input({ prompt = "Snippet Instruction: " }, function(user_instruction)
        if not user_instruction or user_instruction:match("^%s*$") then
            vim.notify("Snippet: Aborted (No instruction provided).", vim.log.levels.WARN)
            return
        end

        local prompt = user_instruction .. "\n\nSnippet to process:\n" .. selected_text

        -- Use the range and buffer, but with the snippet system prompt
        run_opencode_and_replace(start_row, start_col, end_row, end_col, prompt, M.config.system_prompt_snippet, buf)
    end)
end

return M
