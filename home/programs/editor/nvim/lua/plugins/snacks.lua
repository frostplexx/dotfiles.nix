return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = {
            enabled = true,
            notify = true,
            size = 100 * 1024 -- 100Kb
        },
        animate = {
            enabled = true,
            duration = 20, -- ms per step
            easing = "linear",
            fps = 144,     -- frames per second. Global setting for all animations
        },
        debug = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        statuscolumn = {
            enabled = true,
            left = { "mark", "sign" }, -- priority of signs on the left (high to low)
            right = { "fold", "git" }, -- priority of signs on the right (high to low)
            folds = {
                open = false,          -- show open fold icons
                git_hl = false,        -- use Git Signs hl for fold icons
            },
            git = {
                -- patterns to match Git signs
                patterns = { "GitSign", "MiniDiffSign" },
            },
            refresh = 50, -- refresh at most every 50ms
        },
        scroll = { enabled = false },
        words = { enabled = true },

        picker = {
            win = {
                -- input window
                input = {
                    keys = {
                        ["<Esc>"] = { "close", mode = { "n", "i" } },
                    },
                },
            },
            reverse = true,
        }
    },
    keys = {
        { "<leader>z",       function() Snacks.zen() end,                     desc = "Toggle Zen Mode" },
        { "<leader>.",       function() Snacks.scratch() end,                 desc = "Toggle Scratch Buffer" },
        { "<leader>S",       function() Snacks.scratch.select() end,          desc = "Select Scratch Buffer" },
        { "<leader>n",       function() Snacks.notifier.show_history() end,   desc = "Notification History" },
        { "<leader>bd",      function() Snacks.bufdelete() end,               desc = "Delete Buffer" },
        { "<leader>cR",      function() Snacks.rename.rename_file() end,      desc = "Rename File" },
        { "<leader>gf",      function() Snacks.lazygit.log_file() end,        desc = "Lazygit Current File History" },
        { "<leader>gg",      function() Snacks.lazygit() end,                 desc = "Lazygit" },
        { "<leader>gl",      function() Snacks.lazygit.log() end,             desc = "Lazygit Log (cwd)" },
        { "<leader>go",      function() Snacks.gitbrowse() end,               desc = "Open Current Repo in Browser" },
        { "<leader>un",      function() Snacks.notifier.hide() end,           desc = "Dismiss All Notifications" },
        { "]]",              function() Snacks.words.jump(vim.v.count1) end,  desc = "Next Reference",              mode = { "n", "t" } },
        { "[[",              function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference",              mode = { "n", "t" } },

        { "<leader><space>", function() Snacks.picker.files() end,            desc = "Find Files",                  remap = true,       silent = true },
        { "<leader>bf",      function() Snacks.picker.buffers() end,          desc = "List open Buffers",           remap = true,       silent = true },
        { "<leader>ch",      function() Snacks.picker.command_history() end,  desc = "Command History",             silent = true },
        { "<leader>km",      function() Snacks.picker.keymaps() end,          desc = "Keymap",                      silent = true },
        { "<leader>fg",      function() Snacks.picker.grep() end,             desc = "Live Grep",                   silent = true },
        { "<leader>fh",      function() Snacks.picker.help() end,             desc = "Help Tags",                   silent = true },
        { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,      desc = "LSP Symbols" },


    },
}
