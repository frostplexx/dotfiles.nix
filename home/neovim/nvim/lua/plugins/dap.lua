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
                -- stopOnEntry = false,
                followForks = true,               -- Keep this
                followExecs = true,               -- Keep this
                detachOnFork = false,             -- Keep this
                -- Add these new settings
                sourceLanguages = { 'cpp', 'c' }, -- Help debugger identify source types
                pid = function()                  -- Allow attaching to existing process
                    local handle = io.popen('pgrep -n ' .. vim.fn.expand('%:t:r'))
                    if handle then
                        local pid = handle:read("*a")
                        handle:close()
                        return pid
                    end
                    return nil
                end,
                processCreateCommands = { -- Commands run when new process is created
                    'set follow-fork-mode child',
                    'set detach-on-fork off',
                },
                -- Ensure LLDB is configured to catch all signals
                stopOnEntry = true, -- Stop at program entry to set up debugging
                setupCommands = {
                    {
                        description = 'Enable all signal catching',
                        text = 'process handle -p true -s true -n true',
                        ignoreFailures = true,
                    },
                },
                env = function() -- Ensure proper environment variables
                    local variables = {}
                    for k, v in pairs(vim.fn.environ()) do
                        table.insert(variables, string.format("%s=%s", k, v))
                    end
                    return variables
                end,
            },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

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
        { "<leader>dt", "<cmd>:lua require('dapui').toggle()<CR>",                    desc = "Debug Toggle Debug UI" },
        { "<leader>da", "<cmd>DapNew<CR>",                                            desc = "Debug New" },
        { "<leader>?",  "<cmd>:lua require('dapui').eval(nil, { enter = true })<CR>", desc = "Debug Eval" },
    }
}
