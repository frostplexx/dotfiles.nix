local icons = require "icons"
local colors = require("colors").sections.calendar
local settings = require "settings"

local cal = sbar.add("item", {
  icon = {
    padding_left = 8,
    padding_right = 4,
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Medium"],
    },
  },
  label = {
    color = colors.label,
    align = "left",
    padding_right = 8,
  },
  padding_left = 10,
  position = "right",
  update_freq = 30,
  click_script = "$CONFIG_DIR/helpers/notification_center/notification_center",
})

-- english date
cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set { icon = os.date "%b %d %H:%M", label = icons.calendar }
end)
