local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("Monaspace Neon NF", { weight = "Bold" })
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

-- TokyoNight Night
local tokyo = {
  background = "#1a1b26",
  background_alt = "#16161e",
  surface = "#24283b",
  selection = "#33467c",
  border = "#414868",
  accent = "#7aa2f7",
  foreground = "#c0caf5",
  bright = "#e0e6ff",
  muted = "#565f89",
  info = "#7dcfff",
  warning = "#e0af68",
  error = "#f7768e",
  green = "#9ece6a",
  magenta = "#bb9af7",
  orange = "#ff9e64",
}

config.colors = {
  foreground = tokyo.foreground,
  background = tokyo.background,
  cursor_bg = tokyo.accent,
  cursor_fg = tokyo.background,
  cursor_border = tokyo.accent,
  selection_fg = tokyo.bright,
  selection_bg = tokyo.selection,
  scrollbar_thumb = tokyo.border,
  split = tokyo.border,
  ansi = {
    tokyo.background_alt,
    tokyo.error,
    tokyo.green,
    tokyo.warning,
    tokyo.accent,
    tokyo.magenta,
    tokyo.info,
    tokyo.foreground,
  },
  brights = {
    tokyo.border,
    tokyo.error,
    tokyo.green,
    tokyo.orange,
    tokyo.accent,
    tokyo.magenta,
    tokyo.info,
    tokyo.bright,
  },
  indexed = {
    [16] = tokyo.warning,
    [17] = tokyo.error,
  },
  tab_bar = {
    background = tokyo.background,
    active_tab = {
      bg_color = tokyo.accent,
      fg_color = tokyo.background,
    },
    inactive_tab = {
      bg_color = tokyo.surface,
      fg_color = tokyo.foreground,
    },
    inactive_tab_hover = {
      bg_color = tokyo.selection,
      fg_color = tokyo.bright,
    },
    new_tab = {
      bg_color = tokyo.surface,
      fg_color = tokyo.foreground,
    },
    new_tab_hover = {
      bg_color = tokyo.selection,
      fg_color = tokyo.bright,
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
  local background = tokyo.surface
  local foreground = tokyo.foreground

  if tab.is_active then
    background = tokyo.accent
    foreground = tokyo.background
  elseif hover then
    background = tokyo.selection
    foreground = tokyo.bright
  end

  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  return {
    { Background = { Color = tokyo.background } },
    { Foreground = { Color = background } },
    { Text = left_arrow },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. title .. " " },
    { Background = { Color = tokyo.background } },
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
