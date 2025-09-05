local function LspInfo()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
        vim.notify("No LSP clients attached", vim.log.levels.WARN)
        return
    end

    local info = {}
    for _, client in pairs(clients) do
        local client_info = {
            "Client: " .. client.name,
            "ID: " .. client.id,
            "Root directory: " .. (client.config.root_dir or "Not set"),
            "Capabilities:",
        }

        -- Add key capabilities
        local caps = client.server_capabilities
        local capabilities = {
            "    • Completion: " .. tostring(caps.completionProvider ~= nil),
            "    • Hover: " .. tostring(caps.hoverProvider ~= nil),
            "    • Definition: " .. tostring(caps.definitionProvider ~= nil),
            "    • References: " .. tostring(caps.referencesProvider ~= nil),
            "    • Diagnostics: " .. tostring(caps.diagnosticProvider ~= nil),
        }

        for _, cap in ipairs(capabilities) do
            table.insert(client_info, cap)
        end

        table.insert(info, table.concat(client_info, "\n"))
    end

    vim.notify(table.concat(info, "\n\n"), vim.log.levels.INFO)
end

-- Register the command
vim.api.nvim_create_user_command("LspInfo", LspInfo, {})


vim.api.nvim_create_user_command('Todos', function()
    MiniPick.builtin.grep({ pattern = '(TODO|FIXME|HACK|NOTE):' })
end, { desc = 'Grep TODOs', nargs = 0 })

-- Clean all plugins command
local function CleanPlugins()
    local pack_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt"
    
    if vim.fn.isdirectory(pack_dir) == 1 then
        vim.ui.input({
            prompt = "This will delete all plugins. Are you sure? (yes/no): ",
        }, function(input)
            if input == "yes" then
                print("Cleaning plugins directory: " .. pack_dir)
                vim.system({ "rm", "-rf", pack_dir }, {}, function(result)
                    if result.code == 0 then
                        print("All plugins cleaned successfully!")
                        print("Restart Neovim to reinstall plugins.")
                    else
                        print("Failed to clean plugins: " .. (result.stderr or "unknown error"))
                    end
                end)
            else
                print("Plugin cleanup cancelled.")
            end
        end)
    else
        print("Plugin directory not found: " .. pack_dir)
    end
end

vim.api.nvim_create_user_command("CleanPlugins", CleanPlugins, { desc = "Clean all Neovim plugins" })

-- Pack command that uses the dedicated pack_manager module
local function PackInfo()
    require('core.pack_manager').show()
end

vim.api.nvim_create_user_command("Pack", PackInfo, { desc = "Show loaded Neovim plugins in a floating window" })