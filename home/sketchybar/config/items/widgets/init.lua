-- require "items.widgets.messages"
require "items.widgets.volume"
require "items.widgets.wifi"
require "items.widgets.battery"
require "items.widgets.menu_bar_apps"

sbar.add("bracket", { "/widgets\\..*/" }, {})

sbar.add("item", "widget.padding", {
  width = 16,
})
