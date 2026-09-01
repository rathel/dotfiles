# Hyprland Lua configuration: capabilities and API research

> Researched **2026-08-31** against Hyprland **0.56.0** and upstream `main` at commit
> `86c24e2e079aa62214421c76f01b603fc8178125`. The wiki is versioned; select the
> documentation matching `hyprctl version` rather than assuming `main` is compatible.

## Executive summary

Hyprland 0.55 introduced `~/.config/hypr/hyprland.lua` and deprecated the old
Hyprlang `hyprland.conf` format. Lua is not merely alternate syntax for static
settings. It turns the compositor configuration into a typed, event-driven
scripting environment. In addition to configuring every normal Hyprland option,
Lua can:

- generate configuration with variables, functions, loops, conditions, and modules;
- query live windows, workspaces, monitors, layer surfaces, the cursor, config values,
  loaded plugins, key state, and current submap;
- react to compositor events;
- execute arbitrary logic from key, mouse, switch, and gesture callbacks;
- create one-shot and repeating timers;
- dispatch window, workspace, group, cursor, monitor, and process actions directly;
- add, remove, enable, and disable keybinds and named rules at runtime;
- create fully custom tiling layouts in Lua;
- create and mutate Hyprland's built-in notifications;
- communicate with plugin-provided Lua functions and plugin events;
- use the Lua 5.5 standard library, which also means it can read files, run commands,
  load modules, and execute arbitrary code as the user.

This makes many tasks possible without a shell script, IPC client, or C++ plugin.
Plugins remain necessary for compositor internals that Hyprland does not expose to
Lua.

---

## 1. Status, loading, and migration

### Version status

- Lua configuration arrived in **0.55**.
- Upstream describes Hyprlang as deprecated and no longer receiving new config
  features.
- In 0.56, legacy `hyprland.conf` is still present as a fallback.
- At startup, Hyprland chooses `hyprland.lua` when it exists; otherwise it loads
  `hyprland.conf`. The choice is made for that config context, not continuously.
- `hyprctl reload full-reset` recreates the config context and can switch between
  Lua and Hyprlang. Ordinary `hyprctl reload` should normally be used.
- Other Hypr ecosystem applications do **not** automatically use Lua; the 0.55
  announcement says they continue using Hyprlang where appropriate.

### File locations

```text
$XDG_CONFIG_HOME/hypr/hyprland.lua
~/.config/hypr/hyprland.lua     # usual path
```

A different file can be selected at launch:

```sh
start-hyprland -- --config ~/my-rice/hyprland.lua
```

`HYPRLAND_CONFIG` can also name the config path, although startup environment
placement matters.

### Reload behavior

Hyprland watches the config and loaded Lua files and reloads when they change.
Manual reload:

```sh
hyprctl reload
```

A syntax error can reject the reload, preserving the prior usable configuration.
If an error occurs before any binds are registered, Hyprland provides emergency
binds: `SUPER+Q` for a terminal, `SUPER+R` for hyprlauncher, and `SUPER+M` to exit.

### Practical migration approach

1. Keep a working TTY available and retain a backup of `hyprland.conf`.
2. Copy upstream's [`example/hyprland.lua`](https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua).
3. Move one concern at a time into modules: monitors, environment, appearance,
   input, binds, rules, autostart, and scripts.
4. Use the 0.54 wiki to interpret old syntax and the versioned 0.56 wiki for the
   corresponding Lua API.
5. Validate with `hyprctl configerrors`, `hyprctl reload`, and the REPL.
6. Treat third-party converters as a starting point, not proof of semantic
   equivalence, especially for old bind flags, rules, and plugin settings.

---

## 2. Lua language and module system

Hyprland currently links against **Lua 5.5** and loads the standard libraries.
Normal Lua facilities are available:

- local/global variables and functions;
- strings, tables, metatables, iteration, loops, and conditionals;
- `math`, `string`, `table`, `utf8`, `os`, `io`, `package`, and other standard
  facilities;
- `os.getenv()` for existing environment variables;
- `pcall()`/`xpcall()` for guarded execution;
- Lua modules and third-party Lua code found through `package.path`/searchers.

Example of generated binds:

```lua
local mod = "SUPER"
for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key,
          hl.dsp.window.move({ workspace = i }))
end
```

### `require()` enhancements

Hyprland wraps Lua's `require()` with config-aware behavior:

```lua
require("monitors")                 -- relative module
require("rice.binds")               -- dots preferred as separators
require("./lua/*")                  -- every Lua file in a directory
require("./lua/*/loadme")           -- matching module in subdirectories
require("/absolute/path/module")
```

Important behavior:

- Relative paths start from the directory containing `hyprland.lua`.
- Required files are watched for reloads.
- Each Hyprland-managed `require()` receives a protected scope, so a runtime error
  in one required config file does not stop other required files.
- A missing module still throws in the caller. Use `pcall(require, "optional")`
  for optional modules.
- Original Lua semantics remain available as `__require`; setting
  `require = __require` may help third-party modules that dislike scope separation.

Recommended structure:

```text
~/.config/hypr/
├── hyprland.lua
└── lua/
    ├── monitors.lua
    ├── appearance.lua
    ├── input.lua
    ├── binds.lua
    ├── rules.lua
    ├── events.lua
    └── layouts.lua
```

```lua
-- hyprland.lua
require("lua.monitors")
require("lua.appearance")
require("lua.input")
require("lua.binds")
require("lua.rules")
require("lua.events")
require("lua.layouts")
```

---

## 3. Static configuration—everything the old config could express

### General options: `hl.config()`

Set nested categories:

```lua
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = { top = 20, right = 10, bottom = 20, left = 10 },
    layout = "dwindle",
    col = {
      active_border = {
        colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
        angle = 45,
      },
    },
  },
  decoration = {
    rounding = 10,
    blur = { enabled = true, size = 8, passes = 2 },
  },
})
```

Or set dotted keys:

```lua
hl.config({ ["general.border_size"] = 2 })
```

Calls are incremental, and the latest assignment wins. The API covers the normal
configuration categories:

- `general`: gaps, borders, layout, resizing, snapping, tearing;
- `decoration`: opacity, rounding, blur variants, shadow, glow, wobble, motion
  blur, dimming, and screen shader;
- `animations`;
- `input`: keyboards, pointers, touchpads, tablets, touchscreens, virtual
  keyboards;
- `gestures` defaults and workspace-swipe behavior;
- `group` and groupbar appearance/behavior;
- `misc` compositor behavior, VRR, swallowing, session-lock behavior;
- `layout`, plus `dwindle`, `master`, and `scrolling` layout-specific settings;
- `binds` behavior;
- `xwayland`, `opengl`, `render`, and color-management controls;
- `cursor`, including zoom and hardware/software cursor behavior;
- `ecosystem` permissions/update behavior;
- `quirks`, `input_capture`, `debug`, and `experimental`.

The exact option set is large and release-sensitive. The authoritative full list
is the versioned **Config options** page and the installed LuaLS stub.

### Supported value types

Lua adds useful typed representations:

- booleans, integers, floats, and strings;
- vectors: `{ x, y }` or `{ x = ..., y = ... }` depending on the API;
- CSS-like gaps: integer or `{ top=?, right=?, bottom=?, left=? }`;
- colors: `"#RRGGBB"`, `"#RGBA"`, `"rgb(...)"`, `"rgba(...)"`, or legacy ARGB;
- gradients: color string or
  `{ colors = { color1, color2, ... }, angle = number }`;
- font weights as numbers or names;
- selectors represented by strings, IDs, or live Hyprland objects.

### Monitors: `hl.monitor()`

Lua can declaratively configure output matching, disablement, modes, scale,
transform, virtual position, mirroring, bit depth, VRR, ICC profile, reserved
areas, wide gamut, HDR support, color-management preset, transfer function, and
luminance/SDR mapping.

```lua
hl.monitor({
  output = "DP-1",
  mode = "2560x1440@165",
  position = "0x0",
  scale = 1,
  vrr = 1,
  bitdepth = 10,
  cm = "wide",
})

-- fallback for all unmatched outputs
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
```

### Environment: `hl.env()`

```lua
hl.env("XCURSOR_SIZE", "24")
hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent.socket")
```

A source-exposed third boolean argument requests importing the variable into
systemd/D-Bus activation environments:

```lua
hl.env("MY_VARIABLE", "value", true)
```

UWSM users should generally put environment values in UWSM's environment files
instead. Environment changes cannot retroactively alter already-running clients.

### Per-device input: `hl.device()`

Override applicable `input` settings by the exact name from `hyprctl devices`:

```lua
hl.device({
  name = "my-epic-mouse",
  sensitivity = -0.5,
  natural_scroll = true,
  tags = "gaming,pointer",
})
```

This can configure keyboard layouts/options, pointer acceleration and scrolling,
click/tap behavior, tablet regions/output, touch transforms, device enablement,
whether a keyboard participates in binds, and tags used by per-device binds.

### Animations and curves

Define cubic Bézier and physical spring curves:

```lua
hl.curve("quick", {
  type = "bezier",
  points = { { 0.15, 0 }, { 0.1, 1 } },
})

hl.curve("bouncy", {
  type = "spring",
  mass = 1,
  stiffness = 70,
  damping = 10,
})

hl.animation({
  leaf = "windowsIn",
  enabled = true,
  speed = 4.1,       -- deciseconds
  spring = "bouncy",
  style = "popin 87%",
})
```

Animation leaves include global, windows/open/close/move, layers/open/close,
multiple fade branches, border/shadow/glow angles, workspaces and special
workspaces, cursor zoom, and monitor-added animation. Available styles depend on
the leaf (slide, popin, gnomed, fade, vertical variants, angle loop, etc.).

### Window, layer, and workspace rules

Lua uses structured rules instead of comma-packed Hyprlang strings.

#### Window rules: `hl.window_rule()`

Match on class, title, initial class/title, content type, focused/floating/grouped/
modal/pinned/fullscreen/XWayland state, fullscreen modes, tag, workspace, or XDG
tag.

Static open-time effects include:

- center, float/tile, pseudo, pin;
- maximize/fullscreen/fullscreen state;
- initial focus suppression;
- target workspace or monitor;
- floating move/size expressions;
- group policy;
- content type and scrolling width;
- temporary close prevention;
- suppression of client events.

Dynamic effects include:

- animation, opacity, border color/size, rounding/power;
- min/max/persistent size and aspect ratio;
- blur, shadow, glow, dimming, decoration, wobble, nearest-neighbor filtering;
- focus and input policies;
- idle inhibition, screen-share hiding, shortcut inhibition;
- VRR, tearing/immediate mode, AutoHDR, tonemapping, RGBX, xray;
- XDG drag, scroll-factor, pointer confinement, render-unfocused behavior;
- dynamic tags.

```lua
local firefoxRule = hl.window_rule({
  name = "firefox-opacity",
  match = { class = "firefox" },
  opacity = "1.0 override 0.85 override",
  no_blur = true,
})

firefoxRule:set_enabled(false)
firefoxRule:set_enabled(true)
print(firefoxRule:is_enabled())
```

Named window rules return a handle that can be enabled/disabled dynamically.
Static effects are only applied at window creation; use events plus dispatchers
for later title/class changes.

#### Layer rules: `hl.layer_rule()`

Match layer-shell namespaces and control animation, blur and popup blur,
`ignore_alpha`, xray, dimming, screen-share hiding, reservation order, and
whether/how a layer appears above the lock screen. Named rules also return an
enable/disable handle.

#### Workspace rules: `hl.workspace_rule()`

Select workspaces and control monitor binding, default workspace, persistent
lifetime, default name, creation command, animation, gaps, borders, shadow,
rounding, decoration, per-workspace layout, and layout-specific options.

```lua
local coding = hl.workspace_rule({
  workspace = "name:coding",
  monitor = "DP-1",
  persistent = true,
  layout = "scrolling",
  gaps_in = 4,
})

coding:set_enabled(false)
```

This enables per-workspace use of built-in or Lua layouts.

### Permissions: `hl.permission()`

With `hyprland-guiutils` installed and
`ecosystem.enforce_permissions = true`, set `allow`, `ask`, or `deny` rules for:

- `screencopy`;
- `plugin` loading;
- `keyboard` devices;
- `cursorpos` access;
- `input-capture`.

```lua
hl.permission({
  binary = "/usr/bin/grim",
  type = "screencopy",
  mode = "allow",
})
```

Permission config deliberately requires a Hyprland restart and does not hot
reload. Rules are regex-based; narrowly scope them, especially plugin access.

---

## 4. Key, mouse, switch, and submap programming

### `hl.bind(keys, action, options)`

The action may be an `hl.dsp.*` dispatcher or any Lua function.

```lua
hl.bind("SUPER + Return", hl.dsp.exec_cmd("foot"), {
  description = "Open terminal",
})

hl.bind("SUPER + X", function()
  local w = hl.get_active_window()
  if w and w.class == "foot" then
    hl.dispatch(hl.dsp.window.float({ action = "set" }))
  else
    hl.notification.create({ text = "Not a terminal", timeout = 1500 })
  end
end)
```

Key specifications support:

- XKB keysyms and left/right modifiers;
- raw keycodes through `code:N`;
- modifier-only chords;
- mouse buttons such as `mouse:272`;
- wheel events such as `mouse_up`/`mouse_down`;
- switches (`switch:name`, `switch:on:name`, `switch:off:name`);
- a submap-only `catchall` bind.

Bind options:

| Option | Capability |
|---|---|
| `locked` | run under an input inhibitor/lock screen |
| `release` | trigger on release |
| `click`, `drag` | distinguish click/release from drag threshold |
| `long_press` | trigger after a long press |
| `repeating` | repeat while held |
| `non_consuming` | also pass event to client |
| `auto_consuming` | pass event when handler reports failure |
| `mouse` | interactive mouse bind |
| `transparent` | cannot be shadowed |
| `ignore_mods` | ignore extra modifiers |
| `dont_inhibit` | bypass application shortcut inhibition |
| `submap_universal` | active in every submap |
| `description`/`desc` | discoverable bind description |
| `device` | inclusive/exclusive device names or tags |
| `allow_input_capture` | process even during client input capture |

Lua bind callbacks can perform multiple actions and conditional consumption.
Return `{ ok = false }` from an `auto_consuming` callback to pass the key through.
Dispatcher constructors evaluate immediately at config/bind creation, so runtime
conditions must be inside the callback.

`hl.bind()` returns an `HL.Keybind` handle with:

- methods `set_enabled(bool)`, `is_enabled()`, `remove()`, and `unbind()`;
- metadata/flags including `enabled`, `description`, `display_key`, `submap`,
  `handler`, `arg`, `modmask`, `key`, `keycode`, bind flags, and device list.

`hl.unbind("EXACT + CASE")` removes prior matches; source also supports
`hl.unbind("all")` to clear all binds. Use the latter with extreme care.

### Submaps

`hl.define_submap()` creates modal/nested key maps, useful for resize modes,
leader-key menus, temporary input suppression, and nested command palettes.

```lua
hl.bind("SUPER + R", hl.dsp.submap("resize"))

hl.define_submap("resize", "reset", function()
  hl.bind("H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }),
          { repeating = true })
  hl.bind("L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }),
          { repeating = true })
  hl.bind("escape", hl.dsp.submap("reset"))
end)
```

The optional reset target automatically changes submap after a bind dispatch.
`hl.get_current_submap()` queries the current mode, and `keybinds.submap` reports
changes.

---

## 5. Dispatcher/action API

A dispatcher constructor describes an action; it does not run it by itself.
Pass it directly to `hl.bind()`, or execute it with `hl.dispatch()`:

```lua
hl.dispatch(hl.dsp.window.close())
```

### General dispatchers

| API | What it can do |
|---|---|
| `hl.dsp.exec_cmd(cmd, rules?)` | shell command, optionally applying rules to its window |
| `hl.dsp.exec_raw(cmd)` | raw process execution without `sh -c` |
| `hl.dsp.focus({...})` | focus by direction, monitor, workspace, window, urgent/last |
| `hl.dsp.exit()` | exit Hyprland (`hyprshutdown` is preferred) |
| `hl.dsp.submap(name)` | change keybind submap |
| `hl.dsp.pass({window?})` | pass current shortcut to a window |
| `hl.dsp.send_shortcut({...})` | synthesize a shortcut for a window |
| `hl.dsp.send_key_state({...})` | synthesize key up/down state |
| `hl.dsp.layout(message)` | send a message to the active layout |
| `hl.dsp.dpms({...})` | enable/disable/toggle output power |
| `hl.dsp.event(string)` | emit a socket2 event |
| `hl.dsp.global(string)` | invoke a D-Bus global shortcut |
| `hl.dsp.force_idle(seconds)` | manipulate idle timers |
| `hl.dsp.no_op()` | intentional no-op/conditional bind result |
| `hl.dsp.force_renderer_reload()` | reload renderer on every monitor |
| `hl.dsp.release_input_capture()` | release an active input-capture session |

### Window dispatchers: `hl.dsp.window.*`

- `close`, `kill`, and `signal`;
- `float`, `pseudo`, `pin`, `fullscreen`, and precise `fullscreen_state`;
- `move` by direction, workspace, monitor, absolute/relative coordinates, or
  into/out of groups;
- `resize` interactively or by coordinates;
- `swap` by direction, target, next, or previous;
- `center`, `cycle_next`, and `bring_to_top`;
- `tag` and `clear_tags`;
- `toggle_swallow`;
- `alter_zorder`;
- `set_prop` for dynamic window-rule properties;
- `deny_from_group`;
- `drag` and interactive `resize` for mouse binds.

### Workspace dispatchers: `hl.dsp.workspace.*`

- `change_id`;
- `rename`;
- `move` to a monitor;
- `swap_monitors`;
- `toggle_special` scratchpads.

### Group dispatchers: `hl.dsp.group.*`

- create/toggle group;
- select next/previous/indexed member;
- reorder members;
- lock a group or the active group.

### Cursor dispatchers: `hl.dsp.cursor.*`

- move to global coordinates;
- move to a selected corner of a window.

Built-in layouts additionally accept layout-specific messages through
`hl.dsp.layout(...)` (split ratios and directions in dwindle, master orientation
and counts, scrolling column operations, and so on).

---

## 6. Querying live compositor state

### Top-level query and utility functions

| Function | Result/use |
|---|---|
| `hl.get_config("section.option")` | typed current config value, plus possible error |
| `hl.get_windows(filters?)` | mapped windows; filter exact class/title, tag, mapped/floating, monitor/workspace |
| `hl.get_window(selector)` | one selected window |
| `hl.get_active_window()` / `hl.get_urgent_window()` | focused or urgent window |
| `hl.get_last_window()` | previous mapped window in focus history |
| `hl.get_workspaces()` / `hl.get_workspace(selector)` | all or selected workspace |
| `hl.get_active_workspace(monitor?)` | regular active workspace |
| `hl.get_active_special_workspace(monitor?)` | active scratchpad |
| `hl.get_last_workspace(monitor?)` | previous workspace |
| `hl.get_workspace_windows(selector)` | mapped windows on workspace |
| `hl.get_monitors({all?})` / `hl.get_monitor(selector)` | active/all or selected monitor |
| `hl.get_active_monitor()` | focused monitor |
| `hl.get_monitor_at(x,y)` | monitor containing coordinates |
| `hl.get_monitor_at_cursor()` | monitor under pointer |
| `hl.get_layers(filters?)` | layer surfaces, filter by monitor/namespace |
| `hl.get_cursor_pos()` | `{x, y}` |
| `hl.get_current_submap()` | submap string |
| `hl.get_loaded_plugins()` | plugin metadata list |
| `hl.is_key_down(keycode_or_keysym)` | current key state |
| `hl.version()` | Hyprland version string |
| `hl.exec_cmd(cmd, rules?)` | asynchronous command launch |
| `hl.exec_scheduled_prop_refresh_immediately()` | force pending config/device/workspace refresh |
| `hl.clear_crashed_lockscreen()` | recover only a crashed lock with no live/denied lock client |

Selectors may be strings/IDs or returned `HL.Window`, `HL.Workspace`, and
`HL.Monitor` objects. Window selectors support PID, stable ID, address, regex
class/title/initial values/tags, active/floating/tiled. Workspace selectors
support IDs, names, special workspaces, previous workspace, relative searches,
and predicates. Monitor selectors support object, ID, output/description,
direction, and current monitor.

### Live objects

Objects compare by underlying compositor object, stringify usefully, and become
expired after their compositor entity disappears. Check for `nil` and avoid
assuming an old handle remains alive.

#### `HL.Window` readable fields

`address`, `mapped`, `hidden`, `visible`, `accepts_input`, `at`, `size`,
`workspace`, `floating`, `monitor`, `class`, `title`, `initial_class`,
`initial_title`, `pid`, `xwayland`, `pinned`, `pin_fullscreened`, `fullscreen`,
`fullscreen_client`, `allowed_over_fullscreen`, `fullscreen_handler`, `group`,
`tags`, `swallowing`, `focus_history_id`, `inhibiting_idle`, `xdg_tag`,
`xdg_description`, `content_type`, `stable_id`, layout-specific data, `active`,
and `tearing_hint`.

Layout-specific window data can identify master status/percentages or scrolling
column/index/width/members.

#### `HL.Workspace` fields and methods

Fields: `id`, `name`, `monitor`, window count, `visible`, `special`, `active`,
`has_urgent`, `fullscreen_mode`, `has_fullscreen`, `fullscreen_window`,
`is_persistent`, `is_empty`, `config_name`, `tiled_layout`, `last_window`, and
group count.

Methods: `get_windows()` and `get_groups()`.

#### `HL.Monitor` fields and methods

Fields: ID/name/description/serial, pixel and physical dimensions, refresh rate,
position, size, active regular/special workspace, scale, transform, DPMS,
enabled/focused/VRR/mirror state, mirrors, available modes, color-management
preset, and reserved area.

Methods: `set_workspace(selector)` and `set_special_workspace(selector)`.

#### `HL.LayerSurface` fields

`address`, geometry (`x`, `y`, `w`, `h`), `namespace`, `pid`, `monitor`, `mapped`,
layer level, keyboard interactivity, and above-fullscreen state.

#### `HL.Group` fields and methods

Fields: `locked`, `denied`, `size`, `current_index`, `current`, and `members`.
Methods: `add(window, index?)` and `remove(window_or_index)`.

---

## 7. Events and reactive automation

Register any number of callbacks with `hl.on()`:

```lua
local subscription = hl.on("window.active", function(w, reason)
  if w then
    print("Focused", w.class, w.title, reason)
  end
end)

subscription:is_active()
subscription:remove()
```

### Complete built-in event list

| Event | Callback parameters |
|---|---|
| `hyprland.start` | none |
| `hyprland.shutdown` | none |
| `window.bell` | window |
| `window.open` | window, after rules |
| `window.open_early` | window, before rules |
| `window.close` | window, possibly still animating |
| `window.destroy` | window at compositor removal |
| `window.kill` | force-killed window |
| `window.active` | window, integer focus reason |
| `window.urgent` | window |
| `window.title` | window |
| `window.class` | window |
| `window.pin` | window |
| `window.fullscreen` | window |
| `window.update_rules` | window |
| `window.move_to_workspace` | window, workspace |
| `layer.opened` | layer surface |
| `layer.closed` | layer surface |
| `monitor.added` | monitor |
| `monitor.removed` | monitor |
| `monitor.focused` | monitor |
| `monitor.layout_changed` | none |
| `workspace.active` | workspace |
| `workspace.special_active` | workspace or nil, monitor |
| `workspace.created` | workspace |
| `workspace.removed` | workspace |
| `workspace.move_to_monitor` | workspace, monitor |
| `config.reloaded` | none |
| `config.props_refreshed` | bool: scheduled vs forced immediately |
| `keybinds.submap` | submap name; empty means default |
| `screenshare.state` | active bool, type integer, name string |
| `input.keyboard.key` | XKB keycode, Unix/event timestamp, state 0/1/2 |

Plugins can add custom Lua-visible events with bool, integer, double, string,
window, workspace, layer-surface, and monitor arguments.

### Useful patterns

- autostart on `hyprland.start` and cleanup on `hyprland.shutdown`;
- apply a static-like action after a dynamic title change;
- update appearance according to active workspace/window/monitor;
- implement smart gaps or context-dependent keybind behavior;
- react to monitor hotplug and assign workspaces;
- display screenshare or urgent-window indicators;
- log or audit keyboard events and compositor state;
- dynamically enable/disable rules and binds.

Example: float a late title match and notify:

```lua
hl.on("window.title", function(w)
  if w and w.title:match("Picture.in.Picture") then
    hl.dispatch(hl.dsp.window.float({ window = w, action = "set" }))
    hl.dispatch(hl.dsp.window.pin({ window = w, action = "set" }))
  end
end)
```

Hyprland suppresses recursive re-entry of the same event callback and has dispatch
limits/timeouts to avoid an infinite script taking down the session.

---

## 8. Timers and delayed work

Create compositor event-loop timers:

```lua
local timer = hl.timer(function()
  hl.notification.create({ text = os.date("%H:%M"), timeout = 1000 })
end, { timeout = 60000, type = "repeat" })

timer:set_timeout(30000)
timer:set_enabled(false)
print(timer:is_enabled())
timer:set_enabled(true)
```

Types are `"oneshot"` and `"repeat"`; timeout is milliseconds and must be
positive. Timers enable debounce, delayed DPMS operations, periodic state checks,
time-based appearance, and delayed cleanup without external IPC.

---

## 9. Gestures, including live Lua gestures

`hl.gesture()` can map 2–9-finger swipe/pinch directions to built-in actions or
Lua code.

Directions: `swipe`, `horizontal`, `vertical`, `left`, `right`, `up`, `down`,
`pinch`, `pinchin`, and `pinchout`.

Built-in actions:

- workspace switching;
- window move and resize;
- special-workspace toggle;
- close, fullscreen/maximize, float/tile;
- cursor zoom (fixed, multiplicative, or live);
- scrolling-layout movement;
- `unset` for an exact prior gesture.

A callback can run once:

```lua
hl.gesture({
  fingers = 4,
  direction = "up",
  action = function() hl.exec_cmd("foot") end,
})
```

Or implement a live gesture through `start`, `update`, and `finish` callbacks.
Start/update events expose gesture type, boot-relative timestamp, fingers, delta
X/Y, and pinch scale/rotation. Finish exposes type, timestamp, and cancellation.
This can implement continuous volume/brightness control, custom animations, or
stateful desktop interactions.

Optional gesture fields include modifiers, delta scale, workspace name, mode,
zoom level, and shortcut-inhibitor bypass.

---

## 10. Custom tiling layouts in pure Lua

This is one of the largest new capabilities. Register a layout:

```lua
hl.layout.register("grid", {
  recalculate = function(ctx)
    local n = #ctx.targets
    if n == 0 then return end
    local cols = math.ceil(math.sqrt(n))
    for i, target in ipairs(ctx.targets) do
      target:place(ctx:grid_cell(i, cols))
    end
  end,

  layout_msg = function(ctx, message)
    -- mutate layout state and return true, nil, or an error string
    return true
  end,
})

hl.config({ general = { layout = "lua:grid" } })
-- or: hl.workspace_rule({ workspace = "3", layout = "lua:grid" })
```

`HL.LayoutContext` provides:

- `area = {x, y, w, h}` for usable workspace area;
- ordered `targets`;
- `grid_cell(i, columns, rows?)`;
- `column(i, count)`;
- `row(i, count)`;
- `split(box, side, ratio)` where side is left/right/top/bottom/up/down.

Each `HL.LayoutTarget` provides:

- `index`;
- optional primary `window` (groups/other targets may differ);
- current `box`;
- `place(box)` and `set_box(box)`.

Use `place()` as recommended by the wiki so Hyprland handles gaps, pseudotiling,
and reserved areas. A layout can retain arbitrary Lua state, inspect target window
metadata, change behavior according to focus/class/workspace, and process custom
messages from `hl.dsp.layout("...")`.

Upstream includes column, grid, spiral, and stateful/manual layout examples.

---

## 11. Built-in notifications

Create and list lightweight Hyprland notification overlays (not a replacement for
a freedesktop notification daemon):

```lua
local n = hl.notification.create({
  text = "Lua configuration loaded",
  timeout = 5000,
  icon = "ok",
  color = "rgba(80ff80ff)",
  font_size = 16,
})

local active = hl.notification.get()
```

`HL.Notification` methods:

- lifecycle: `dismiss()`, `is_alive()`;
- pause: `pause()`, `resume()`, `set_paused(bool)`, `is_paused()`;
- mutate: `set_text`, `set_timeout`, `set_color`, `set_icon`, `set_font_size`;
- inspect: `get_text`, `get_timeout`, `get_color`, `get_icon`, `get_font_size`,
  `get_elapsed`, `get_elapsed_since_creation`.

Icons include none, warning, info, hint, error, confused/question, and OK.

---

## 12. Plugins and Lua

Lua can:

- register plugins for loading with `hl.plugin.load("/absolute/path.so")`;
- inspect metadata with `hl.get_loaded_plugins()`;
- call functions registered by plugins under
  `hl.plugin.<namespace>.<function>(...)`;
- subscribe with `hl.on()` to custom events registered by plugins;
- set plugin config below `hl.config({ plugin = { ... } })`.

Guard plugin-specific APIs because they do not exist before the plugin is loaded:

```lua
if hl.plugin.my_plugin then
  hl.plugin.my_plugin.configure({ enabled = true })
end
```

Lua does not replace plugins when functionality requires unexposed renderer,
protocol, layout-engine, or compositor internals. Plugin binaries remain
version-sensitive and execute native code.

---

## 13. Runtime control, testing, and editor support

### `hyprctl` Lua commands

```sh
# Execute Lua; reports ok/error
hyprctl eval 'hl.config({ ["general.gaps_in"] = 0 })'

# Dispatcher shorthand
hyprctl dispatch 'hl.dsp.focus({ workspace = "3" })'

# Evaluate and print one expression
hyprctl repl 'hl.get_active_window().class'

# Interactive session (Ctrl+D exits)
hyprctl repl
```

Runtime `hl.config()` changes made via `eval` last until the next reload unless
also written to the config. Other useful diagnostics:

```sh
hyprctl configerrors
hyprctl version
hyprctl clients
hyprctl activewindow
hyprctl workspaces
hyprctl monitors all
hyprctl layers
hyprctl devices
hyprctl binds
hyprctl animations
hyprctl layouts
```

### LuaLS autocompletion

Hyprland installs generated API/type stubs at:

```text
/usr/share/hypr/stubs/
/run/current-system/sw/share/hypr/stubs/   # typical NixOS path
```

Example `.luarc.json`:

```json
{
  "workspace": {
    "library": ["/usr/share/hypr/stubs"]
  }
}
```

The generated `hl.meta.lua` is often more precise and current than prose docs for
function return objects and config-value types. In the researched source it
documents hundreds of option keys plus the query objects and API namespaces.

---

## 14. Runtime configuration patterns enabled by Lua

### Toggle any config value

```lua
hl.bind("SUPER + SHIFT + G", function()
  local gaps = hl.get_config("general.gaps_in")
  hl.config({ ["general.gaps_in"] = gaps.top == 0 and 5 or 0 })
end)
```

### Context-sensitive key behavior

```lua
hl.bind("SUPER + Return", function()
  local w = hl.get_active_window()
  if w and w.class == "foot" then
    hl.dispatch(hl.dsp.window.pseudo({ window = w }))
  else
    hl.exec_cmd("foot")
  end
end)
```

### Dynamic named rule

```lua
local focusMode = hl.window_rule({
  name = "focus-mode-dim",
  match = { focus = false },
  opacity = "0.55 override",
})
focusMode:set_enabled(false)

hl.bind("SUPER + F12", function()
  focusMode:set_enabled(not focusMode:is_enabled())
end)
```

### Monitor-aware behavior

```lua
hl.on("monitor.added", function(m)
  if m.name == "DP-1" then
    m:set_workspace("name:external")
  end
end)
```

### Delayed DPMS, avoiding direct keybind timing issues

```lua
hl.bind("SUPER + SHIFT + P", function()
  hl.timer(function()
    hl.dispatch(hl.dsp.dpms({ action = "disable" }))
  end, { timeout = 500, type = "oneshot" })
end)
```

These primitives also support leader-key menus, mode indicators, monitor docking
profiles, workspace-specific policies, rules generated from data tables, adaptive
animation/decoration profiles, stateful layouts, and desktop automation based on
focus, screensharing, urgency, or key state.

---

## 15. Important limits, performance, and security

### Do not block the compositor event loop

Bind, event, timer, and live-gesture callbacks execute in Hyprland's process/event
loop. Blocking operations freeze input and rendering. Avoid inside callbacks:

- `io.popen()` and synchronous subprocess waits;
- network I/O;
- clipboard programs such as `wl-paste`/`xclip`;
- sleeps and long loops;
- heavy file processing.

Use `hl.exec_cmd()`/`hl.dsp.exec_cmd()` for asynchronous external work. Keep live
gesture and keyboard-event callbacks especially small.

### Deferred property refresh

Config, device, monitor, and workspace-rule changes may schedule one consolidated
property refresh at the end of the current Lua event. Code later in the same
callback may still observe the old applied state. If ordering absolutely requires
it:

```lua
hl.exec_scheduled_prop_refresh_immediately()
```

Overuse can cause slowdowns. Observe `config.props_refreshed` while debugging.

### Error behavior

- Fundamental syntax errors reject a reload.
- Runtime Lua errors abort the current Lua file/scope.
- Many `hl.*` type errors report a config error and allow later execution.
- Async callback errors become notifications/config errors.
- Required-file scope separation limits blast radius.
- Infinite-loop, re-entrancy, and callback timeout protections exist, but should
  not be treated as a performance strategy.

### Security model

A Lua config is executable code with the user's permissions. It can invoke the
shell, read/write user-accessible files, load native modules/plugins, and observe
considerable desktop state. Therefore:

- audit copied configs and Lua modules;
- do not run a “rice” as if it were inert theme data;
- narrowly scope permission regexes;
- avoid allowing arbitrary `hyprctl` plugin loading;
- remember that Hyprland permissions do not secure its IPC sockets;
- treat callbacks that inspect keyboard events, cursor position, and windows as
  sensitive automation.

---

## 16. API quick reference

### Configuration/registration

```text
hl.config                 hl.monitor               hl.device
hl.env                    hl.curve                 hl.animation
hl.window_rule            hl.layer_rule            hl.workspace_rule
hl.permission             hl.gesture               hl.bind
hl.unbind                 hl.define_submap         hl.layout.register
hl.plugin.load
```

### Automation/control

```text
hl.on                     hl.timer                 hl.dispatch
hl.exec_cmd               hl.notification.create  hl.notification.get
hl.exec_scheduled_prop_refresh_immediately
hl.clear_crashed_lockscreen
```

### Queries

```text
hl.get_config             hl.get_windows           hl.get_window
hl.get_active_window      hl.get_urgent_window     hl.get_last_window
hl.get_workspaces         hl.get_workspace         hl.get_active_workspace
hl.get_active_special_workspace                    hl.get_last_workspace
hl.get_workspace_windows  hl.get_monitors          hl.get_monitor
hl.get_active_monitor     hl.get_monitor_at        hl.get_monitor_at_cursor
hl.get_layers             hl.get_cursor_pos        hl.get_current_submap
hl.get_loaded_plugins     hl.is_key_down           hl.version
```

### Dispatcher namespaces

```text
hl.dsp.*
hl.dsp.window.*
hl.dsp.workspace.*
hl.dsp.group.*
hl.dsp.cursor.*
```

---

## 17. Sources and research notes

### Primary official sources

1. [Lua-ification announcement (2026-04-26)](https://hypr.land/news/26_lua/)
2. [Hyprland Wiki: Core / start here](https://wiki.hypr.land/configuring/core/)
3. [Config options](https://wiki.hypr.land/configuring/core/config-options/)
4. [Lua utilities](https://wiki.hypr.land/configuring/core/advanced-configuration/lua-utilities/)
5. [Lua events](https://wiki.hypr.land/configuring/core/advanced-configuration/events/)
6. [Binds](https://wiki.hypr.land/configuring/core/binds/)
7. [Dispatchers](https://wiki.hypr.land/configuring/core/dispatchers/)
8. [Gestures](https://wiki.hypr.land/configuring/core/binds/gestures/)
9. [Window rules](https://wiki.hypr.land/configuring/core/rules/window-rules/)
10. [Layer rules](https://wiki.hypr.land/configuring/core/rules/layer-rules/)
11. [Workspace rules](https://wiki.hypr.land/configuring/core/rules/workspace-rules/)
12. [Custom layouts](https://wiki.hypr.land/configuring/layouts/custom-layouts/)
13. [Using hyprctl](https://wiki.hypr.land/configuring/core/advanced-configuration/using-hyprctl/)
14. [Permissions](https://wiki.hypr.land/configuring/core/advanced-configuration/permissions/)
15. [Official Lua example](https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua)
16. [Official Lua layout examples](https://github.com/hyprwm/Hyprland/tree/main/example/layouts)
17. [Generated LuaLS API stub](https://github.com/hyprwm/Hyprland/blob/main/meta/hl.meta.lua)
18. [Lua implementation source](https://github.com/hyprwm/Hyprland/tree/main/src/config/lua)

### Snapshot details

- Research machine: Hyprland 0.56.0, built 2026-08-30.
- Hyprland source inspected: `86c24e2e079aa62214421c76f01b603fc8178125`.
- Wiki source inspected: `6fbe82af4d010d2e96a194aac8be4b9b47f7b236`.
- Local upstream checkouts used:
  - `~/git/Hyprland`
  - `~/git/hyprland-wiki`

The source and generated stub were consulted where the prose wiki only summarized
return-object fields or omitted small source-level capabilities. Such details are
more likely to change and should be rechecked after a Hyprland upgrade.

### Research/troubleshooting log

- Direct text extraction with the configured web-fetch service failed for the
  announcement and wiki landing page. The official announcement was retrieved
  with `wget`, while the wiki was inspected from its official Git repository.
- The existing `~/git/Hyprland` checkout was already at the current researched
  commit; the official wiki was cloned to `~/git/hyprland-wiki`.
- The upstream Lua stub generator reported `meta/hl.meta.lua` unchanged, confirming
  that the checked-in generated API reference matched the inspected source.
- A final `git status` check across both large checkouts timed out; no source edits
  were requested or made. Only this report was created under `~/Documents`.
