local M = {}

function M.show()
    local loaded_packages = vim.api.nvim_list_runtime_paths()
    local plugins = {}
    local pack_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt"
    local deleted_plugins = {}
    local configured_plugins = {}
    
    -- Check what plugins exist on disk (including unloaded ones)
    local disk_plugins = {}
    if vim.fn.isdirectory(pack_dir) == 1 then
        local plugin_dirs = vim.fn.glob(pack_dir .. "/*", false, true)
        for _, plugin_path in ipairs(plugin_dirs) do
            if vim.fn.isdirectory(plugin_path) == 1 then
                local plugin_name = vim.fn.fnamemodify(plugin_path, ":t")
                if plugin_name ~= "after" and not plugin_name:match("^%.") then
                    disk_plugins[plugin_name] = {
                        name = plugin_name,
                        path = plugin_path,
                        is_loaded = false,  -- Will be updated if found in loaded_packages
                        is_configured = false  -- Will be updated if found in config
                    }
                end
            end
        end
    end
    
    -- Scan plugin configuration files to find defined plugins
    local plugin_config_dir = vim.fn.stdpath("config") .. "/lua/plugins"
    if vim.fn.isdirectory(plugin_config_dir) == 1 then
        local config_files = vim.fn.glob(plugin_config_dir .. "/*.lua", false, true)
        for _, config_file in ipairs(config_files) do
            local content = vim.fn.readfile(config_file)
            local file_content = table.concat(content, "\n")
            
            -- Look for name = "plugin-name" patterns
            for plugin_name in file_content:gmatch('name%s*=%s*["\']([^"\']+)["\']') do
                configured_plugins[plugin_name] = true
                if disk_plugins[plugin_name] then
                    disk_plugins[plugin_name].is_configured = true
                end
            end
            
            -- Also extract from src URLs as fallback
            for plugin_spec in file_content:gmatch('src%s*=%s*["\']([^"\']+/[^"\']+)["\']') do
                local plugin_name = plugin_spec:match("([^/]+)$")
                if plugin_name then
                    plugin_name = plugin_name:gsub("%.git$", "")
                    configured_plugins[plugin_name] = true
                    if disk_plugins[plugin_name] then
                        disk_plugins[plugin_name].is_configured = true
                    end
                end
            end
        end
    end
    
    -- Mark loaded plugins in disk_plugins
    for _, path in ipairs(loaded_packages) do
        local plugin_name = vim.fn.fnamemodify(path, ":t")
        if path:match(pack_dir:gsub("%-", "%%-")) and 
           plugin_name ~= "after" and 
           not plugin_name:match("^%.") then
            if disk_plugins[plugin_name] then
                disk_plugins[plugin_name].is_loaded = true
                disk_plugins[plugin_name].path = path
            end
        end
    end
    
    -- Convert disk_plugins to plugins array
    for _, plugin_info in pairs(disk_plugins) do
        -- Add description if available and loaded
        if plugin_info.is_loaded then
            local readme_files = { "README.md", "readme.md", "README.txt", "readme.txt" }
            for _, readme in ipairs(readme_files) do
                local readme_path = plugin_info.path .. "/" .. readme
                if vim.fn.filereadable(readme_path) == 1 then
                    local lines = vim.fn.readfile(readme_path, "", 5)
                    for _, line in ipairs(lines) do
                        if line:match("^#") or line:match("^%*%*") then
                            plugin_info.description = line:gsub("^#+%s*", ""):gsub("^%*%*(.-)%*%*", "%1")
                            break
                        end
                    end
                    break
                end
            end
        end
        table.insert(plugins, plugin_info)
    end
    
    if #plugins == 0 then
        vim.notify("No plugins found", vim.log.levels.WARN)
        return
    end
    
    table.sort(plugins, function(a, b) return a.name:lower() < b.name:lower() end)
    
    local width = math.min(80, math.floor(vim.o.columns * 0.9))
    local header = "📦 Loaded Plugins"
    local help = "[u]pdate [d]elete [r]eload [q]uit"
    local total = string.format("Total: %d plugins loaded", #plugins)
    
    local lines = {
        string.format("%s%s", string.rep(" ", math.floor((width - #header) / 2)), header),
        string.format("%s%s", string.rep(" ", math.floor((width - #help) / 2)), help),
        ""
    }
    
    local plugin_line_map = {}
    
    for i, plugin in ipairs(plugins) do
        local symbol = "●"  -- Default green dot
        if deleted_plugins[plugin.name] then
            symbol = "●"  -- Red dot for deleted
        elseif not plugin.is_configured then
            symbol = "●"  -- Yellow dot for orphaned (on disk but not configured)
        elseif not plugin.is_loaded then
            symbol = "●"  -- Gray dot for configured but not loaded
        end
        
        local name_line = string.format("  %s %s", symbol, plugin.name)
        table.insert(lines, name_line)
        plugin_line_map[#lines] = i  -- Map line number to plugin index
    end
    
    table.insert(lines, string.format("%s%s", string.rep(" ", math.floor((width - #total) / 2)), total))
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'packinfo')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'readonly', true)
    
    local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.85))
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded"
    }
    
    local win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Set up highlighting
    local ns = vim.api.nvim_create_namespace('pack_info')
    
    -- Header highlighting
    vim.api.nvim_buf_add_highlight(buf, ns, 'Title', 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, ns, 'Comment', 1, 0, -1)
    
    -- Plugin highlighting
    for i = 1, #plugins do
        local line_idx = i + 2  -- Offset by header lines (now only 2)
        local plugin = plugins[i]
        local hl_color = 'String'  -- Default green
        if deleted_plugins[plugin.name] then
            hl_color = 'ErrorMsg'  -- Red for deleted
        elseif not plugin.is_configured then
            hl_color = 'WarningMsg'  -- Yellow for orphaned (on disk but not configured)
        elseif not plugin.is_loaded then
            hl_color = 'Comment'  -- Gray for configured but not loaded
        end
        vim.api.nvim_buf_add_highlight(buf, ns, hl_color, line_idx, 2, 3)  -- Symbol (●)
        vim.api.nvim_buf_add_highlight(buf, ns, 'Normal', line_idx, 4, -1)  -- Plugin name
    end
    
    -- Total count highlighting
    vim.api.nvim_buf_add_highlight(buf, ns, 'MoreMsg', #lines - 1, 0, -1)
    
    local function refresh_display()
        -- Temporarily make buffer modifiable and remove readonly
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_option(buf, 'readonly', false)
        
        -- Clear and regenerate lines
        local new_lines = {
            string.format("%s%s", string.rep(" ", math.floor((width - #header) / 2)), header),
            string.format("%s%s", string.rep(" ", math.floor((width - #help) / 2)), help),
            ""
        }
        
        plugin_line_map = {}
        
        for i, plugin in ipairs(plugins) do
            local symbol = "●"  -- Default green dot
            if deleted_plugins[plugin.name] then
                symbol = "●"  -- Red dot for deleted
            elseif not plugin.is_configured then
                symbol = "●"  -- Yellow dot for orphaned (on disk but not configured)
            elseif not plugin.is_loaded then
                symbol = "●"  -- Gray dot for configured but not loaded
            end
            
            local name_line = string.format("  %s %s", symbol, plugin.name)
            table.insert(new_lines, name_line)
            plugin_line_map[#new_lines] = i
        end
        
        table.insert(new_lines, string.format("%s%s", string.rep(" ", math.floor((width - #total) / 2)), total))
        
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
        
        -- Reapply highlighting
        local ns = vim.api.nvim_create_namespace('pack_info')
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        
        vim.api.nvim_buf_add_highlight(buf, ns, 'Title', 0, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns, 'Comment', 1, 0, -1)
        
        for i = 1, #plugins do
            local line_idx = i + 2
            local plugin = plugins[i]
            local hl_color = 'String'  -- Default green
            if deleted_plugins[plugin.name] then
                hl_color = 'ErrorMsg'  -- Red for deleted
            elseif not plugin.is_configured then
                hl_color = 'WarningMsg'  -- Yellow for orphaned (on disk but not configured)
            elseif not plugin.is_loaded then
                hl_color = 'Comment'  -- Gray for configured but not loaded
            end
            vim.api.nvim_buf_add_highlight(buf, ns, hl_color, line_idx, 2, 3)
            vim.api.nvim_buf_add_highlight(buf, ns, 'Normal', line_idx, 4, -1)
        end
        
        vim.api.nvim_buf_add_highlight(buf, ns, 'MoreMsg', #new_lines - 1, 0, -1)
        
        -- Restore buffer protection
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(buf, 'readonly', true)
    end

    local function get_plugin_at_cursor()
        local cursor_line = vim.fn.line('.')
        local plugin_idx = plugin_line_map[cursor_line]
        return plugin_idx and plugins[plugin_idx] or nil
    end
    
    local function update_plugin()
        local plugin = get_plugin_at_cursor()
        if not plugin then
            vim.notify("No plugin selected", vim.log.levels.WARN)
            return
        end
        
        vim.notify("Updating " .. plugin.name .. "...", vim.log.levels.INFO)
        
        -- Use vim.pack.update if the plugin was installed via vim.pack
        local pack_plugins = vim.pack.get()
        local is_pack_plugin = false
        for _, pack_plugin in ipairs(pack_plugins) do
            if pack_plugin.spec.name == plugin.name then
                is_pack_plugin = true
                break
            end
        end
        
        if is_pack_plugin then
            vim.pack.update({ plugin.name }, { force = true })
            vim.notify(plugin.name .. " update initiated!", vim.log.levels.INFO)
        else
            -- Fallback to git pull for non-vim.pack plugins
            vim.system({ "git", "pull" }, { cwd = plugin.path }, function(result)
                vim.schedule(function()
                    if result.code == 0 then
                        vim.notify(plugin.name .. " updated successfully!", vim.log.levels.INFO)
                    else
                        vim.notify("Failed to update " .. plugin.name .. ": " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
                    end
                end)
            end)
        end
    end
    
    local function delete_plugin()
        local plugin = get_plugin_at_cursor()
        if not plugin then
            vim.notify("No plugin selected", vim.log.levels.WARN)
            return
        end
        
        vim.ui.input({
            prompt = "Delete " .. plugin.name .. "? (yes/no): ",
        }, function(input)
            if input == "yes" then
                -- Use vim.pack.del if it's a vim.pack plugin
                local pack_plugins = vim.pack.get()
                local is_pack_plugin = false
                for _, pack_plugin in ipairs(pack_plugins) do
                    if pack_plugin.spec.name == plugin.name then
                        is_pack_plugin = true
                        break
                    end
                end
                
                if is_pack_plugin then
                    vim.pack.del({ plugin.name })
                    deleted_plugins[plugin.name] = true
                    vim.notify(plugin.name .. " deleted successfully!", vim.log.levels.INFO)
                    vim.schedule(function()
                        refresh_display()
                    end)
                else
                    vim.system({ "rm", "-rf", plugin.path }, {}, function(result)
                        vim.schedule(function()
                            if result.code == 0 then
                                deleted_plugins[plugin.name] = true
                                vim.notify(plugin.name .. " deleted successfully!", vim.log.levels.INFO)
                                refresh_display()
                            else
                                vim.notify("Failed to delete " .. plugin.name, vim.log.levels.ERROR)
                            end
                        end)
                    end)
                end
            end
        end)
    end
    
    local function reload_plugins()
        vim.notify("Reloading plugins...", vim.log.levels.INFO)
        vim.api.nvim_win_close(win, true)
        vim.schedule(function()
            require('core.pack').load_plugins()
            M.show()
        end)
    end
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', 'u', '', { noremap = true, silent = true, callback = update_plugin })
    vim.api.nvim_buf_set_keymap(buf, 'n', 'd', '', { noremap = true, silent = true, callback = delete_plugin })
    vim.api.nvim_buf_set_keymap(buf, 'n', 'r', '', { noremap = true, silent = true, callback = reload_plugins })
    
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_win_set_option(win, 'wrap', false)
end

return M