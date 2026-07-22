local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("IosevkaTerm Nerd Font")
config.font_size = 12.0

-- UI / behavior
config.window_decorations = "RESIZE"
config.front_end = "OpenGL"
config.window_background_opacity = 1.0
config.window_padding = {
  left = "10pt",
  right = "10pt",
  top = "10pt",
  bottom = "10pt",
}
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 0,
  fade_out_duration_ms = 0,
}
config.scrollback_lines = 10000
config.window_close_confirmation = "AlwaysPrompt"

-- Cursor
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0

-- Catppuccin Mocha Verdant
config.colors = {
  foreground = "#c9dccb",
  background = "#07110d",
  cursor_bg = "#a6e3a1",
  cursor_fg = "#07110d",
  cursor_border = "#a6e3a1",
  selection_fg = "#e4f1e5",
  selection_bg = "#1b3a2d",
  scrollbar_thumb = "#486052",
  split = "#486052",
  ansi = {
    "#0b1812",
    "#e88a9c",
    "#8fd694",
    "#dccb88",
    "#7fb7a7",
    "#b79ad8",
    "#79c9b7",
    "#b8c9ba",
  },
  brights = {
    "#486052",
    "#f38ba8",
    "#a6e3a1",
    "#f9e2af",
    "#89dceb",
    "#cba6f7",
    "#94e2d5",
    "#e4f1e5",
  },
  indexed = {
    [16] = "#fab387",
    [17] = "#f5a97f",
  },
  tab_bar = {
    background = "#0b1812",
    active_tab = {
      bg_color = "#a6e3a1",
      fg_color = "#07110d",
    },
    inactive_tab = {
      bg_color = "#12271e",
      fg_color = "#c9dccb",
    },
    inactive_tab_hover = {
      bg_color = "#1b3a2d",
      fg_color = "#e4f1e5",
    },
    new_tab = {
      bg_color = "#12271e",
      fg_color = "#c9dccb",
    },
    new_tab_hover = {
      bg_color = "#1b3a2d",
      fg_color = "#e4f1e5",
    },
  },
}

-- Top powerline tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false

local left_arrow = wezterm.nerdfonts.pl_right_hard_divider
local right_arrow = wezterm.nerdfonts.pl_left_hard_divider
wezterm.on("format-tab-title", function(tab, _, _, _, hover)
  local background = "#12271e"
  local foreground = "#c9dccb"

  if tab.is_active then
    background = "#a6e3a1"
    foreground = "#07110d"
  elseif hover then
    background = "#1b3a2d"
    foreground = "#e4f1e5"
  end

  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  return {
    { Background = { Color = "#0b1812" } },
    { Foreground = { Color = background } },
    { Text = left_arrow },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. title .. " " },
    { Background = { Color = "#0b1812" } },
    { Foreground = { Color = background } },
    { Text = right_arrow },
  }
end)

-- Handy keybinds
config.keys = {
  {
    key = "Enter",
    mods = "CTRL|SHIFT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "t",
    mods = "CTRL|SHIFT",
    action = act.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "w",
    mods = "CTRL|SHIFT",
    action = act.CloseCurrentPane({ confirm = false }),
  },
  {
    key = "]",
    mods = "CTRL|SHIFT",
    action = act.ActivateTabRelative(1),
  },
  {
    key = "[",
    mods = "CTRL|SHIFT",
    action = act.ActivateTabRelative(-1),
  },
}

return config
