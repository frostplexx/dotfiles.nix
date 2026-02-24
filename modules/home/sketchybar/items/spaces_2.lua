-- Import color scheme for spaces from the main colors configuration
-- This provides consistent theming across the entire bar
local colors = require("colors").sections.spaces

-- Execute aerospace command to get list of all configured workspaces
-- This runs asynchronously and creates space indicators for each workspace found
sbar.exec("aerospace list-workspaces --all", function(spaces_output)

  -- Iterate through each workspace name returned by aerospace
  -- The gmatch pattern splits the output by newlines to get individual workspace names
  for space_name in spaces_output:gmatch "[^\r\n]+" do

    -- Create a new sketchybar item for this workspace
    -- Each space gets a unique identifier: "space." + workspace_name
    local space = sbar.add("item", "space." .. space_name, {

      -- Icon configuration - this is the main visual element (the dot)
      icon = {
        -- Use filled circle as default - will change based on window presence
        string = "●",

        -- Horizontal padding around the dot (adjust for spacing between workspaces)
        padding_left = 4,   -- Space before the dot
        padding_right = 4,  -- Space after the dot

        -- Colors from theme - inactive and active states
        color = colors.icon.color,              -- Default/inactive color
        highlight_color = colors.icon.highlight, -- Active workspace color

        -- Font settings for the dot symbol
        font = {
          size = 8.0,  -- Size of the dot (increase for larger dots)
        },
      },

      -- Padding around the entire space item
      padding_left = 2,   -- Space before the entire item
      padding_right = 2,  -- Space after the entire item

      -- Label configuration - currently disabled for minimal design
      label = {
        drawing = false,  -- Set to true if you want text labels alongside dots
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
          highlight = selected  -- Enable highlight color if selected
        },
      }
    end)

    -- Subscribe to window change events for this workspace
    -- This updates the dot appearance based on whether workspace has windows
    space:subscribe("space_windows_change", function()
      -- Get list of windows in this workspace
      sbar.exec("aerospace list-windows --workspace " .. space_name, function(windows)
        -- Check if workspace has any windows (non-whitespace content)
        local has_windows = windows:match("%S") ~= nil

        -- Update dot symbol based on window presence
        space:set {
          icon = {
            -- Filled dot (●) if has windows, empty dot (○) if empty
            -- You can change these symbols to anything you prefer:
            -- Examples: "■"/"□", "▲"/"△", "♦"/"◇", numbers, letters, etc.
            string = has_windows and "●" or "○",
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
-- 1. Change dot symbols: Replace "●" and "○" with your preferred characters
-- 2. Adjust spacing: Modify padding_left/padding_right values
-- 3. Change dot size: Adjust font.size (8.0 = small, 12.0 = medium, 16.0 = large)
-- 4. Add text labels: Set label.drawing = true and configure label properties
-- 5. Colors are defined in colors.lua under sections.spaces
--
-- To add features:
-- 1. Workspace numbers: Change icon.string to space_name for workspace names
-- 2. App count: Show number of windows instead of just presence
-- 3. Custom click actions: Add behavior for right clicks or modifier keys
-- 4. Animations: Add transition effects for state changes
-- 5. Tooltips: Add hover information showing workspace details
