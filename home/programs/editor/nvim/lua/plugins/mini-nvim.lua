return {
    "echasnovski/mini.nvim",
    version = false,
    lazy = true,
    event = "BufReadPost",
    enabled = true,
    config = function()
        -- [[ Gitsigns ]]]

        -- [[ Mini Files ]]
        -- require("mini.files").setup({
        --   -- Customization of shown content
        --   content = {
        --     -- Predicate for which file system entries to show
        --     filter = nil,
        --     -- What prefix to show to the left of file system entry
        --     prefix = nil,
        --     -- In which order to show file system entries
        --     sort = nil,
        --   },
        --
        --   -- Module mappings created only inside explorer.
        --   -- Use `''` (empty string) to not create one.
        --   mappings = {
        --     close       = 'q',
        --     go_in       = 'l',
        --     go_in_plus  = '<cr>',
        --     go_out      = 'h',
        --     go_out_plus = 'H',
        --     mark_goto   = "'",
        --     mark_set    = 'm',
        --     reset       = '<BS>',
        --     reveal_cwd  = '@',
        --     show_help   = 'g?',
        --     synchronize = '=',
        --     trim_left   = '<',
        --     trim_right  = '>',
        --   },
        --
        --   -- General options
        --   options = {
        --     -- Whether to delete permanently or move into module-specific trash
        --     permanent_delete = false,
        --     -- Whether to use for editing directories
        --     use_as_default_explorer = true,
        --   },
        --
        --   -- Customization of explorer windows
        --   windows = {
        --     -- Maximum number of windows to show side by side
        --     max_number = math.huge,
        --     -- Whether to show preview of file/directory under cursor
        --     preview = true,
        --     -- Width of focused window
        --     width_focus = 50,
        --     -- Width of non-focused window
        --     width_nofocus = 15,
        --     -- Width of preview window
        --     width_preview = 25,
        --   },
        -- })

        -- [[ Mini Indetenscope ]]
        -- require("mini.indentscope").setup({
        --     -- Draw options
        --     draw = {
        --         -- Delay (in ms) between event and start of drawing scope indicator
        --         delay = 0,
        --         animation = require("mini.indentscope").gen_animation.none(),
        --     },
        --
        --     -- Module mappings. Use `''` (empty string) to disable one.
        --     mappings = {
        --         -- Textobjects
        --         object_scope = "ii",
        --         object_scope_with_border = "ai",
        --
        --         -- Motions (jump to respective border line; if not present - body line)
        --         goto_top = "[i",
        --         goto_bottom = "]i",
        --     },
        --
        --     -- Options which control scope computation
        --     options = {
        --         border = "both",
        --         indent_at_cursor = true,
        --         try_as_border = false,
        --     },
        --     symbol = "│",
        -- })

        -- [[ Mini Pairs ]]
        require("mini.pairs").setup({
            disablee_in_macro = false,
            map_cr = false,
        })

        -- [[ Mini Surround ]]
        require("mini.surround").setup()

        local statusline = function()
            local mini = require("mini.statusline")

            local mode, mode_hl = mini.section_mode({ trunc_width = 9999 })
            local git = mini.section_git({ trunc_width = 75 })
            local diagnostics = mini.section_diagnostics({ trunc_width = 75 })
            local filename = mini.section_filename({ trunc_width = 140 })
            local fileinfo = mini.section_fileinfo({ trunc_width = 9999 })
            local location = mini.section_location({ trunc_width = 9999 })
            local search = mini.section_searchcount({ trunc_width = 0 })
            local diff = mini.section_diff({ trunc_width = 0 })

            local function show_macro_recording()
                local recording_register = vim.fn.reg_recording()
                if recording_register == "" then
                    return ""
                else
                    return "recording @" .. recording_register
                end
            end

            vim.api.nvim_set_hl(0, "MiniStatuslineGit", { bg = "", fg = "#cad3f5" })
            vim.api.nvim_set_hl(0, "MiniStatuslineRecording", { bg = "", fg = "#8aadf4" })
            vim.api.nvim_set_hl(0, "MiniStatuslineFilepath", { bg = "", fg = "#8087a2" })

            return mini.combine_groups({
                { hl = mode_hl,             strings = { mode } },
                { hl = "MiniStatuslineGit", strings = { git, diff, diagnostics } },
                "%<", -- truncate point
                { hl = "MiniStatuslineRecording", strings = { show_macro_recording() } },
                { hl = "MiniStatuslineFilepath",  strings = { filename } },
                "%=", -- end left alignment
                { hl = "MiniStatuslineLocation", strings = { search, location } },
                { hl = mode_hl,                  strings = { fileinfo } },
            })
        end

        local inactive = function()
            local mini = require("mini.statusline")
            local filename = mini.section_filename({ trunc_width = 140 })
            local fileinfo = mini.section_fileinfo({ trunc_width = 9999 })
            return mini.combine_groups({
                { hl = "MiniStatuslineLocation", strings = { filename } },
                "%=", -- end left alignment
                { hl = "MiniStatuslineLocation", strings = { fileinfo } },
            })
        end

        -- -- [[ Mini Statusline ]]
        require("mini.statusline").setup(
        -- No need to copy this inside `setup()`. Will be used automatically.
            {
                content = {
                    active = statusline,
                    inactive = inactive,
                },
                use_icons = true,
                set_vim_settings = true,
            }
        )
    end,
    -- keys = {
    --   { "<leader>e", ":lua MiniFiles.open()<cr>", desc = "Mini Files" }
    -- }
}
