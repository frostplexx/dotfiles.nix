return {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
        local dap, dapui = require("dap"), require("dapui")

        -- Basic UI setup
        dapui.setup()
        require("nvim-dap-virtual-text").setup({
            virt_text_pos = "eol",
        })

        -- Define paths for debug adapters
        local codelldb_path = vim.fn.expand("~/dotfiles.nix/home/programs/editor/debug/darwin/codelldb")

        -- Setup codelldb adapter with proper executable path
        dap.adapters.codelldb = {
            type = 'server',
            port = '13000',
            executable = {
                command = codelldb_path,
                args = { "--port", "13000" }
            }
        }

        -- Configuration for C, C++
        dap.configurations.cpp = {
            {
                name = 'Launch C/C++',
                type = 'codelldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                followForks = true,
                followExecs = true,
                detachOnFork = false,
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

        -- UI Listeners
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
        { "<leader>dc", "<cmd>DapContinue<CR>",                                       desc = "Debug Continue" },
        { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>",              desc = "Debug Toggle Breakpoint" },
        { "<leader>dn", "<cmd>DapStepOver<CR>",                                       desc = "Debug Step Over" },
        { "<leader>di", "<cmd>DapStepInto<CR>",                                       desc = "Debug Step Into" },
        { "<leader>do", "<cmd>DapStepOut<CR>",                                        desc = "Debug Step Out" },
        { "<leader>dd", "<cmd>lua require'dap'.down()<CR>",                           desc = "Debug Down" },
        { "<leader>ds", "<cmd>DapTerminate<CR>",                                      desc = "Debug Stop" },
        { "<leader>dt", "<cmd>lua require'dapui'.toggle()<CR>",                       desc = "Debug Toggle Debug UI" },
        { "<leader>da", "<cmd>DapNew<CR>",                                            desc = "Debug New" },
        { "<leader>?",  "<cmd>:lua require('dapui').eval(nil, { enter = true })<CR>", desc = "Debug Eval" },
    }
}
