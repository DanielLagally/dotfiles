local vars = require("_upstream.variables")

vars.cursorTheme = "rose-pine-hyprcursor"
vars.cursorSize = 32

-- Real S3 suspend hard-hangs on resume on this machine (black screen, no
-- keyboard LEDs, hard power cycle required) - cause still unknown, see the
-- `suspend-debug` branch of nixos-config. suspend-then-hibernate begins with
-- an S3 phase, so it hits the same hang. Hibernate works reliably, so route
-- the sleep gesture straight to it.
vars.sleepGestureCmd = "systemctl hibernate"

return vars
