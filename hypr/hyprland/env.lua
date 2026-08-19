local vars = require("variables")

require("_upstream.hyprland.env")

-- Cursors
hl.env("GDK_SCALE", "1")
hl.env("HYPRCURSOR_THEME", vars.cursorTheme)
hl.env("HYPRCURSOR_SIZE", vars.cursorSize)
hl.env("XCURSOR_THEME", "BreezeX-RoséPine")
hl.env("XCURSOR_SIZE", "24")
