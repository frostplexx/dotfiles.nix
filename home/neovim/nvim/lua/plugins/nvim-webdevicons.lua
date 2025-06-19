return {
    {
        'nvim-tree/nvim-web-devicons',
        -- Lots of plugins will require this later.
        lazy = false,
        event = "VeryLazy",
        priority = 1000, -- Load before other plugins
        opts = {
            -- Make the icon for query files more visible.
            override = {
                scm = {
                    icon = '󰘧',
                    color = '#A9ABAC',
                    cterm_color = '16',
                    name = 'Scheme',
                },
            },
        },
    },
}
