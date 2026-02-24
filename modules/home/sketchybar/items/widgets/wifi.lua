local icons = require "icons"
local colors = require("colors").sections.widgets.wifi

local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  icon = {
    color = colors.icon,
  },
  label = { drawing = false },
  background = { drawing = false },
  padding_left = 4,
  padding_right = 8,
})

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
  sbar.exec([[ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}']], function(wifi_name)
    local connected = not (wifi_name == "")
    wifi:set {
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
      },
    }
  end)
end)

wifi:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec "open /System/Library/PreferencePanes/Network.prefpane"
  else
    sbar.exec "open x-apple.systempreferences:com.apple.controlcenter"
  end
end)
