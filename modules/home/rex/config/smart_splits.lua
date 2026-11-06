-- Neovim and Rex panes behave as one grid for smart-splits.nvim. The client
-- this config runs against has no smart_splits_* actions yet, so define them.
local directions = { h = "left", j = "down", k = "up", l = "right" }
local default_resize_amount = 3

local function is_vim_foreground(ctx)
    local process = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    local foreground = process and process.foreground
    if not foreground then
        return false
    end
    -- `name` is not always the executable's name, so check `argv0` too
    for _, executable in ipairs({ foreground.name or "", (foreground.argv0 or ""):match("[^/]*$") }) do
        if executable:match("^n?vim") then
            return true
        end
    end
    return false
end

rex.action({
    name = "smart_splits_focus",
    title = "Smart Splits: Focus Pane",
    args = { direction = "string", key = "string?" },
    run = function(ctx, args)
        if is_vim_foreground(ctx) then
            if not args.key then
                error("smart_splits_focus: no key given to forward to Neovim", 0)
            end
            rex.client.queue("pane.send_key", { key = args.key })
            return
        end
        local _, err = rex.session.focus_direction({ direction = args.direction })
        if err ~= nil then
            error(err, 0)
        end
    end,
})

rex.action({
    name = "smart_splits_resize",
    title = "Smart Splits: Resize Pane",
    args = { direction = "string", key = "string?", amount = "number?" },
    run = function(ctx, args)
        if is_vim_foreground(ctx) then
            if not args.key then
                error("smart_splits_resize: no key given to forward to Neovim", 0)
            end
            rex.client.queue("pane.send_key", { key = args.key })
            return
        end
        rex.client.queue("pane.resize", {
            direction = args.direction,
            amount = args.amount or default_resize_amount,
        })
    end,
})

for key, direction in pairs(directions) do
    rex.bind("ctrl+" .. key, "smart_splits_focus", { direction = direction, key = "ctrl+" .. key })
    rex.bind("alt+" .. key, "smart_splits_resize", { direction = direction, key = "alt+" .. key })
end
