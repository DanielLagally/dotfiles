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
