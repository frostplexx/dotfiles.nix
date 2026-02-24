local colors = require("colors").sections.bar

-- Equivalent to the --bar domain
sbar.bar {
  topmost = "window",
  height = 22,
  color = colors.bg,
  padding_right = 4,
  padding_left = 4,
  margin = 5,
  corner_radius = 5,
  y_offset = 2,
  border_color = colors.border,
  border_width = 0,
  blur_radius = 32,
}
