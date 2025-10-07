local settings = require "settings"

local max_items = 15
local menu_items = {}
local current_menus = {} -- Cache to avoid unnecessary updates

for i = 1, max_items, 1 do
    local menu = sbar.add("item", "menu." .. i, {
        position = "left",
        drawing = false,
        icon = { drawing = false },
        background = { drawing = false },
        label = {
            font = {
                style = settings.font.style_map[i == 1 and "Medium" or "Italic"],
            },
            padding_left = 6,
            padding_right = 6,
        },
        click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
    })
    menu_items[i] = menu
end

sbar.add("bracket", { "/menu\\..*/" }, {})

local menu_padding = sbar.add("item", "menu.padding", {
    drawing = false,
    width = 5,
})

local function update_menus(env)
    sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
        -- Parse menus into table
        local new_menus = {}
        for menu in string.gmatch(menus, "[^\r\n]+") do
            table.insert(new_menus, menu)
        end

        -- Check if menus actually changed (avoid unnecessary updates)
        local menus_changed = #new_menus ~= #current_menus
        if not menus_changed then
            for i = 1, #new_menus do
                if new_menus[i] ~= current_menus[i] then
                    menus_changed = true
                    break
                end
            end
        end

        if not menus_changed then
            return -- Exit early if nothing changed
        end

        -- Update cache
        current_menus = new_menus

        -- Batch all updates into a single command for efficiency
        local updates = {}

        -- Update each menu item
        for i = 1, max_items do
            if new_menus[i] then
                table.insert(updates, {
                    item = "menu." .. i,
                    label = new_menus[i],
                    drawing = true
                })
            else
                table.insert(updates, {
                    item = "menu." .. i,
                    drawing = false
                })
            end
        end

        -- Apply all updates
        for _, update in ipairs(updates) do
            menu_items[tonumber(update.item:match("%d+"))]:set(update)
        end

        -- Update padding
        menu_padding:set { drawing = (#new_menus > 0) }
    end)
end

-- Only subscribe one item to reduce overhead
menu_items[1]:subscribe("front_app_switched", update_menus)

sbar.add("event", "aerospace_workspace_changed")
menu_items[1]:subscribe("aerospace_workspace_changed", update_menus)

-- Move menus after spaces once spaces are loaded
sbar.exec("aerospace list-workspaces --all", function(spaces_output)
    local last_space = nil
    for space_name in spaces_output:gmatch "[^\r\n]+" do
        last_space = space_name
    end

    if last_space then
        -- Build single command to move all menu items efficiently
        local move_cmd = "sketchybar"
        local prev_item = "space." .. last_space

        for i = 1, max_items do
            move_cmd = move_cmd .. " --move menu." .. i .. " after " .. prev_item
            prev_item = "menu." .. i
        end
        move_cmd = move_cmd .. " --move menu.padding after " .. prev_item

        -- Execute all moves in a single command for performance
        sbar.exec(move_cmd)
    end
end)

update_menus()
