return {
    'rcarriga/nvim-notify',
    event = "BufReadPre",
    enabled = false,
    config = function()
        require("notify").setup(
            {
                background_colour = "NotifyBackground",
                fps = 144,
                icons = {
                    DEBUG = "",
                    ERROR = "",
                    INFO = "",
                    TRACE = "✎",
                    WARN = ""
                },
                level = 2,
                minimum_width = 50,
                render = "wrapped-compact",
                stages = "fade_in_slide_out",
                time_formats = {
                    notification = "%T",
                    notification_history = "%FT%T"
                },
                timeout = 2000,
                top_down = true
            }
        )
        vim.notify = require("notify")
    end
}
