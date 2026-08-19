require("_upstream.hyprland.execs")

-- exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprtasking.so"
-- exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprspace.so"

hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("easyeffects")
    hl.exec_cmd('hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprsplit.so"')
end)
