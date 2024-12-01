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

        -- Helper function to get program arguments
        local function get_args()
            local args_string = vim.fn.input('Program arguments: ')
            local args = {}
            for arg in args_string:gmatch("%S+") do
                table.insert(args, arg)
            end
            return args
        end

        -- Configuration for C, C++, and Rust
        local codelldb_config = {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            args = get_args,
            -- 💀
            -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
            --
            --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
            --
            -- Otherwise you might get the following error:
            --
            --    Error on launch: Failed to attach to the target process
            --
            -- But you should be aware of the implications:
            -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
            -- runInTerminal = false,
        }

        -- Apply the configuration to C, C++, and Rust
        dap.configurations.c = { codelldb_config }
        dap.configurations.cpp = { codelldb_config }
        dap.configurations.rust = { codelldb_config }

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
        { "<leader>dt", "<cmd>lua require'dap'.toggle()<CR>",            desc = "Toggle Debug UI" },
        { "<leader>dv", "<cmd>lua require'dapui'.variables()<CR>",       desc = "Variables" },
        { "<leader>di", "<cmd>lua require'dapui'.inspector()<CR>",       desc = "Inspector" },
        { "<leader>dk", "<cmd>lua require'dapui'.hover()<CR>",           desc = "Hover" },
    }
}
