local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font('JetBrains Mono')
config.font_size = wezterm.target_triple:find('darwin') and 13 or 10

-- Window configuration
config.window_padding = {
    left = 2,
    right = 2,
    top = 2,
    bottom = 2,
}

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
    {
        key = 'h',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
        key = 'j',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Down',
    },
    {
        key = 'k',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
        key = 'l',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Right',
    },
    -- Resize panes
    {
        key = 'LeftArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Left', 2 },
    },
    {
        key = 'RightArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Right', 2 },
    },
    {
        key = 'UpArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Up', 2 },
    },
    {
        key = 'DownArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.AdjustPaneSize { 'Down', 2 },
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
