return {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text"
    },
    config = function()
        local dap, dapui = require("dap"), require("dapui")

        -- Basic UI setup
        dapui.setup()
        require("nvim-dap-virtual-text").setup({
            virt_text_pos = "eol",
        })

        -- Define paths for Nix-installed debug adapters
        local codelldb_path = "nix shell nixpkgs#lldb --command which codelldb"
        local node_debug_path = "nix shell nixpkgs#nodePackages.node-debug2-adapter --command which node-debug2-adapter"
        local bash_debug_path = "nix shell nixpkgs#bash-debug-adapter --command which bash-debug-adapter"

        -- Setup debug adapters using Nix
        dap.adapters.codelldb = {
            type = 'server',
            port = "${port}",
            executable = {
                command = codelldb_path,
                args = { "--port", "${port}" },
            }
        }

        dap.adapters.node2 = {
            type = 'executable',
            command = node_debug_path,
            args = {}
        }

        dap.adapters.bash = {
            type = 'executable',
            command = bash_debug_path,
            args = {}
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

        -- Configuration for TypeScript/JavaScript
        dap.configurations.typescript = {
            {
                name = 'Launch TypeScript',
                type = 'node2',
                request = 'launch',
                program = '${file}',
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                protocol = 'inspector',
                console = 'integratedTerminal',
                outFiles = { "${workspaceFolder}/dist/**/*.js" },
            },
            {
                name = 'Attach to Process',
                type = 'node2',
                request = 'attach',
                processId = require('dap.utils').pick_process,
            }
        }
        dap.configurations.javascript = dap.configurations.typescript

        -- Configuration for Bash
        dap.configurations.sh = {
            {
                name = 'Launch Bash Script',
                type = 'bash',
                request = 'launch',
                program = '${file}',
                cwd = '${workspaceFolder}',
                pathBash = 'bash',
                pathCat = 'cat',
                pathMkfifo = 'mkfifo',
                pathPkill = 'pkill',
                env = {},
                args = {},
            }
        }

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

        -- Utility function to ensure debug adapters are installed
        local function ensure_debug_adapters()
            local handle = io.popen(
                "nix shell nixpkgs#lldb nixpkgs#nodePackages.node-debug2-adapter nixpkgs#bash-debug-adapter --command echo OK")
            if handle then
                handle:close()
            end
        end

        -- Ensure debug adapters are installed when loading configuration
        ensure_debug_adapters()
    end,
    keys = {
        { "<leader>dc", "<cmd>DapContinue<CR>",                                       desc = "Debug Continue" },
        { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>",              desc = "Debug Toggle Breakpoint" },
        { "<leader>dn", "<cmd>DapStepOver<CR>",                                       desc = "Debug Step Over" },
        { "<leader>di", "<cmd>DapStepInto<CR>",                                       desc = "Debug Step Into" },
        { "<leader>do", "<cmd>DapStepOut<CR>",                                        desc = "Debug Step Out" },
        { "<leader>dd", "<cmd>lua require'dap'.down()<CR>",                           desc = "Debug Down" },
        { "<leader>ds", "<cmd>DapTerminate<CR>",                                      desc = "Debug Stop" },
        { "<leader>dt", "<cmd>lua require'dap'.toggle()<CR>",                         desc = "Debug Toggle Debug UI" },
        { "<leader>da", "<cmd>DapNew<CR>",                                            desc = "Debug New" },
        { "<leader>?",  "<cmd>:lua require('dapui').eval(nil, { enter = true })<CR>", desc = "Debug Eval" },
    }
}
