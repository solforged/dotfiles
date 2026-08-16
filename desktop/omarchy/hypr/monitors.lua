local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- acer x32 x2: native 4k at its maximum 240 hz, with variable refresh rate always on.
hl.monitor({
  output = "DP-1",
  mode = "3840x2160@240",
  position = "auto",
  scale = omarchy_monitor_scale,
  vrr = 1,
})
