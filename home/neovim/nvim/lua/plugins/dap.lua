return {
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
    {
        src = "https://github.com/mfussenegger/nvim-dap",
        name = "nvim-dap",
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
                    args = {'-p', 'lldb', '--command', 'lldb-vscode'},
                }
            }

        end
    },
}