return {
    { -- Collection of various small independent plugins/modules
        'echasnovski/mini.nvim',
        event = "VeryLazy",
        enabled = true,
        config = function()
            local function get_buffer_list()
                local buffers = vim.fn.getbufinfo({ buflisted = 1 })
                local current_buf = vim.fn.bufnr('%')
                local buf_list = {}

                for _, buf in ipairs(buffers) do
                    local name = vim.fn.fnamemodify(buf.name, ':t') -- Get only filename for non-active buffers
                    local modified = buf.changed == 1 and "+" or ""
                    local buffer_text = string.format("%d:%s%s", buf.bufnr, name, modified)

                    if buf.bufnr == current_buf then
                        -- Show full path and highlight active buffer
                        name = vim.fn.fnamemodify(buf.name, ':~:.')
                        buffer_text = string.format("%%#MiniStatuslineActiveBuffer#%d:%s%s%%*", buf.bufnr, name, modified)
                    else
                        -- Use inactive color for other buffers
                        buffer_text = string.format("%%#MiniStatuslineInactiveBuffer#%s%%*", buffer_text)
                    end

                    table.insert(buf_list, buffer_text)
                end

                return table.concat(buf_list, " | ")
            end

            local statusline = function()
                local mini = require("mini.statusline")
                local mode, mode_hl = mini.section_mode({ trunc_width = 9999 })
                local git = mini.section_git({ trunc_width = 75 })
                local diagnostics = mini.section_diagnostics({ trunc_width = 75 })
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
                vim.api.nvim_set_hl(0, "MiniStatuslineActiveBuffer", { bg = "", fg = "#ffffff" })
                vim.api.nvim_set_hl(0, "MiniStatuslineInactiveBuffer", { bg = "", fg = "#6e738d" })

                return mini.combine_groups({
                    { hl = mode_hl,             strings = { mode } },
                    { hl = "MiniStatuslineGit", strings = { git, diff, diagnostics } },
                    "%<", -- truncate point
                    { hl = "MiniStatuslineRecording", strings = { show_macro_recording() } },
                    { hl = "MiniStatuslineBuffers",   strings = { get_buffer_list() } },
                    "%=", -- end left alignment
                    { hl = "MiniStatuslineLocation", strings = { search, location } },
                    { hl = mode_hl,                  strings = { fileinfo } },
                })
            end

            local inactive = function()
                local mini = require("mini.statusline")
                local fileinfo = mini.section_fileinfo({ trunc_width = 9999 })
                return mini.combine_groups({
                    { hl = "MiniStatuslineBuffers",  strings = { get_buffer_list() } },
                    "%=", -- end left alignment
                    { hl = "MiniStatuslineLocation", strings = { fileinfo } },
                })
            end

            -- -- [[ Mini Statusline ]]
            require("mini.statusline").setup({
                content = {
                    active = statusline,
                    inactive = inactive,
                },
                use_icons = true,
                set_vim_settings = true,
            })
        end,
    },
}
