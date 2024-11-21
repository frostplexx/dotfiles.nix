return {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
        require("dapui").setup()

        require("mason-nvim-dap").setup({
            ensure_installed = { "python", "codelldb" },
            handlers = {}, -- sets up dap in the predefined manner
        })

        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end,
    keys = {
        { "<leader>dc", "<cmd>lua require'dap'.continue()<CR>",          desc = "Continue" },
        { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = "Toggle Breakpoint" },
        { "<leader>dn", "<cmd>lua require'dap'.step_over()<CR>",         desc = "Step Over" },
        { "<leader>di", "<cmd>lua require'dap'.step_into()<CR>",         desc = "Step Into" },
        { "<leader>do", "<cmd>lua require'dap'.step_out()<CR>",          desc = "Step Out" },
        { "<leader>dd", "<cmd>lua require'dap'.down()<CR>",              desc = "Down" },
        { "<leader>ds", "<cmd>lua require'dap'.close()<CR>",             desc = "Stop" },
        { "<leader>dt", "<cmd>lua require'dapui'.toggle()<CR>",          desc = "Toggle Debug UI" },
        { "<leader>dv", "<cmd>lua require'dapui'.variables()<CR>",       desc = "Variables" },
        { "<leader>di", "<cmd>lua require'dapui'.inspector()<CR>",       desc = "Inspector" },
        { "<leader>dk", "<cmd>lua require'dapui'.hover()<CR>",           desc = "Hover" },
    }
}
