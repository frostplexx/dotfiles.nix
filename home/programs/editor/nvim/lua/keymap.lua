-- [[ keymaps that (re)map vim functions ]]

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim.keymap.set("n", "<leader>bd", ":bd!<cr>", { desc = "delete buffer", silent = true })
vim.keymap.set("n", "<Tab>", ":bnext<cr>", { desc = "next buffer", silent = true })
vim.keymap.set("n", "<S-Tab>", ":bprevious<cr>", { desc = "next buffer", silent = true })

-- remap redo to shift-u
vim.keymap.set("n", "U", "<c-r>", { desc = "redo", noremap = false })

-- scratchpad
vim.keymap.set("n", "<leader>sc", ":lua require('scratch').toggle()<cr>", { desc = "toggle scratchpad", silent = true })

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


-- lazygit
vim.keymap.set("n", "<leader>gg", function()
    vim.cmd("terminal lazygit")
    vim.cmd("startinsert")
    -- Autocmd to close the terminal when lazygit exits
    vim.cmd("autocmd TermClose * if &buftype == 'terminal' && expand('<afile>') =~ 'lazygit' | bd! | endif")
end, { desc = "open lazygit in terminal" })

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
vim.keymap.set("n", "n", "nzzzv", { desc = "move to previous search result" })

-- delete selected text in normal and visual mode without affecting the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "delete without affecting clipboard" })

-- search and replace in the whole file with confirmation, case-insensitive, and whole-word
vim.keymap.set("n", "<leader>s", [[:%s/\<<c-r><c-w>\>/<c-r><c-w>/gi<left><left><left>]],
    { desc = "search and replace in file" })
