return {
    "ibhagwan/fzf-lua",
    lazy = true,
    opts = function(_, _)
        local config = require('fzf-lua.config')
        -- Quickfix
        config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
        config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
        config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
        config.defaults.keymap.fzf["ctrl-x"] = "jump"
        config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
        config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
        config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
        config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"
        config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
        return {
            "default-title",
            fzf_colors = true,
            fzf_opts = {
                ["--no-scrollbar"] = true,
                ["--layout"] = "reverse",
            },
            defaults = {
                -- formatter = "path.filename_first",
                formatter = "path.dirname_first",
            },
            ui_select = function(fzf_opts, items)
                return vim.tbl_deep_extend("force", fzf_opts, {
                    prompt = " ",
                    winopts = {
                        title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
                        title_pos = "center",
                    },
                }, fzf_opts.kind == "codeaction" and {
                    winopts = {
                        layout = "vertical",
                        -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
                        height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
                        width = 0.5,
                        preview = {
                            layout = "vertical",
                            vertical = "down:15,border-top",
                        },
                    },
                } or {
                    winopts = {
                        width = 0.5,
                        -- height is number of items, with a max of 80% screen height
                        height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
                    },
                })
            end,
            winopts = {
                width = 0.8,
                height = 0.8,
                row = 0.5,
                col = 0.5,
                preview = {
                    scrollchars = { "┃", "" },
                },
            },
            lsp = {
                symbols = {
                    symbol_hl = function(s)
                        return "TroubleIcon" .. s
                    end,
                    symbol_fmt = function(s)
                        return s:lower() .. "\t"
                    end,
                    child_prefix = false,
                },
                code_actions = {
                    previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
                },
            },
        }
    end,
    keys = {
        { "<leader><space>", ":lua require('fzf-lua').files()<cr>",            desc = "Find Files",        remap = true, silent = true },
        { "<leader>fg",      ":lua require('fzf-lua').live_grep_resume()<cr>", desc = "Live Grep",         silent = true },
        { "<leader>fh",      ":lua require('fzf-lua').helptags()<cr>",         desc = "Help Tags",         silent = true },
        { "<leader>ch",      ":lua require('fzf-lua').command_history()<cr>",  desc = "Command History",   silent = true },
        { "<leader>km",      ":lua require('fzf-lua').keymaps()<cr>",          desc = "Keymap",            silent = true },
        { "<leader>bf",      ":lua require('fzf-lua').buffers()<cr>",          desc = "List open Buffers", remap = true, silent = true },
    }
}
