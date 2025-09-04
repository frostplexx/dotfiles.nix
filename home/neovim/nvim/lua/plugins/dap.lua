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

        -- Setup CodeLLDB adapter using nix-shell
        dap.adapters.codelldb = {
            type = 'server',
            port = "${port}",
            executable = {
                command = 'nix-shell',
                args = {
                    '-p', 'vscode-extensions.vadimcn.vscode-lldb',
                    '--run', 'codelldb --port ${port}'
                },
            }
        }

        -- Alternative: Use lldb-vscode from llvmPackages
        dap.adapters.lldb = {
            type = 'executable',
            command = 'nix-shell',
            args = {
                '-p', 'llvmPackages.lldb',
                '--run', 'lldb-vscode'
            },
            name = 'lldb'
        }

        -- Configuration for C, C++, Rust
        dap.configurations.cpp = {
            {
                name = 'Launch C/C++ (CodeLLDB)',
                type = 'codelldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                followForks = true,
                followExecs = true,
                detachOnFork = false,
                sourceLanguages = { 'cpp', 'c' },
                pid = function()
                    local handle = io.popen('pgrep -n ' .. vim.fn.expand('%:t:r'))
                    if handle then
                        local pid = handle:read("*a")
                        handle:close()
                        return pid
                    end
                    return nil
                end,
                processCreateCommands = {
                    'set follow-fork-mode child',
                    'set detach-on-fork off',
                },
                stopOnEntry = true,
                setupCommands = {
                    {
                        description = 'Enable all signal catching',
                        text = 'process handle -p true -s true -n true',
                        ignoreFailures = true,
                    },
                },
                env = function()
                    local variables = {}
                    for k, v in pairs(vim.fn.environ()) do
                        table.insert(variables, string.format("%s=%s", k, v))
                    end
                    return variables
                end,
            },
            {
                name = 'Launch C/C++ (LLDB)',
                type = 'lldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                args = {},
            },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

        -- Python adapter using nix-shell
        dap.adapters.python = {
            type = 'executable',
            command = 'nix-shell',
            args = {
                '-p', 'python3Packages.debugpy',
                '--run', 'python -m debugpy.adapter'
            },
        }

        dap.configurations.python = {
            {
                type = 'python',
                request = 'launch',
                name = 'Launch file',
                program = '${file}',
                pythonPath = function()
                    -- Use python from nix-shell if needed
                    local cwd = vim.fn.getcwd()
                    if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                        return cwd .. '/venv/bin/python'
                    elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                        return cwd .. '/.venv/bin/python'
                    else
                        -- Use nix-shell python3
                        return vim.fn.system('nix-shell -p python3 --run "which python3"'):gsub('\n', '')
                    end
                end,
            },
        }

        -- Go adapter using nix-shell with delve
        dap.adapters.go = {
            type = 'executable',
            command = 'nix-shell',
            args = {
                '-p', 'delve',
                '--run', 'dlv dap'
            },
        }

        dap.configurations.go = {
            {
                type = "go",
                name = "Debug",
                request = "launch",
                program = "${file}",
            },
            {
                type = "go",
                name = "Debug test",
                request = "launch",
                mode = "test",
                program = "${file}",
            },
            {
                type = "go",
                name = "Debug test (go.mod)",
                request = "launch",
                mode = "test",
                program = "./${relativeFileDirname}",
            },
        }


        local function pick_process()
            local handle = io.popen('ps -eo pid,comm --no-headers')
            if not handle then
                return nil
            end

            local processes = {}
            for line in handle:lines() do
                local pid, name = line:match('(%d+)%s+(.+)')
                if pid and name then
                    table.insert(processes, { pid = pid, name = name })
                end
            end
            handle:close()

            if #processes == 0 then
                return nil
            end

            local choices = {}
            for i, proc in ipairs(processes) do
                table.insert(choices, string.format("%d: %s (PID: %s)", i, proc.name, proc.pid))
            end

            local choice = vim.fn.inputlist(choices)
            if choice > 0 and choice <= #processes then
                return tonumber(processes[choice].pid)
            end

            return nil
        end

        -- Alternative setup using nix-shell for node
        dap.adapters["pwa-node"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
                command = "js-debug",
                args = {
                    "${port}"
                }
            }
        }

        dap.configurations["typescript"] = {
            {
                type = "pwa-node",
                request = "launch",
                name = "Launch file",
                program = "${file}",
                cwd = "${workspaceFolder}",
            },
            {
                type = "pwa-node",
                request = "attach",
                name = "Attach to process ID",
                processId = pick_process,
                cwd = "${workspaceFolder}",
            },
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
