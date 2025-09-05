local function load_plugins()
    local plugins = {}
    local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
    
    local files = vim.fn.glob(plugin_dir .. "/*.lua", false, true)
    
    for _, file in ipairs(files) do
        local plugin_name = vim.fn.fnamemodify(file, ":t:r")
        local plugin_module = "plugins." .. plugin_name
        
        local ok, plugin_config = pcall(require, plugin_module)
        if ok then
            --print("Plugin config for " .. plugin_name .. ":", vim.inspect(plugin_config))
            if type(plugin_config) == "table" then
                for _, plugin in ipairs(plugin_config) do
                    -- Process version field if it's a string
                    if plugin.version and type(plugin.version) == "string" then
                        plugin.version = vim.version.range(plugin.version)
                    end
                    -- Set default priority if not specified
                    if not plugin.priority then
                        plugin.priority = 1
                    end
                    table.insert(plugins, plugin)
                end
            end
        end
    end
    
    -- Sort plugins by priority (highest to lowest)
    table.sort(plugins, function(a, b)
        return (a.priority or 1) > (b.priority or 1)
    end)
    
    -- Separate plugins by loading strategy
    local startup_plugins = {}
    local lazy_plugins = {}
    
    for _, plugin in ipairs(plugins) do
        if plugin.lazy == false or plugin.priority and plugin.priority > 50 then
            table.insert(startup_plugins, plugin)
        else
            table.insert(lazy_plugins, plugin)
        end
    end
    
    -- Load startup plugins immediately
    if #startup_plugins > 0 then
        vim.pack.add(startup_plugins)
    end
    
    -- Load lazy plugins after startup
    if #lazy_plugins > 0 then
        vim.schedule(function()
            vim.pack.add(lazy_plugins)
            -- Process lazy plugins after they're loaded
            for _, plugin in ipairs(lazy_plugins) do
                -- Execute build, config, and keymaps for lazy plugins
                if plugin.build and type(plugin.build) == "string" then
                    local plugin_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/" .. plugin.name
                    local build_marker = plugin_path .. "/.build_complete"
                    
                    if vim.fn.isdirectory(plugin_path) == 1 and vim.fn.filereadable(build_marker) == 0 then
                        if plugin.build:match("^:") then
                            vim.schedule(function()
                                local ok, result = pcall(vim.cmd, plugin.build:sub(2))
                                if ok then
                                    vim.schedule(function()
                                        vim.fn.writefile({""}, build_marker)
                                    end)
                                end
                            end)
                        else
                            vim.system({ "sh", "-c", plugin.build }, { cwd = plugin_path }, function(result)
                                if result.code == 0 then
                                    vim.schedule(function()
                                        vim.fn.writefile({""}, build_marker)
                                    end)
                                end
                            end)
                        end
                    end
                end
                
                if plugin.config and type(plugin.config) == "function" then
                    plugin.config()
                end
                
                if plugin.keys and type(plugin.keys) == "table" then
                    vim.schedule(function()
                        for _, keymap in ipairs(plugin.keys) do
                            local key = keymap[1]
                            local func = keymap[2]
                            local desc = keymap.desc
                            local remap = keymap.remap
                            local silent = keymap.silent
                            
                            if key and func then
                                local opts = {}
                                if desc then opts.desc = desc end
                                if remap ~= nil then opts.remap = remap end
                                if silent ~= nil then opts.silent = silent end
                                
                                vim.keymap.set("n", key, func, opts)
                            end
                        end
                    end)
                end
            end
        end)
    end
    
    -- Execute config functions for startup plugins only
    for _, plugin in ipairs(startup_plugins) do
        -- Execute build commands only if plugin needs building
        if plugin.build and type(plugin.build) == "string" then
            local plugin_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/" .. plugin.name
            local build_marker = plugin_path .. "/.build_complete"
            
            if vim.fn.isdirectory(plugin_path) == 1 and vim.fn.filereadable(build_marker) == 0 then
                if plugin.build:match("^:") then
                    vim.schedule(function()
                        local ok, result = pcall(vim.cmd, plugin.build:sub(2))
                        if ok then
                            vim.fn.writefile({""}, build_marker)
                        end
                    end)
                else
                    vim.system({ "sh", "-c", plugin.build }, { cwd = plugin_path }, function(result)
                        if result.code == 0 then
                            vim.schedule(function()
                                vim.fn.writefile({""}, build_marker)
                            end)
                        end
                    end)
                end
            end
        end

        if plugin.config and type(plugin.config) == "function" then
            plugin.config()
        end
        
        if plugin.keys and type(plugin.keys) == "table" then
            vim.schedule(function()
                for _, keymap in ipairs(plugin.keys) do
                    local key = keymap[1]
                    local func = keymap[2]
                    local desc = keymap.desc
                    local remap = keymap.remap
                    local silent = keymap.silent
                    
                    if key and func then
                        local opts = {}
                        if desc then opts.desc = desc end
                        if remap ~= nil then opts.remap = remap end
                        if silent ~= nil then opts.silent = silent end
                        
                        vim.keymap.set("n", key, func, opts)
                    end
                end
            end)
        end
    end
    
    return plugins
end

return { load_plugins = load_plugins }