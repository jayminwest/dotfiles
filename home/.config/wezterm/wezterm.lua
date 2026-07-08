local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Kanagawa (Gogh)"
config.font = wezterm.font("BlexMono Nerd Font")
config.font_size = 13.0
config.window_background_opacity = 0.60
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Ctrl+Shift+Y toggles between the two keeper schemes in this window only;
-- config.color_scheme above stays the default.
local schemes = {
  "Kanagawa (Gogh)",
  "zenbones_dark",
}
local idx = 0
wezterm.on("cycle-scheme", function(window, pane)
  idx = idx % #schemes + 1
  window:set_config_overrides({ color_scheme = schemes[idx] })
  window:set_right_status(schemes[idx] .. "  ")
end)
config.keys = {
  { key = "Y", mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("cycle-scheme") },
}

return config
