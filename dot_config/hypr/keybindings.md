# Hyprland keybindings

These bindings are defined in [`hyprland.lua`](./hyprland.lua). `SUPER` is the
Hyprland main modifier.

## Applications and utilities

| Key | Action |
|---|---|
| `SUPER + T` | Open Foot terminal |
| `SUPER + P` | Open the scratch terminal with `cm-edit.sh` |
| `SUPER + ALT + P` | Open the Pi launcher |
| `SUPER + M` | Toggle maximize for the active window |
| `SUPER + grave` | Open a scratch shell |
| `SUPER + D` | Open the application launcher (`tofi-drun`) |
| `SUPER + S` | Open the Steam launcher |
| `SUPER + SHIFT + S` | Open the host picker |
| `SUPER + SHIFT + T` | Open Thunderbird |
| `SUPER + B` | Open Firefox |
| `SUPER + SHIFT + B` | Open Beeper |
| `SUPER + G` | Launch Shadowtech |
| `SUPER + ALT + L` | Lock the screen |

The session also locks automatically after 10 minutes of inactivity and before
sleep. The idle manager pauses while Shadow PC is running.

## Audio and media

| Key | Action |
|---|---|
| `XF86AudioRaiseVolume` | Increase volume by 5% |
| `XF86AudioLowerVolume` | Decrease volume by 5% |
| `XF86AudioMute` | Toggle audio mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86AudioNext` | Next track |
| `XF86AudioPause` / `XF86AudioPlay` | Toggle play/pause |
| `XF86AudioPrev` | Previous track |

Volume and mute bindings work while the screen is locked. Volume changes repeat
while held and are capped at 100%; mute toggles do not repeat. The external
monitors have no `brightnessctl` backlight, so brightness keys are intentionally
unbound.

## Focus and window navigation

| Key | Action |
|---|---|
| `SUPER + Left/Down/Up/Right` | Focus a window in that direction |
| `SUPER + H/L` | Focus left/right, including across adjacent monitors |
| `SUPER + J/K` | Select the next/previous window in the stack |
| `ALT + TAB` | Focus the previously focused window |
| `SUPER + Q` | Close the active window |

## Workspaces

| Key | Action |
|---|---|
| `SUPER + 1` … `SUPER + 9` | Focus workspace 1 … 9 |
| `SUPER + 0` | Focus workspace 10 |
| `SUPER + CTRL + 1` … `9` | Move the active window to workspace 1 … 9 |
| `SUPER + CTRL + 0` | Move the active window to workspace 10 |
| `SUPER + PAGE_DOWN` / `PAGE_UP` | Focus the next/previous monitor-local workspace |
| `SUPER + U` / `I` | Focus the next/previous monitor-local workspace |
| `SUPER + CTRL + PAGE_DOWN` / `PAGE_UP` | Move the active window to the next/previous monitor-local workspace |
| `SUPER + CTRL + U` / `I` | Move the active window to the next/previous monitor-local workspace |
| `SUPER + mouse_down` / `mouse_up` | Focus the next/previous monitor-local workspace |
| `SUPER + CTRL + mouse_down` / `mouse_up` | Move the active window to the next/previous monitor-local workspace |

Moving downward past the final workspace creates the next empty workspace on the
current monitor. Moving upward from the first workspace is a no-op.

## Monitor navigation

| Key | Action |
|---|---|
| `SUPER + SHIFT + Left/Down/Up/Right` | Focus the monitor in that direction |
| `SUPER + SHIFT + H/J/K/L` | Focus the monitor left/down/up/right |
| `SUPER + CTRL + SHIFT + Left/Down/Up/Right` | Move the active window to that monitor |
| `SUPER + CTRL + SHIFT + H/J/K/L` | Move the active window to the monitor left/down/up/right |

## Window actions

| Key | Action |
|---|---|
| `SUPER + M` | Toggle maximize |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + SHIFT + F` | Exit fullscreen |
| `SUPER + V` | Toggle floating |
| `SUPER + SHIFT + V` | Open clipboard history |
| `SUPER + minus` / `equal` | Resize horizontally by 100 pixels |
| `SUPER + SHIFT + minus` / `equal` | Resize vertically by 100 pixels |
| `SUPER + O` | Toggle the `overview` special workspace |
| `SUPER + SHIFT + E` | Exit Hyprland |
| `CTRL + ALT + Delete` | Exit Hyprland |
| `SUPER + SHIFT + P` | Lock, then turn off the displays with DPMS |

## Master-stack layout

These bindings control the custom `master-stack` layout. Any focus path,
including `ALT+TAB`, recenters an off-screen active stack card.

| Key | Action |
|---|---|
| `SUPER + J` / `K` | Select the next/previous stack window |
| `SUPER + CTRL + J` / `K` | Move the focused stack window down/up and scroll it into view |
| `SUPER + ALT + H` | Focus the master window |
| `SUPER + ALT + J` / `K` | Focus the next/previous stack window and scroll it into view |
| `SUPER + ALT + R` | Reset stack scrolling |
| `SUPER + ALT + Return` | Promote the active window to master |
| `SUPER + ALT + mouse_down` / `mouse_up` | Scroll the stack down/up without changing focus |

## Mouse window controls

| Key | Action |
|---|---|
| `SUPER + mouse:272` | Drag the active window |
| `SUPER + mouse:273` | Resize the active window |

## Screenshots

Screenshots are saved under `~/Pictures/Screenshots/` with a timestamped filename.

| Key | Action |
|---|---|
| `SUPER + F12` | Capture the whole screen |
| `SUPER + CTRL + F12` | Capture the output selected by `slurp -o` |
| `SUPER + ALT + F12` | Select a region with `slurp` and capture it |
