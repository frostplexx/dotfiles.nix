-- Import color scheme for spaces from the main colors configuration
-- This provides consistent theming across the entire bar
local colors = require("colors").sections.spaces

-- Import app icon mapping to show app icons for windows in workspaces
local icon_map = require("helpers.icon_map")

-- Execute aerospace command to get list of all configured workspaces
-- This runs asynchronously and creates space indicators for each workspace found
sbar.exec("aerospace list-workspaces --all", function(spaces_output)
    -- Iterate through each workspace name returned by aerospace
    -- The gmatch pattern splits the output by newlines to get individual workspace names
    for space_name in spaces_output:gmatch "[^\r\n]+" do
        -- Create a new sketchybar item for this workspace
        -- Each space gets a unique identifier: "space." + workspace_name
        local space = sbar.add("item", "space." .. space_name, {

            -- Icon configuration - shows the workspace number/name
            icon = {
                -- Show the workspace number/name instead of dot
                string = space_name,

                -- Horizontal padding around the number (adjust for spacing between workspaces)
                padding_left = 4,  -- Space before the number
                padding_right = 4, -- Space after the number

                -- Colors from theme - inactive and active states
                color = colors.icon.color,               -- Default/inactive color
                highlight_color = colors.icon.highlight, -- Active workspace color

                -- Font settings for the workspace number
                font = {
                    size = 13.0, -- Size of the workspace number
                },
            },

            -- Padding around the entire space item
            padding_left = 2,  -- Space before the entire item
            padding_right = 2, -- Space after the entire item

            -- Background and border configuration for each workspace item
            background = {
                color = require("colors").sections.item.bg, -- Background color from theme
                -- border_color = colors.label.color,  -- Border color from theme
                -- highlight_color = colors.icon.highlight,   -- Active workspace color
                border_width = 1,  -- Border thickness (1px)
                corner_radius = 4, -- Rounded corners (adjust for more/less rounding)
            },

            -- Label configuration - shows app icons for windows in this workspace
            label = {
                font = "sketchybar-app-font:Regular:11.0", -- App icon font
                string = "space",                          -- Default text (will be replaced with app icons)
                color = colors.icon.color,                 -- Default/inactive color
                highlight_color = colors.icon.highlight,   -- Active workspace color
                y_offset = -1,                             -- Vertical positioning adjustment
                padding_right = 12,                        -- Space after the app icons
                padding_left = -1,                         -- Space after the app icons
                drawing = false,                           -- Initially hidden, shown when workspace has apps
            },
        })

        -- Subscribe to workspace change events from aerospace
        -- This handles highlighting the currently active workspace
        space:subscribe("aerospace_workspace_changed", function(env)
            -- Check if this workspace is the currently focused one
            local selected = env.FOCUSED_WORKSPACE == space_name

            -- Update the space appearance based on selection state
            space:set {
                icon = {
                    highlight = selected -- Enable highlight color if selected
                },
                label = {
                    highlight = selected,
                }
            }
        end)

        -- Subscribe to window change events for this workspace
        -- This updates the app icons shown for windows in this workspace
        space:subscribe("space_windows_change", function()
            -- Get list of windows with app names in this workspace
            sbar.exec("aerospace list-windows --format %{app-name} --workspace " .. space_name, function(windows)
                -- Start with empty icon line
                local icon_line = ""
                local has_apps = false

                -- Process each app name returned
                for app in windows:gmatch "[^\r\n]+" do
                    has_apps = true
                    -- Look up the app icon from the icon map
                    local lookup = icon_map[app]

                    -- FIXME: Custom override for Vesktop as thats not in the font
                    if app == "Vesktop" then
                        lookup = icon_map["Discord"]
                    end

                    -- Use the found icon or default icon if app not in map
                    local icon = ((lookup == nil) and icon_map["default"] or lookup)
                    -- Add icon to the line with space separator
                    icon_line = icon_line .. " " .. icon
                end

                -- Update the label to show app icons
                space:set {
                    label = {
                        string = has_apps and icon_line or "", -- Show icons or empty string
                        drawing = has_apps,                    -- Only draw label if there are apps
                    }
                }
            end)
        end)

        -- Handle mouse clicks on workspace indicators
        space:subscribe("mouse.clicked", function(env)
            -- Only respond to left clicks (ignore right clicks)
            if env.BUTTON ~= "right" then
                -- Switch to this workspace using aerospace command
                sbar.exec("aerospace workspace " .. space_name)
            end
            -- Note: Right clicks are ignored - you could add custom behavior here
            -- Example: show workspace menu, rename workspace, etc.
        end)
    end
end)

-- CUSTOMIZATION NOTES:
--
-- To modify the appearance:
-- 1. Change workspace display: icon.string currently shows workspace number/name
-- 2. Adjust spacing: Modify padding_left/padding_right values for icons and labels
-- 3. Change number size: Adjust icon.font.size (12.0 = current, 10.0 = smaller, 14.0 = larger)
-- 4. App icon size: Modify label.font size or change to different app font
-- 5. Colors are defined in colors.lua under sections.spaces
-- 6. App icon spacing: Adjust label.padding_right for space after app icons
--
-- To modify functionality:
-- 1. Hide app icons: Set label.drawing = false permanently
-- 2. Show only app count: Replace icon_line with window count number
-- 3. Custom workspace symbols: Change icon.string to custom symbols instead of space_name
-- 4. App icon mapping: Modify helpers/icon_map.lua to change which icons show for apps
-- 5. Custom click actions: Add behavior for right clicks or modifier keys
--
-- Current behavior:
-- - Shows workspace number/name as main icon
-- - Shows app icons in label when workspace has windows
-- - Highlights active workspace with different colors
-- - Click to switch workspaces
