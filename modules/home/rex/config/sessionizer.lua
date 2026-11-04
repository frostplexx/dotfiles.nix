---@diagnostics disable: undefined-global, unused-local, unused-function
require "utils/picker"


-- Set project dir to be HOME/Projects
local project_dir = os.getenv("HOME") .. "/Projects"


-- Enumerate all subdirectories in the project directory using fd
-- Projects can be stored in the following structures:
--      Projects/<host>/<user>/<repo>
--      Projects/<folder>.local/<repo>
--      Projects/<repo> (this should ne be used but oh well)
local function enumerate_projects()
    local projects = {}
    local result, err = rex.exec(
        { "/etc/profiles/per-user/daniel/bin/fd", "--type", "d", "--hidden", "-p", ".git/?$", "--max-depth", "4", "." },
        { cwd = project_dir })
    if result then
        for line in result.stdout:gmatch("[^\r\n]+") do
            -- Remove leading ./ and trailing .git from the line
            line = line:gsub("^%./", ""):gsub("%/.git/$", "")
            table.insert(projects, line)
        end
    else
        error("Failed to enumerate projects: " .. err)
    end
    return projects
end


local function app_client_id()
    local clients = rex.call("client.list")
    for _, client in ipairs(clients and clients.clients or {}) do
        if client.info and client.info.kind == "app" and client.connection_state == "connected" then
            return client.client_id
        end
    end
    return nil
end


print("Enumerating projects in " .. project_dir)

rex.action({
    name = "session_new_project",
    title = "New Project Session",
    description = "Create a new session for a project",
    keywords = "project session",
    run = function()
        picker({
            prompt = "Jump to...",
            items = enumerate_projects(),
            on_select = function(item)
                local project_path = project_dir .. "/" .. item
                print("Selected project: " .. project_path)
                -- create a new session with the selected project as the cwd
                local created, err = rex.call("session.create", {
                    label = " " .. item:gsub("^[^/]*%.[^/]*/", ""),
                    initial_windows = {
                        {
                            layout = rex.layout.block({
                                flavor = "com.superlogical.terminal.shell",
                                options = { cwd = project_path },
                            }),
                        },
                    },
                })
                if err then
                    error(err)
                end

                -- Shows the new session. Needs Remote Control turned on in Rex Settings;
                -- the session exists either way.
                local app_client = app_client_id()
                local select_err
                if app_client then
                    _, select_err = rex.call("client.perform", {
                        client_id = app_client,
                        action = "session.select",
                        args = { session_id = created.session_id },
                    })
                end
                if select_err then
                    -- The picker's callback runs as a CLI connection, so ask the app
                    -- directly. When Rex.app dispatched the action itself, queueing it
                    -- back is enough.
                    local queued, queue_err = pcall(rex.client.queue, "session.select", { session_id = created.session_id })
                    if not queued or queue_err then
                        rex.log("warn", "sessionizer: created session but could not show it: " .. tostring(queue_err))
                    end
                end
            end,
            label = "Project Picker",
            position = "bottom",
            width = 0.5,
            padding = 0.01,
        })
    end,
})

rex.bind("cmd+o", "session_new_project")
