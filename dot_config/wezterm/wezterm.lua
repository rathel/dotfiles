local wezterm = require 'wezterm'
local config = wezterm.config_builder()
-- Basic configuration
config.font = wezterm.font 'Iosevka Nerd Font'
config.color_scheme = 'Catppuccin Mocha'
config.window_decorations = "RESIZE"
-- Make the terminal background slightly transparent (0.0 = fully transparent, 1.0 = opaque)
config.window_background_opacity = 0.9
return config