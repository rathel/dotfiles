local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("IosevkaTerm Nerd Font", { weight = "Bold" })
config.font_size = 13.0

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

-- Nord - Polar Night
local nord = {
  nord0 = "#2e3440",
  nord1 = "#3b4252",
  nord2 = "#434c5e",
  nord3 = "#4c566a",
  nord4 = "#d8dee9",
  nord5 = "#e5e9f0",
  nord6 = "#eceff4",
  nord7 = "#8fbcbb",
  nord8 = "#88c0d0",
  nord9 = "#81a1c1",
  nord10 = "#5e81ac",
  nord11 = "#bf616a",
  nord12 = "#d08770",
  nord13 = "#ebcb8b",
  nord14 = "#a3be8c",
  nord15 = "#b48ead",
}

config.colors = {
  foreground = nord.nord4,
  background = nord.nord0,
  cursor_bg = nord.nord8,
  cursor_fg = nord.nord0,
  cursor_border = nord.nord8,
  selection_fg = nord.nord6,
  selection_bg = nord.nord2,
  scrollbar_thumb = nord.nord3,
  split = nord.nord3,
  ansi = {
    nord.nord1,
    nord.nord11,
    nord.nord14,
    nord.nord13,
    nord.nord9,
    nord.nord15,
    nord.nord8,
    nord.nord5,
  },
  brights = {
    nord.nord3,
    nord.nord11,
    nord.nord14,
    nord.nord13,
    nord.nord9,
    nord.nord15,
    nord.nord7,
    nord.nord6,
  },
  indexed = {
    [16] = nord.nord12,
    [17] = nord.nord11,
  },
  tab_bar = {
    background = nord.nord0,
    active_tab = {
      bg_color = nord.nord8,
      fg_color = nord.nord0,
    },
    inactive_tab = {
      bg_color = nord.nord1,
      fg_color = nord.nord4,
    },
    inactive_tab_hover = {
      bg_color = nord.nord2,
      fg_color = nord.nord6,
    },
    new_tab = {
      bg_color = nord.nord1,
      fg_color = nord.nord4,
    },
    new_tab_hover = {
      bg_color = nord.nord2,
      fg_color = nord.nord6,
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
  local background = nord.nord1
  local foreground = nord.nord4

  if tab.is_active then
    background = nord.nord8
    foreground = nord.nord0
  elseif hover then
    background = nord.nord2
    foreground = nord.nord6
  end

  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  return {
    { Background = { Color = nord.nord0 } },
    { Foreground = { Color = background } },
    { Text = left_arrow },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. title .. " " },
    { Background = { Color = nord.nord0 } },
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
