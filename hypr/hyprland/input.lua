require("_upstream.hyprland.input")

hl.config({
    input = {
        kb_layout = "de",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:super",
        kb_rules = "",

        follow_mouse = 1,

        repeat_rate = 25,
        repeat_delay = 200,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        -- accel_profile = "custom 0.8 0.0 0.3 0.8 2.0 3.5",
        accel_profile = "flat",

        scroll_method = "on_button_down",
        scroll_button = 274,

        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.5,
        },
    },

    cursor = {
        -- Nvidia + Hyprland's "auto" heuristic (cursor:no_hardware_cursors)
        -- falls back to a software-rendered cursor, which gets baked
        -- directly into any screen-buffer capture (e.g. caelestia's region
        -- screenshot picker) since it's not on a separate hardware overlay
        -- plane that capture tools can exclude. Force hardware cursors back
        -- on to fix this. See github.com/caelestia-dots/shell/issues/960.
        no_hardware_cursors = false,
    },
})

hl.device({
    name = "sony-interactive-entertainment-dualsense-wireless-controller-touchpad",
    enabled = false,
})

hl.device({
    name = "wacom-one-by-wacom-s-pen",
    output = "DP-1",
    left_handed = true,
})
