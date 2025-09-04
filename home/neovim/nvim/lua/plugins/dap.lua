return {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
        "mxsdev/nvim-dap-vscode-js",
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

        -- Helper function to detect package manager
        local function get_package_manager()
            if vim.fn.filereadable("yarn.lock") == 1 then
                return "yarn"
            elseif vim.fn.filereadable("package-lock.json") == 1 then
                return "npm"
            else
                return "npm" -- default fallback
            end
        end

        -- Setup TypeScript debugging
        require("dap-vscode-js").setup({
            debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
            adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
        })

        -- TypeScript/JavaScript configurations
        for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
            dap.configurations[language] = {
                -- Debug single nodejs files
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                },
                -- Debug nodejs processes (make sure to add --inspect when you run the process)
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach",
                    processId = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                },
                -- Debug web app (client side)
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch Chrome",
                    url = function()
                        local url = vim.fn.input("URL: ", "http://localhost:3000")
                        return url
                    end,
                    webRoot = "${workspaceFolder}",
                    protocol = "inspector",
                    sourceMaps = true,
                    userDataDir = false,
                },
                -- Launch npm/yarn dev server and attach
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch via npm/yarn",
                    runtimeExecutable = function()
                        return get_package_manager()
                    end,
                    runtimeArgs = function()
                        local pm = get_package_manager()
                        if pm == "yarn" then
                            return { "dev" }
                        else
                            return { "run", "dev" }
                        end
                    end,
                    rootPath = "${workspaceFolder}",
                    cwd = "${workspaceFolder}",
                    console = "integratedTerminal",
                    internalConsoleOptions = "neverOpen",
                },
                -- Launch npm/yarn start script
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch via start script",
                    runtimeExecutable = function()
                        return get_package_manager()
                    end,
                    runtimeArgs = function()
                        local pm = get_package_manager()
                        if pm == "yarn" then
                            return { "start" }
                        else
                            return { "run", "start" }
                        end
                    end,
                    rootPath = "${workspaceFolder}",
                    cwd = "${workspaceFolder}",
                    console = "integratedTerminal",
                    internalConsoleOptions = "neverOpen",
                },
                -- Debug Jest tests
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Debug Jest Tests",
                    runtimeExecutable = "node",
                    runtimeArgs = function()
                        local pm = get_package_manager()
                        if pm == "yarn" then
                            return {
                                "./node_modules/.bin/jest",
                                "--runInBand",
                                "--no-cache",
                                "--no-coverage",
                                "--watchAll=false",
                            }
                        else
                            return {
                                "./node_modules/.bin/jest",
                                "--runInBand",
                                "--no-cache",
                                "--no-coverage",
                                "--watchAll=false",
                            }
                        end
                    end,
                    rootPath = "${workspaceFolder}",
                    cwd = "${workspaceFolder}",
                    console = "integratedTerminal",
                    internalConsoleOptions = "neverOpen",
                },
            }
        end

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
