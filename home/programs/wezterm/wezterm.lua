local wezterm = require('wezterm')
local config = wezterm.config_builder()
local act = wezterm.action

-- Font configuration
config.font = wezterm.font('JetBrains Mono')
config.font_size = wezterm.target_triple:find('darwin') and 13 or 10

-- Window configuration
config.window_padding = {
    left = 2,
    right = 2,
    top = 4,
    bottom = 0.5,
}

config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
}

config.max_fps = 144

config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.enable_scroll_bar = false
config.default_cursor_style = 'SteadyBlock'
config.scrollback_lines = 10000

-- Tab bar configuration
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 25
config.hide_tab_bar_if_only_one_tab = true

-- Color configuration
config.colors = {
    tab_bar = {
        active_tab = {
            bg_color = '#8aadf4',
            fg_color = '#1a1b26',
        }
    }
}

-- Bell configuration
config.audible_bell = "Disabled"
config.visual_bell = {
    fade_in_duration_ms = 0,
    fade_out_duration_ms = 0,
}



-- Source: https://github.com/numToStr/Navigator.nvim/wiki/WezTerm-Integration
local function switch_in_direction(dir)
    return function(window)
        local tab = window:active_tab()
        local next_pane = tab:get_pane_direction(dir)
        if next_pane then
            tab.swap_active_with_index(next_pane, true)
        end
    end
end


local function isViProcess(pane)
    -- get_foreground_process_name On Linux, macOS and Windows,
    -- the process can be queried to determine this path. Other operating systems
    -- (notably, FreeBSD and other unix systems) are not currently supported
    return pane:get_foreground_process_name():find('n?vim') ~= nil or pane:get_title():find("n?vim") ~= nil
end

local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
    if isViProcess(pane) then
        window:perform_action(
        -- This should match the keybinds you set in Neovim.
            act.SendKey({ key = vim_direction, mods = 'ALT' }),
            pane
        )
    else
        window:perform_action(act.ActivatePaneDirection(pane_direction), pane)
    end
end

wezterm.on('ActivatePaneDirection-right', function(window, pane)
    conditionalActivatePane(window, pane, 'Right', 'l')
end)
wezterm.on('ActivatePaneDirection-left', function(window, pane)
    conditionalActivatePane(window, pane, 'Left', 'h')
end)
wezterm.on('ActivatePaneDirection-up', function(window, pane)
    conditionalActivatePane(window, pane, 'Up', 'k')
end)
wezterm.on('ActivatePaneDirection-down', function(window, pane)
    conditionalActivatePane(window, pane, 'Down', 'j')
end)

-- Key bindings
config.keys = {
    -- Split management
    {
        key = '_',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitPane {
            direction = 'Down',
            size = { Percent = 50 },
        },
    },
    {
        key = '+',
        mods = 'CTRL|SHIFT',

        action = wezterm.action.SplitPane {
            direction = 'Right',
            size = { Percent = 50 },
        },
    },
    -- Navigation
    { key = 'h', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-left') },
    { key = 'j', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-down') },
    { key = 'k', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-up') },
    { key = 'l', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-right') },
    -- Resize panes
    {
        key = 'LeftArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Left', 1 },
    },
    {
        key = 'RightArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Right', 1 },
    },
    {
        key = 'UpArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Up', 1 },
    },
    {
        key = 'DownArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Down', 1 },
    },
    -- Move Panes
    {
        key = 'H',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(switch_in_direction('Left')),
    },
    {
        key = 'J',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(switch_in_direction('Down')),
    },
    {
        key = 'K',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(switch_in_direction('Up')),
    },
    {
        key = 'L',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(switch_in_direction('Right')),
    },
    -- Resize panes
    {
        key = 'LeftArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Left', 1 },
    },
    {
        key = 'RightArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Right', 1 },
    },
    {
        key = 'UpArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Up', 1 },
    },
    {
        key = 'DownArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Down', 1 },
    },
    -- Close pane
    {
        key = 'x',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },
}

-- Mouse configuration
config.hide_mouse_cursor_when_typing = true
config.mouse_bindings = {
    -- Make Alt-Click work for selection
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'ALT',
        action = wezterm.action.CompleteSelection 'ClipboardAndPrimarySelection',
    },
}

-- URL configuration
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Set working directory for new splits
config.default_cwd = wezterm.home_dir

return config
