local wezterm = require("wezterm")
local config = wezterm.config_builder()
-- Basic configuration
config.font = wezterm.font("Iosevka Nerd Font")
config.font_size = 11.5
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "RESIZE"
config.front_end = "OpenGL"
config.window_background_opacity = 1.0
return config

