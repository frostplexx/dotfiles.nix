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

        local dap, dapui = require("dap"), require("dapui")
        require("mason-nvim-dap").setup({
            ensure_installed = { "python", "codelldb" },
            handlers = {}, -- sets up dap in the predefined manner
        })



        -- Configuration for C, C++, and Rust
        dap.configurations.cpp = {
            {
                name = 'Launch',
                type = 'codelldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                args = function()
                    local args_string = vim.fn.input('Program arguments: ')
                    local args = {}
                    for arg in args_string:gmatch("%S+") do
                        table.insert(args, arg)
                    end
                    return args
                end

            },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        -- dap.listeners.before.event_terminated.dapui_config = function()
        --     dapui.close()
        -- end
        -- dap.listeners.before.event_exited.dapui_config = function()
        --     dapui.close()
        -- end
    end,
    keys = {
        { "<leader>dc", "<cmd>DapStepContinue<CR>",                      desc = "Debug Continue" },
        { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = "Debug Toggle Breakpoint" },
        { "<leader>dn", "<cmd>DapStepOver<CR>",                          desc = "Debug Step Over" },
        { "<leader>di", "<cmd>DapStepInto<CR>",                          desc = "Debug Step Into" },
        { "<leader>do", "<cmd>DapStepOut<CR>",                           desc = "Debug Step Out" },
        { "<leader>dd", "<cmd>lua require'dap'.down()<CR>",              desc = "Debug Down" },
        { "<leader>ds", "<cmd>lua require'dap'.close()<CR>",             desc = "Debug Stop" },
        { "<leader>dt", "<cmd>lua require'dapui'.toggle()<CR>",          desc = "Debug Toggle Debug UI" },
    }
}
