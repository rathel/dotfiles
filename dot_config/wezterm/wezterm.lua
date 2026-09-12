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

-- Forest Green
local forest = {
  background = "#192324",
  background_alt = "#213230",
  surface = "#29463d",
  selection = "#345b4b",
  border = "#43725d",
  accent = "#5a8e73",
  foreground = "#dce8e1",
  bright = "#f3f7f5",
  muted = "#a9beb3",
  info = "#6f9a91",
  warning = "#b9a66c",
  error = "#b97872",
}

config.colors = {
  foreground = forest.foreground,
  background = forest.background,
  cursor_bg = forest.accent,
  cursor_fg = forest.background,
  cursor_border = forest.accent,
  selection_fg = forest.bright,
  selection_bg = forest.selection,
  scrollbar_thumb = forest.border,
  split = forest.border,
  ansi = {
    forest.background_alt,
    forest.error,
    forest.accent,
    forest.warning,
    forest.info,
    forest.border,
    forest.info,
    forest.foreground,
  },
  brights = {
    forest.border,
    forest.error,
    forest.accent,
    forest.warning,
    forest.info,
    forest.accent,
    forest.info,
    forest.bright,
  },
  indexed = {
    [16] = forest.warning,
    [17] = forest.error,
  },
  tab_bar = {
    background = forest.background,
    active_tab = {
      bg_color = forest.accent,
      fg_color = forest.background,
    },
    inactive_tab = {
      bg_color = forest.surface,
      fg_color = forest.foreground,
    },
    inactive_tab_hover = {
      bg_color = forest.selection,
      fg_color = forest.bright,
    },
    new_tab = {
      bg_color = forest.surface,
      fg_color = forest.foreground,
    },
    new_tab_hover = {
      bg_color = forest.selection,
      fg_color = forest.bright,
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
  local background = forest.surface
  local foreground = forest.foreground

  if tab.is_active then
    background = forest.accent
    foreground = forest.background
  elseif hover then
    background = forest.selection
    foreground = forest.bright
  end

  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  return {
    { Background = { Color = forest.background } },
    { Foreground = { Color = background } },
    { Text = left_arrow },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. title .. " " },
    { Background = { Color = forest.background } },
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
