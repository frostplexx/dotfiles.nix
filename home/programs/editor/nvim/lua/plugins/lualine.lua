return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VeryLazy",
    opts = {
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
        },
        sections = {
            lualine_a = {
                {
                    'mode',
                    fmt = function(str)
                        return str:sub(1, 1)
                    end
                }
            },
            lualine_b = { 'branch', 'diff',
                {
                    'macro-recording',
                    fmt = function()
                        local recording_register = vim.fn.reg_recording()
                        if recording_register == '' then
                            return ''
                        else
                            return '󰑋 ' .. recording_register
                        end
                    end,
                },
            },
            lualine_c = { {
                'buffers',
                show_filename_only = false, -- Shows shortened relative path when set to false.
                symbols = {
                    modified = ' ', -- Text to show when the buffer is modified
                    alternate_file = '', -- Text to show to identify the alternate file
                    directory = '', -- Text to show when the buffer is a directory
                },
            } },
            lualine_x = { 'diagnostics' },
            lualine_y = { 'filetype' },
            lualine_z = { 'searchcount', 'location' }
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = { 'progress' }
        },
        extensions = {
            "lazy",
            "mason",
            "nvim-dap-ui",
            "quickfix",
            "trouble"
        }
    }
}
