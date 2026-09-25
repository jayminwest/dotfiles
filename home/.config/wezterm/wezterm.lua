local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- System-wide theme. Single source of truth: ~/.config/theme-mode ("dark" |
-- "light"). The `theme` shell command and Ctrl+Shift+T flip it; WezTerm watches
-- the file and reloads, nvim polls it, yazi reads its symlinked theme.toml.
local home = os.getenv("HOME")
local mode_file = home .. "/.config/theme-mode"

local function read_mode()
  local f = io.open(mode_file, "r")
  if not f then
    return "dark"
  end
  local m = (f:read("l") or ""):gsub("%s+", "")
  f:close()
  if m == "light" then
    return "light"
  end
  return "dark"
end

local themes = {
  dark = { color_scheme = "Kanagawa (Gogh)", opacity = 0.60 },
  light = { color_scheme = "Everforest Light (Gogh)", opacity = 1.00 },
}

local theme = themes[read_mode()]
config.color_scheme = theme.color_scheme
config.window_background_opacity = theme.opacity

config.font = wezterm.font("BlexMono Nerd Font")
config.font_size = 13.0
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = false
config.window_decorations = "RESIZE"

-- Reload when the mode file changes (flipped by the `theme` toggle script), so
-- color_scheme + opacity above are re-evaluated.
wezterm.add_to_config_reload_watch_list(mode_file)

local toggle = home .. "/.dotfiles/home/.config/theme/toggle"
wezterm.on("toggle-theme", function(_, _)
  wezterm.run_child_process({ toggle })
  -- the watch list above triggers a reload once the mode file is rewritten.
end)

config.keys = {
  { key = "T", mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-theme") },
  { key = "H", mods = "CTRL|SHIFT", action = wezterm.action.SplitPane({ direction = "Left" }) },
  { key = "L", mods = "CTRL|SHIFT", action = wezterm.action.SplitPane({ direction = "Right" }) },
}

return config
