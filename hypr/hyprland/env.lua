local vars = require("variables")

require("_upstream.hyprland.env")

-- Qt icon theming: upstream's env sets QT_QPA_PLATFORMTHEME=qtengine, a
-- custom plugin that isn't built/installed. Override with qt5ct (which
-- is), matching the qt.platformTheme NixOS module setting.
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- Steam (XWayland) otherwise uses DGA to confine the pointer to its window.
hl.env("SDL_VIDEO_X11_DGAMOUSE", "0")

-- Cursors
hl.env("GDK_SCALE", "1")
hl.env("HYPRCURSOR_THEME", vars.cursorTheme)
hl.env("HYPRCURSOR_SIZE", vars.cursorSize)
hl.env("XCURSOR_THEME", "BreezeX-RoséPine")
hl.env("XCURSOR_SIZE", "24")
