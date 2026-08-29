require("_upstream.hyprland.rules")

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- fix tooltips (always have a title of `win.<id>`)
hl.window_rule({
    match = { class = "^(.*jetbrains.*)$", title = "^(win.*)$" },
    no_initial_focus = true,
    no_focus = true,
})
-- fix tab dragging (always have a single space character as their title)
hl.window_rule({
    match = { class = "^(.*jetbrains.*)$", title = "^\\s$" },
    no_initial_focus = true,
    no_focus = true,
})

hl.window_rule({
    match = { class = "zen-twilight" },
    opaque = true,
    opacity = "1 override",
})
