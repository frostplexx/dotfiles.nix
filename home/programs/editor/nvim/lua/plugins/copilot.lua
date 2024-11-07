return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    enabled = true,
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>",
          },
          layout = {
            position = "bottom",             -- | top | left | right
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<C-Enter>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-d>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = "node",         -- Node.js version must be > 18.x
        server_opts_overrides = {},
      })
    end,
  },
  -- {
  --     "CopilotC-Nvim/CopilotChat.nvim",
  --     branch = "canary",
  --     cmd = "CopilotChat",
  --     opts = function()
  --         local user = vim.env.USER or "User"
  --         user = user:sub(1, 1):upper() .. user:sub(2)
  --         return {
  --             model = "gpt-4",
  --             auto_insert_mode = true,
  --             show_help = true,
  --             question_header = "  " .. user .. " ",
  --             answer_header = "  Copilot ",
  --             window = {
  --                 width = 0.4,
  --             },
  --             selection = function(source)
  --                 local select = require("CopilotChat.select")
  --                 return select.visual(source) or select.buffer(source)
  --             end,
  --             mappings = {
  --                 reset = {
  --                     normal = "",
  --                     insert = "C-l",
  --                 },
  --             },
  --         }
  --     end,
  --     keys = {
  --         {
  --             "<leader>aa",
  --             function()
  --                 return require("CopilotChat").toggle()
  --             end,
  --             desc = "Toggle (CopilotChat)",
  --             mode = { "n", "v" },
  --         },
  --         {
  --             "<leader>ax",
  --             function()
  --                 return require("CopilotChat").reset()
  --             end,
  --             desc = "Clear (CopilotChat)",
  --             mode = { "n", "v" },
  --         },
  --     },
  --     config = function(_, opts)
  --         local chat = require("CopilotChat")
  --         require("CopilotChat.integrations.cmp").setup()
  --
  --         vim.api.nvim_create_autocmd("BufEnter", {
  --             pattern = "copilot-chat",
  --             callback = function()
  --                 vim.opt_local.relativenumber = false
  --                 vim.opt_local.number = false
  --             end,
  --         })
  --
  --         chat.setup(opts)
  --     end,
  -- },
}
