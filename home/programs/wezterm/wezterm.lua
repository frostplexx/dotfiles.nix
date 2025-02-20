local wezterm = require('wezterm')
local config = wezterm.config_builder()
local act = wezterm.action

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
    options = {
        icons_enabled = true,
        theme = 'Catppuccin Mocha',
        tabs_enabled = true,
        theme_overrides = {},
        section_separators = {
            left = wezterm.nerdfonts.pl_left_hard_divider,
            right = wezterm.nerdfonts.pl_right_hard_divider,
        },
        component_separators = {
            left = wezterm.nerdfonts.pl_left_soft_divider,
            right = wezterm.nerdfonts.pl_right_soft_divider,
        },
        tab_separators = {
            left = wezterm.nerdfonts.pl_left_hard_divider,
            right = wezterm.nerdfonts.pl_right_hard_divider,
        },
    },
    sections = {
        tabline_a = { 'mode' },
        tabline_b = { 'workspace' },
        tabline_c = { '' },
        tab_active = { 'index', { 'cwd', padding = { left = 0, right = 1 } }, },
        tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
        tabline_x = { 'ram', 'cpu' },
        tabline_y = { 'battery' },
        tabline_z = { 'datetime' },
    },
    extensions = {},
})

tabline.apply_to_config(config)

-- Font configuration
-- config.font = wezterm.font('JetBrains Mono')
config.font = wezterm.font('CommitMono')
config.font_size = wezterm.target_triple:find('darwin') and 13 or 10

-- Window configuration
config.window_padding = {
    left = 2,
    right = 0,
    top = 4,
    bottom = 0.5,
}

config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
}

config.color_scheme = 'Catppuccin Mocha'
config.window_background_opacity = 0.8

config.max_fps = 144
config.animation_fps = 144

config.macos_window_background_blur = 20
config.window_decorations = wezterm.target_triple:find('darwin') and "RESIZE" or "TITLE | RESIZE"
config.enable_scroll_bar = false
config.default_cursor_style = 'SteadyBlock'
config.scrollback_lines = 10000

-- Tab bar configuration
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 25
config.hide_tab_bar_if_only_one_tab = false

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


local function switch_in_direction(dir)
    return function(window)
        local tab = window:active_tab()
        local next_pane = tab:get_pane_direction(dir)
        if next_pane then
            tab.swap_active_with_index(next_pane, true)
        end
    end
end

-- Source: https://github.com/numToStr/Navigator.nvim/wiki/WezTerm-Integration
local function isViProcess(pane)
    -- get_foreground_process_name On Linux, macOS and Windows,
    -- the process can be queried to determine this path. Other operating systems
    -- (notably, FreeBSD and other unix systems) are not currently supported
    return pane:get_foreground_process_name():find('n?vim') ~= nil or pane:get_title():find("n?vim") ~= nil
end

local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
    if isViProcess(pane) then
        window:perform_action(
            act.SendKey({ key = vim_direction, mods = 'CTRL' }),
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

-- Key bindings with force-local modifier to ensure they work in multiplexed mode
config.keys = {
    -- Split management
    {
        key = '_',
        mods = 'CTRL|SHIFT',
        action = act({ SplitPane = { direction = 'Down', size = { Percent = 50 } } }),
    },
    {
        key = '+',
        mods = 'CTRL|SHIFT',
        action = act({ SplitPane = { direction = 'Right', size = { Percent = 50 } } }),
    },
    -- Navigation
    {
        key = 'h',
        mods = 'CTRL',
        action = act.Multiple({
            act({ EmitEvent = 'ActivatePaneDirection-left' }),
            act.DisableDefaultAssignment,
        })
    },
    {
        key = 'j',
        mods = 'CTRL',
        action = act.Multiple({
            act({ EmitEvent = 'ActivatePaneDirection-down' }),
            act.DisableDefaultAssignment,
        })
    },
    {
        key = 'k',
        mods = 'CTRL',
        action = act.Multiple({
            act({ EmitEvent = 'ActivatePaneDirection-up' }),
            act.DisableDefaultAssignment,
        })
    },
    {
        key = 'l',
        mods = 'CTRL',
        action = act.Multiple({
            act({ EmitEvent = 'ActivatePaneDirection-right' }),
            act.DisableDefaultAssignment,
        })
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
        action = act({ AdjustPaneSize = { 'Left', 1 } }),
    },
    {
        key = 'RightArrow',
        mods = 'CTRL|SHIFT',
        action = act({ AdjustPaneSize = { 'Right', 1 } }),
    },
    {
        key = 'UpArrow',
        mods = 'CTRL|SHIFT',
        action = act({ AdjustPaneSize = { 'Up', 1 } }),
    },
    {
        key = 'DownArrow',
        mods = 'CTRL|SHIFT',
        action = act({ AdjustPaneSize = { 'Down', 1 } }),
    },
}

-- Mouse configuration
config.hide_mouse_cursor_when_typing = true
config.mouse_bindings = {
    -- Make Alt-Click work for selection
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'ALT',
        action = act.CompleteSelection 'ClipboardAndPrimarySelection',
    },
}

-- URL configuration
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Set working directory for new splits
config.default_cwd = wezterm.home_dir

return config
