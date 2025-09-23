return {
    src = "https://github.com/mfussenegger/nvim-dap",
    defer = true,
    dependencies = {
        {
            src = "https://github.com/rcarriga/nvim-dap-ui",
            name = "nvim-dap-ui",
        },
        {
            src = "https://github.com/nvim-neotest/nvim-nio",
            name = "nvim-nio",
        },
        {
            src = "https://github.com/theHamsta/nvim-dap-virtual-text",
            name = "nvim-dap-virtual-text",
        },
    },
    config = function()
        -- TODO: Fix this
        -- local dap, dapui = require("dap"), require("dapui")

        -- Basic UI setup
        -- dapui.setup()
        -- require("nvim-dap-virtual-text").setup({
        --     virt_text_pos = "eol",
        -- })

        -- Setup CodeLLDB adapter using nix-shell
        -- dap.adapters.codelldb = {
        --     type = 'server',
        --     port = "${port}",
        --     executable = {
        --         command = 'nix-shell',
        --         args = { '-p', 'lldb', '--run', 'lldb-vscode' },
        --     }
        -- }

        -- { "<leader>dc", "<cmd>DapContinue<CR>",                                       desc = "Debug Continue" },
        -- { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>",              desc = "Debug Toggle Breakpoint" },
        -- { "<leader>dn", "<cmd>DapStepOver<CR>",                                       desc = "Debug Step Over" },
        -- { "<leader>di", "<cmd>DapStepInto<CR>",                                       desc = "Debug Step Into" },
        -- { "<leader>do", "<cmd>DapStepOut<CR>",                                        desc = "Debug Step Out" },
        -- { "<leader>dd", "<cmd>lua require'dap'.down()<CR>",                           desc = "Debug Down" },
        -- { "<leader>ds", "<cmd>DapTerminate<CR>",                                      desc = "Debug Stop" },
        -- { "<leader>dt", "<cmd>:lua require('dapui').toggle()<CR>",                    desc = "Debug Toggle Debug UI" },
        -- { "<leader>da", "<cmd>DapNew<CR>",                                            desc = "Debug New" },
        -- { "<leader>?",  "<cmd>:lua require('dapui').eval(nil, { enter = true })<CR>", desc = "Debug Eval" },
    end
}
