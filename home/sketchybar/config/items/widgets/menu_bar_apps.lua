local icons = require "icons"
local colors = require("colors").sections.widgets

local notification_center = sbar.add("item", "widgets.notification_center", {
  position = "right",
  icon = {
    string = icons.message,
    font = { size = 14 },
    color = colors.wifi.icon,
    padding_left = 8,
    padding_right = 8,
  },
  label = { drawing = false },
  background = { drawing = false },
})

notification_center:subscribe("mouse.clicked", function()
  sbar.exec "osascript -e 'tell application \"System Events\" to key code 107 using {command down, option down}'"
end)

local control_center = sbar.add("item", "widgets.control_center", {
  position = "right",
  icon = {
    string = icons.gear,
    font = { size = 14 },
    color = colors.wifi.icon,
    padding_left = 8,
    padding_right = 8,
  },
  label = { drawing = false },
  background = { drawing = false },
})

control_center:subscribe("mouse.clicked", function()
  sbar.exec "osascript -e 'tell application \"System Events\" to key code 49 using {command down, option down}'"
end)

local spotlight = sbar.add("item", "widgets.spotlight", {
  position = "right",
  icon = {
    string = "",
    font = { size = 14 },
    color = colors.wifi.icon,
    padding_left = 8,
    padding_right = 8,
  },
  label = { drawing = false },
  background = { drawing = false },
})

spotlight:subscribe("mouse.clicked", function()
  sbar.exec "osascript -e 'tell application \"System Events\" to keystroke space using command down'"
end)
