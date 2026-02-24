local colors = require("colors").sections.widgets.volume
local icons = require "icons"

local volume_icon = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    color = colors.icon,
  },
  label = { drawing = false },
  background = { drawing = false },
  padding_right = 8,
  padding_left = 4,
})

volume_icon:subscribe("volume_change", function(env)
  local icon = icons.volume._0
  local volume = tonumber(env.INFO)

  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  volume_icon:set { icon = icon }
end)

volume_icon:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec "open /System/Library/PreferencePanes/Sound.prefpane"
  end
end)

local function volume_scroll(env)
  local delta = env.SCROLL_DELTA
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.scrolled", volume_scroll)
