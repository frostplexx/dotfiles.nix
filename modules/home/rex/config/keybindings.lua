
-- Focusing
rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("alt+l", "pane.focus", { direction = "right" })

-- Resizing
rex.bind("alt+shift+h", "pane.resize", { direction = "left" })
rex.bind("alt+shift+j", "pane.resize", { direction = "down" })
rex.bind("alt+shift+k", "pane.resize", { direction = "up" })
rex.bind("alt+shift+l", "pane.resize", { direction = "right" })

-- Moving
rex.bind("ctrl+alt+h", "pane.move", { direction = "left" })
rex.bind("ctrl+alt+j", "pane.move", { direction = "down" })
rex.bind("ctrl+alt+k", "pane.move", { direction = "up" })
rex.bind("ctrl+alt+l", "pane.move", { direction = "right" })


rex.bind("cmd+e", "pane.zoom")
rex.bind("alt+r", "session.rename")
rex.bind("shift+cmd+w", "session.close")
rex.bind("shift+cmd+d", "pane.split", { direction = "down" })
rex.bind("cmd+d", "pane.split", { direction = "right" })


rex.bind("cmd+p", "client.palette.toggle")

rex.bind("cmd+g", "lazygit_float")
rex.bind("cmd+s", "floating_term")

-- Unbind some default keybindings
rex.unbind("shift+cmd+p", "client.palette.toggle")


