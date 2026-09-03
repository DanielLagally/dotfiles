local fn = require("_upstream.utils.functions")
local hs = require("hyprsplit")

-- hyprsplit's swap_monitors() needs explicit monitor names, unlike the old
-- C++ plugin's `split:swapactiveworkspaces current +1` — resolve "current"
-- and "next" (wrapping, ordered by monitor id) freshly on every keypress.
--
-- NOTE: this moves windows one at a time (hyprsplit's own implementation,
-- documented as "does not preserve layout"), so tiling order/position can
-- shift. A version that moves the whole workspace via monitor:set_workspace
-- instead (preserving the layout tree) hit an unresolved Hyprland-internal
-- edge case on the second half of the swap — see git history if revisiting.
local function swap_with_next_monitor()
    return function()
        local active = hl.get_active_monitor()
        local mons = hl.get_monitors()
        if not active or #mons < 2 then return end

        table.sort(mons, function(a, b) return a.id < b.id end)

        local idx
        for i, m in ipairs(mons) do
            if m.id == active.id then
                idx = i
                break
            end
        end
        if not idx then return end

        local next_mon = mons[(idx % #mons) + 1]
        return hs.dsp.workspace.swap_monitors({ monitor1 = active.name, monitor2 = next_mon.name })()
    end
end

-- Same workspace-index math as upstream's fn.wsaction, but supporting a
-- silent move (window follows to the target workspace without switching
-- view to it) — upstream's own wsaction() dropped that mode.
local function wsaction_move_silent(range, i)
    return function()
        local activews = hl.get_active_workspace()
        if activews then
            local id = activews.id
            local s  = (i - 1) * 10 + (id % 10)
            local t  = math.floor((id - 1) / 10) * 10 + i
            local z  = (range == "group") and s or t
            return hl.dispatch(hl.dsp.window.move({ workspace = z, follow = false }))
        end
    end
end

-- If already viewing this special WS, hide it. If it has windows, show it.
-- If empty, show it first then spawn — Zen PWAs reuse an existing process, so
-- `[workspace special:]` on exec never applies; they land on the focused WS.
local function toggle_special(name, cmds)
    return function()
        local target = "special:" .. name
        local active = hl.get_active_special_workspace()
        if active and active.name == target then
            return hl.dispatch(hl.dsp.workspace.toggle_special(name))
        end
        local occupied = false
        for _, w in ipairs(hl.get_windows() or {}) do
            if w.workspace and w.workspace.name == target then
                occupied = true
                break
            end
        end
        if occupied then
            return hl.dispatch(hl.dsp.workspace.toggle_special(name))
        end
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
        for _, cmd in ipairs(cmds) do
            hl.dispatch(hl.dsp.exec_cmd(cmd))
        end
    end
end

hl.define_submap("global", function()

    -- ## Shell keybinds
    -- Launcher
    hl.bind("SUPER + Space", hl.dsp.global("caelestia:launcher"))
    -- `catchall` moved from an `hl.bind` option to a magic key-string value
    -- in newer Hyprland builds (only valid inside a submap, hence here) —
    -- there's no longer a way to gate it to a specific modifier like SUPER.
    hl.bind("catchall", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })
    hl.bind("SUPER + mouse:272", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })
    hl.bind("SUPER + mouse:273", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })
    hl.bind("SUPER + mouse:274", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })
    hl.bind("SUPER + mouse:275", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })
    hl.bind("SUPER + mouse:276", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })
    hl.bind("SUPER + mouse:277", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })
    hl.bind("SUPER + mouse_up", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })
    hl.bind("SUPER + mouse_down", hl.dsp.global("caelestia:launcherInterrupt"), { non_consuming = true, ignore_mods = true })

    -- Misc
    hl.bind("CTRL+ALT + Delete", hl.dsp.global("caelestia:session"))
    hl.bind("CTRL+ALT + C", hl.dsp.global("caelestia:clearNotifs"), { locked = true, non_consuming = true })
    hl.bind("SUPER + N", hl.dsp.global("caelestia:sidebar"))

    -- Restore lock
    hl.bind("SUPER+ALT + L", hl.dsp.exec_cmd("caelestia shell -d"), { locked = true })
    hl.bind("SUPER+ALT + L", hl.dsp.global("caelestia:lock"), { locked = true })

    -- Brightness
    hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true })

    -- Media
    hl.bind("CTRL+SUPER + Space", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    hl.bind("CTRL+SUPER + Equal", hl.dsp.global("caelestia:mediaNext"), { locked = true })
    hl.bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true })
    hl.bind("CTRL+SUPER + Minus", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
    hl.bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true })

    -- Kill/restart
    hl.bind("CTRL+SUPER+SHIFT + R", hl.dsp.exec_cmd("caelestia shell -k"), { release = true })
    hl.bind("CTRL+SUPER+ALT + R", hl.dsp.exec_cmd("caelestia shell -k; sleep 1; caelestia shell -d"), { release = true })

    -- Go to / move to workspace #, and workspace group #
    for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        hl.bind("SUPER + " .. key, fn.wsaction("focus", "", i))
        hl.bind("CTRL+SUPER + " .. key, fn.wsaction("focus", "group", i))
        hl.bind("SUPER+ALT+SHIFT + " .. key, fn.wsaction("move", "", i))
        hl.bind("SUPER+SHIFT + " .. key, wsaction_move_silent("", i))
        hl.bind("CTRL+SUPER+ALT + " .. key, fn.wsaction("move", "group", i))
    end

    -- Go to workspace -1/+1
    hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "-1" }))
    hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "+1" }))
    hl.bind("CTRL+SUPER + right", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
    hl.bind("CTRL+SUPER + left", hl.dsp.focus({ workspace = "+1" }), { repeating = true })
    hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
    hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "+1" }), { repeating = true })
    -- Go to workspace group -1/+1
    hl.bind("CTRL+SUPER + mouse_down", hl.dsp.focus({ workspace = "-10" }))
    hl.bind("CTRL+SUPER + mouse_up", hl.dsp.focus({ workspace = "+10" }))
    -- Toggle steam/game special workspace
    hl.bind("SUPER + S", toggle_special("steam", { "steam" }))

    -- Move window to workspace -1/+1
    hl.bind("SUPER+ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
    hl.bind("SUPER+ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
    hl.bind("SUPER+ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
    hl.bind("SUPER+ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))
    hl.bind("CTRL+SUPER+SHIFT + right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
    hl.bind("CTRL+SUPER+SHIFT + left", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
    -- Move window to/from steam/game special workspace
    hl.bind("SUPER+SHIFT + S", hl.dsp.window.move({ workspace = "special:steam" }))

    -- Window groups
    hl.bind("ALT + Tab", hl.dsp.window.cycle_next({ next = true }), { repeating = true })
    hl.bind("SHIFT+ALT + Tab", hl.dsp.window.cycle_next({ next = false }), { repeating = true })
    hl.bind("CTRL+ALT + Tab", hl.dsp.group.next(), { repeating = true })
    hl.bind("CTRL+SHIFT+ALT + Tab", hl.dsp.group.prev(), { repeating = true })
    hl.bind("SUPER + Comma", hl.dsp.group.toggle())
    hl.bind("SUPER + U", hl.dsp.window.move({ out_of_group = true }))
    hl.bind("SUPER+SHIFT + Comma", hl.dsp.group.lock_active())

    -- Window actions
    hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
    hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
    hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
    hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
    hl.bind("SUPER+SHIFT + h", hl.dsp.window.move({ direction = "left" }))
    hl.bind("SUPER+SHIFT + l", hl.dsp.window.move({ direction = "right" }))
    hl.bind("SUPER+SHIFT + k", hl.dsp.window.move({ direction = "up" }))
    hl.bind("SUPER+SHIFT + j", hl.dsp.window.move({ direction = "down" }))
    hl.bind("SUPER + Minus", hl.dsp.layout("splitratio, -0.1"), { repeating = true })
    hl.bind("SUPER + Plus", hl.dsp.layout("splitratio, 0.1"), { repeating = true })
    hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
    hl.bind("CTRL+SUPER + Period", hl.dsp.window.center())
    hl.bind("CTRL+SUPER+ALT + Period", function()
        local m = hl.get_active_monitor()
        if not m then return end
        hl.dispatch(hl.dsp.window.resize({ x = math.floor(m.width * 0.55), y = math.floor(m.height * 0.70) }))
        hl.dispatch(hl.dsp.window.center())
    end)
    hl.bind("SUPER+ALT + Period", hl.dsp.exec_cmd("caelestia resizer pip")) -- Move window to picture-in-picture mode
    hl.bind("SUPER + P", hl.dsp.window.pin())
    hl.bind("SUPER+ALT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
    hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })) -- Fullscreen with borders
    hl.bind("SUPER+ALT + Space", hl.dsp.window.float({ action = "toggle" }))
    hl.bind("SUPER + Q", hl.dsp.window.close())
    hl.bind("SUPER+ALT + Q", hl.dsp.window.kill())

    -- Special workspace toggles
    hl.bind("CTRL+SHIFT + Escape", toggle_special("sysmon", {
        "foot -a btop -T btop fish -C 'exec btop'",
    }))
    hl.bind("SUPER + M", toggle_special("soundcloud", { "app2unit -- Soundcloud.desktop" }))
    hl.bind("SUPER + D", toggle_special("communication", { "equibop" }))
    hl.bind("SUPER + W", toggle_special("whatsapp", { "altus" }))
    hl.bind("SUPER + T", toggle_special("thunderbird", { "thunderbird" }))
    hl.bind("SUPER + R", toggle_special("todo", { "todoist" }))
    hl.bind("SUPER + G", toggle_special("grok", { "app2unit -- Grok.desktop" }))
    hl.bind("SUPER + C", toggle_special("claude", { "app2unit -- Claude.desktop" }))
    hl.bind("SUPER + Y", toggle_special("zen", { "app2unit -- zen-twilight" }))
    hl.bind("SUPER + X", toggle_special("helix", { "foot -a helix -T helix fish -ic hx" }))
    hl.bind("SUPER + E", toggle_special("yazi", { "foot -a yazi -T yazi fish -ic yazi" }))

    -- Apps
    hl.bind("SUPER + Return", hl.dsp.exec_cmd("app2unit -- foot"))
    hl.bind("CTRL+ALT + V", hl.dsp.exec_cmd("app2unit -- pavucontrol"))

    -- Utilities
    hl.bind("Print", hl.dsp.exec_cmd("$HOME/Dev/lensy/result/bin/lensy region --freeze; pkill -9 hyprpicker"))
    hl.bind("ALT + Print", hl.dsp.exec_cmd("caelestia screenshot"), { locked = true }) -- Full screen capture > clipboard
    hl.bind("SHIFT + Print", hl.dsp.global("caelestia:screenshotFreeze")) -- Capture region (freeze)
    hl.bind("SUPER+ALT + R", hl.dsp.exec_cmd("caelestia record -s")) -- Record screen with sound
    hl.bind("CTRL+ALT + R", hl.dsp.exec_cmd("caelestia record")) -- Record screen
    hl.bind("SUPER+SHIFT+ALT + R", hl.dsp.exec_cmd("caelestia record -r")) -- Record region
    hl.bind("SUPER+SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a")) -- Colour picker

    -- Volume
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    hl.bind("SUPER+SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    hl.bind(
        "XF86AudioRaiseVolume",
        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"),
        { locked = true, repeating = true }
    )
    hl.bind(
        "XF86AudioLowerVolume",
        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"),
        { locked = true, repeating = true }
    )

    -- Sleep
    hl.bind("SUPER+SHIFT+ALT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"))

    -- Clipboard and emoji picker
    hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
    hl.bind("SUPER+ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))
    hl.bind("SUPER + Period", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))
    hl.bind(
        "CTRL+SHIFT+ALT + V",
        hl.dsp.exec_cmd('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'),
        { locked = true }
    )

    -- Testing
    hl.bind(
        "SUPER+ALT + f12",
        hl.dsp.exec_cmd(
            "notify-send -u low -i dialog-information-symbolic 'Test notification' "
            .. [["Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!"]]
            .. " -a 'Shell' -A \"Test1=I got it!\" -A \"Test2=Another action\""
        )
    )

    -- Misc
    hl.bind("CTRL+SUPER+ALT + Q", hl.dsp.exec_cmd("hyprctl kill"))
    hl.bind("CTRL+SHIFT + X", hl.dsp.exec_cmd("equibop --toggle-mic"))
    hl.bind("SUPER + Tab", swap_with_next_monitor())
    hl.bind("CTRL+SUPER+ALT + M", hl.dsp.exit())

end)

-- `submap = global` had no matching reset in the old config, so it was
-- effectively the permanent active map — the old .conf entered it via
-- `exec = hyprctl dispatch submap global`, which (unlike `exec-once`) ran
-- on every parse, including the first one. `config.reloaded` only fires on
-- later reloads, not on that first parse, so `hyprland.start` covers boot.
local function enter_global_submap()
    hl.dispatch(hl.dsp.submap("global"))
end
hl.on("hyprland.start", enter_global_submap)
hl.on("config.reloaded", enter_global_submap)
