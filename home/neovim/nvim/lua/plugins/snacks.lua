return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    event = "VeryLazy",
    opts = {
        bigfile = {
            enabled = true,
            notify = false,  -- Reduce notifications for speed
            size = 50 * 1024 -- Reduce threshold to 50KB for better performance
        },
        animate = {
            enabled = true,
            duration = 20, -- ms per step
            easing = "linear",
            fps = 144,     -- frames per second. Global setting for all animations
        },
        debug = { enabled = false },
        input = { enabled = true },
        scope = { enabled = false },
        -- indent = {
        --     enabled = true, -- enable indent guides
        --     hl = "SnacksIndent5", ---@type string|string[] hl groups for indent guides
        --     animate = {
        --         enabled = false
        --     },
        --     scope = {
        --         underline = true,
        --         hl = "SnacksIndent2", ---@type string|string[] hl group for scopes
        --     },
        -- },
        image = {
            formats = { 'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'tiff', 'heic', 'avif', 'mp4', 'mov', 'avi', 'mkv', 'webm' },
            force = false, -- try displaying the image, even if the terminal does not support it
            markdown = {
                -- enable image viewer for markdown files
                -- if your env doesn't support unicode placeholders, this will be disabled
                enabled = true,
                max_width = 80,
                max_height = 40,
            },
            -- window options applied to windows displaying image buffers
            -- an image buffer is a buffer with `filetype=image`
            wo = {
                wrap = false,
                number = false,
                relativenumber = false,
                cursorcolumn = false,
                signcolumn = 'no',
                foldcolumn = '0',
                list = false,
                spell = false,
                statuscolumn = '',
            },

        },
        notifier = {
            enabled = true,
        },
        notify = {
            enabled = true,
        },
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
            refresh = 100, -- refresh at most every 50ms
        },
        scroll = { enabled = false },
        words = { enabled = true },

        picker = {
            enabled = true,
            win = {
                -- input window
                input = {
                    keys = {
                        ["<Esc>"] = { "close", mode = { "n", "i" } },
                    },
                },
            },
            reverse = true,
        },
        dashboard = {
            width = 60,
            row = nil,                                                                   -- dashboard position. nil for center
            col = nil,                                                                   -- dashboard position. nil for center
            pane_gap = 4,                                                                -- empty columns between vertical panes
            autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence
            -- These settings are used by some built-in sections
            preset = {
                header = [[
   .          .
 ';;,.        ::'
,:::;,,        :ccc,
,::c::,,,,.     :cccc,
,cccc:;;;;;.    cllll,
,cccc;.;;;;;,   cllll;
:cccc; .;;;;;;. coooo;
;llll;   ,:::::'loooo;
;llll:    ':::::loooo:
:oooo:     .::::llodd:
.;ooo:       ;cclooo:.
.;oc        'coo;.
  .'         .,. ]],
                footer = "test"
            },
            formats = {
                header = { "%s", align = "center" },
            },
            sections = {
                { section = "header" },
            },
        }

    },
    keys = {
        { "<leader>z",       function() Snacks.zen() end,                                                                              desc = "Toggle Zen Mode" },
        { "<leader>.",       function() Snacks.scratch() end,                                                                          desc = "Toggle Scratch Buffer" },
        { "<leader>S",       function() Snacks.scratch.select() end,                                                                   desc = "Select Scratch Buffer" },
        { "<leader>n",       function() Snacks.notifier.show_history() end,                                                            desc = "Notification History" },
        { "<leader>bd",      function() Snacks.bufdelete() end,                                                                        desc = "Delete Buffer" },
        { "<leader>cR",      function() Snacks.rename.rename_file() end,                                                               desc = "Rename File" },
        { "<leader>gf",      function() Snacks.lazygit.log_file() end,                                                                 desc = "Lazygit Current File History" },
        { "<leader>gg",      function() Snacks.lazygit() end,                                                                          desc = "Lazygit" },
        { "<leader>gl",      function() Snacks.lazygit.log() end,                                                                      desc = "Lazygit Log (cwd)" },
        { "<leader>go",      function() Snacks.gitbrowse() end,                                                                        desc = "Open Current Repo in Browser" },
        { "<leader>un",      function() Snacks.notifier.hide() end,                                                                    desc = "Dismiss All Notifications" },
        { "]]",              function() Snacks.words.jump(vim.v.count1) end,                                                           desc = "Next Reference",              mode = { "n", "t" } },
        { "[[",              function() Snacks.words.jump(-vim.v.count1) end,                                                          desc = "Prev Reference",              mode = { "n", "t" } },
        { "<leader><space>", function() Snacks.picker.files() end,                                                                     desc = "Find Files",                  remap = true,       silent = true },
        { "<leader>ch",      function() Snacks.picker.command_history({ layout = { preset = "vscode", preview = "main" } }) end,       desc = "Command History",             silent = true },
        { "<leader>km",      function() Snacks.picker.keymaps() end,                                                                   desc = "Keymap",                      silent = true },
        { "<leader>fg",      function() Snacks.picker.grep() end,                                                                      desc = "Live Grep",                   silent = true },
        { "<leader>fh",      function() Snacks.picker.help({ layout = { preset = "vscode", preview = "main" } }) end,                  desc = "Help Tags",                   silent = true },
        { "<leader>ss",      function() Snacks.picker.lsp_workspace_symbols({ layout = { preset = "vscode", preview = "main" } }) end, desc = "LSP Symbols" },
        { "<leader>ms",      function() Snacks.picker.marks() end,                                                                     desc = "Show Marks" },
        { "<leader>cu",      function() Snacks.picker.undo({ layout = { preset = "vscode", preview = "main" } }) end,                  desc = "Undo Tree" },


    },
}
