local colors = require("colors").sections
local icons = require "icons"

local apple = sbar.add("item", {
  icon = {
    font = { size = 14 },
    string = icons.apple,
    padding_right = 4,
    padding_left = 4,
    color = colors.apple,
  },
  label = { drawing = false },
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

apple:subscribe("mouse.clicked", function()
  sbar.animate("tanh", 8, function()
    apple:set {
      background = {
        shadow = {
          distance = 0,
        },
      },
      y_offset = -0,
      padding_left = 8,
      padding_right = 0,
    }
    apple:set {
      y_offset = 0,
      padding_left = 4,
      padding_right = 4,
    }
  end)
end)
