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

-- Catppuccin Mocha
local mocha = {
  background = "#1e1e2e",
  background_alt = "#181825",
  surface = "#313244",
  selection = "#45475a",
  border = "#585b70",
  accent = "#89b4fa",
  foreground = "#cdd6f4",
  bright = "#bac2de",
  muted = "#6c7086",
  info = "#74c7ec",
  warning = "#f9e2af",
  error = "#f38ba8",
  green = "#a6e3a1",
  magenta = "#cba6f7",
  orange = "#fab387",
}

config.colors = {
  foreground = mocha.foreground,
  background = mocha.background,
  cursor_bg = mocha.accent,
  cursor_fg = mocha.background,
  cursor_border = mocha.accent,
  selection_fg = mocha.bright,
  selection_bg = mocha.selection,
  scrollbar_thumb = mocha.border,
  split = mocha.border,
  ansi = {
    mocha.background_alt,
    mocha.error,
    mocha.green,
    mocha.warning,
    mocha.accent,
    mocha.magenta,
    mocha.info,
    mocha.foreground,
  },
  brights = {
    mocha.border,
    mocha.error,
    mocha.green,
    mocha.orange,
    mocha.accent,
    mocha.magenta,
    mocha.info,
    mocha.bright,
  },
  indexed = {
    [16] = mocha.warning,
    [17] = mocha.error,
  },
  tab_bar = {
    background = mocha.background,
    active_tab = {
      bg_color = mocha.accent,
      fg_color = mocha.background,
    },
    inactive_tab = {
      bg_color = mocha.surface,
      fg_color = mocha.foreground,
    },
    inactive_tab_hover = {
      bg_color = mocha.selection,
      fg_color = mocha.bright,
    },
    new_tab = {
      bg_color = mocha.surface,
      fg_color = mocha.foreground,
    },
    new_tab_hover = {
      bg_color = mocha.selection,
      fg_color = mocha.bright,
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
  local background = mocha.surface
  local foreground = mocha.foreground

  if tab.is_active then
    background = mocha.accent
    foreground = mocha.background
  elseif hover then
    background = mocha.selection
    foreground = mocha.bright
  end

  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  return {
    { Background = { Color = mocha.background } },
    { Foreground = { Color = background } },
    { Text = left_arrow },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. title .. " " },
    { Background = { Color = mocha.background } },
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
