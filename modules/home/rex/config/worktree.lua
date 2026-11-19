---@diagnostics disable: undefined-global, unused-local, unused-function
-- 1. check if we are in a git repo
-- 2. if yes ask for worktree name
-- 3. create a new worktree next to the repo
-- 4. create a new session in the new worktree

local terminal = "com.superlogical.terminal"

local function trim(text)
    return (text:gsub("%s+$", ""))
end

-- rex.exec in an action runs in the server's directory, so ask the terminal
-- block where it is.
local function block_cwd(ctx)
    local reported = rex.call("block.method", {
        session_id = ctx.session_id,
        block_id = ctx.block_id,
        method = "pwd",
        args = {},
    })
    if reported and reported.pwd then
        return (reported.pwd:gsub("^file://[^/]*", ""))
    end

    local process = rex.call("block.method", {
        session_id = ctx.session_id,
        block_id = ctx.block_id,
        method = "process",
        args = {},
    })
    if process and process.foreground and process.foreground.cwd then
        return process.foreground.cwd
    end

    return nil
end

local function git_toplevel(cwd)
    local result, err = rex.exec({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd })
    if result == nil then
        return nil, err
    end
    if not result.ok then
        return nil, trim(result.stderr)
    end
    return trim(result.stdout)
end

rex.action({
    name = "session_worktree",
    title = "Git: New Worktree",
    description = "Create a new worktree and jump to it",
    keywords = "worktree git session",
    run = function(ctx)
        local cwd = block_cwd(ctx)
        if cwd == nil then
            error("session_worktree: cannot tell the terminal's working directory", 0)
        end

        local toplevel, git_err = git_toplevel(cwd)
        if toplevel == nil then
            rex.log("warn", "session_worktree: not a git repository: " .. tostring(git_err))
            return
        end

        local name, why = rex.ui.input({
            title       = "New Worktree",
            placeholder = "feature/...",
            value       = "",
            confirm     = "Create worktree",
        })

        if name == nil or name == "" then return end

        local repo_parent, repo_name = toplevel:match("^(.*)/([^/]+)$")
        local wt_path = repo_parent .. "/" .. repo_name .. "-" .. name:gsub("/", "-")

        local result, exec_err = rex.exec({
            "git",
            "worktree",
            "add",
            "-b",
            name,
            wt_path,
        }, { cwd = toplevel })

        if result == nil then
            error(exec_err, 0)
        end
        if not result.ok then
            error(trim(result.stderr), 0)
        end

        local created, create_err = rex.call("session.create", {
            label = name,
            initial_windows = {
                {
                    layout = rex.layout.block({
                        flavor = terminal .. ".shell",
                        options = { cwd = wt_path },
                    }),
                },
            },
        })
        if created == nil then
            error(create_err, 0)
        end

        local queued, queue_err = pcall(rex.client.queue, "session.select", { session_id = created.session_id })
        if not queued then
            rex.log("warn", "session_worktree: created session but could not show it: " .. tostring(queue_err))
        end
    end,
})
