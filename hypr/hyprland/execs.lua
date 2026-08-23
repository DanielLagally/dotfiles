require("_upstream.hyprland.execs")

-- hyprsplit's C++ plugin is deprecated upstream in favour of this pure-Lua
-- library (vendored at hypr/hyprsplit/) — no plugin load/ABI matching needed.
require("hyprsplit")

hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("easyeffects")

    -- No display manager/UWSM here (launched via plain `start-hyprland`
    -- from a TTY) — nothing else tells systemd this is a graphical
    -- session, so services gated on graphical-session.target (notably
    -- xdg-desktop-portal) never start without this. See the
    -- hyprland-session.target unit in nixos-config's hyprland.nix, and
    -- https://wiki.hypr.land/Useful-Utilities/Systemd-start/#hyprland-sessiontarget
    hl.exec_cmd("systemctl --user start hyprland-session.target")
end)

hl.on("hyprland.shutdown", function()
    os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
end)
