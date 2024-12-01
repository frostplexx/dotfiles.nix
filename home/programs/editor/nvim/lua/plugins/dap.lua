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
            ensure_installed = { "python" },
            handlers = {}, -- sets up dap in the predefined manner
        })



        dap.adapters.lldb = {
            type = 'executable',
            command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
            name = 'lldb'
        }

        -- Configuration for C, C++, and Rust
        dap.configurations.cpp = {
            {
                name = 'Launch',
                type = 'lldb',
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
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end,
    keys = {
        { "<leader>dc", "<cmd>lua require'dap'.continue()<CR>",          desc = "Debug Continue" },
        { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = "Debug Toggle Breakpoint" },
        { "<leader>dn", "<cmd>lua require'dap'.step_over()<CR>",         desc = "Debug Step Over" },
        { "<leader>di", "<cmd>lua require'dap'.step_into()<CR>",         desc = "Debug Step Into" },
        { "<leader>do", "<cmd>lua require'dap'.step_out()<CR>",          desc = "Debug Step Out" },
        { "<leader>dd", "<cmd>lua require'dap'.down()<CR>",              desc = "Debug Down" },
        { "<leader>ds", "<cmd>lua require'dap'.close()<CR>",             desc = "Debug Stop" },
        { "<leader>dt", "<cmd>lua require'dapui'.toggle()<CR>",          desc = "Debug Toggle Debug UI" },
        { "<leader>dv", "<cmd>lua require'dapui'.variables()<CR>",       desc = "Debug Variables" },
        { "<leader>di", "<cmd>lua require'dapui'.inspector()<CR>",       desc = "Debug Inspector" },
        { "<leader>dk", "<cmd>lua require'dapui'.hover()<CR>",           desc = "Debug Hover" },
    }
}
