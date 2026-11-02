---@diagnostics disable: undefined-global, unused-local, unused-function

-- cmd+p opens the command palette with one action per repo under ~/Projects.
-- The list is scanned when the file loads, so new repos need `rex config reload`.

local terminal = "com.superlogical.terminal"
local root = (os.getenv("HOME") or "/Users/daniel") .. "/Projects"

local function list_repos()
    local r = rex.exec({
        "/bin/sh",
        "-c",
        "cd " .. root .. " && find . -maxdepth 4 -name .git -prune -print | sed 's|/\\.git$||; s|^\\./||' | grep -v '/\\.' | sort",
    })
    local repos = {}
    if not r or not r.ok then
        rex.log("warn", "jump: could not list repos under " .. root .. ": " .. tostring(r and r.stderr or "no result"))
        return repos
    end
    for line in r.stdout:gmatch("[^\n]+") do
        repos[#repos + 1] = line
    end
    return repos
end

local function short_name(repo)
    local parts = {}
    for part in repo:gmatch("[^/]+") do
        parts[#parts + 1] = part
    end
    local n = #parts
    if n >= 2 then
        return parts[n - 1] .. "/" .. parts[n]
    end
    return parts[n] or repo
end

local function open_session(repo)
    local label = short_name(repo)
    local created, err = rex.call("session.create", {
        label = label,
        initial_windows = {
            {
                window_label = label,
                layout = rex.layout.block({
                    flavor = terminal .. ".shell",
                    options = { cwd = root .. "/" .. repo },
                }),
            },
        },
    })
    if err then
        error(err)
    end

    -- Shows the new session. Needs Remote Control turned on in Rex Settings;
    -- the session exists either way.
    local ok, select_err = pcall(rex.client.queue, "session.select", { session_id = created.session_id })
    if not ok then
        rex.log("warn", "jump: created " .. repo .. " but could not show it: " .. tostring(select_err))
    end
end

local seen = {}
for _, repo in ipairs(list_repos()) do
    local name = "project_" .. (repo:lower():gsub("[^%w]+", "_"))
    while seen[name] do
        name = name .. "_"
    end
    seen[name] = true

    rex.action({
        name = name,
        title = repo,
        category = "Projects",
        keywords = "project repo session jump " .. repo,
        run = function()
            open_session(repo)
        end,
    })
end

