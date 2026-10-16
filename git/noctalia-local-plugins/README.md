# Local Noctalia plugins

## Codex usage

`codex-usage/` is a Noctalia v5 Luau plugin (`plugin_api = 24`). It
reuses `~/.local/bin/codex-usage`, which asks the signed-in Codex CLI's
app-server for subscription rate limits. No API keys are stored here and
no credential files are read by the plugin.

- Bar text: robot icon, `5h 9% 7d 2%` (percent **used**).
- One singleton background service polls every 60 seconds across all monitors.
- Green below 70%, yellow at 70%, red at 90%, using the old Quickshell
  Catppuccin Mocha colors and the higher of the two usage values.
- Failed refreshes retain the last good values and mark the tooltip stale.
  Before the first successful reading the widget shows dashes.
- Left-click to refresh; hover for details and last-update time.

### Enable

```sh
noctalia msg plugins source add rathel-local path "$HOME/git/noctalia-local-plugins"
noctalia msg plugins enable rathel/codex-usage
```

Add a named widget and place it in a bar's start/center/end list, retaining
any existing widgets:

```toml
[widget.codex-usage]
type = "rathel/codex-usage:usage"
```

This machine's placement is in `~/.config/noctalia/codex-usage.toml`.
Plugin source/enable settings are saved by Noctalia in its settings layer.

### Check

```sh
cd ~/git/noctalia-local-plugins
luajit tests/codex-usage.lua
noctalia plugins lint codex-usage
noctalia config validate
noctalia msg plugin rathel/codex-usage:usage all status
noctalia msg plugin rathel/codex-usage:poller all refresh
```

`status` logs the shared usage snapshot with each widget's output connector.
Noctalia's log location depends on how it was started; this session writes
`/tmp/noctalia.log`.

The LuaJIT tests mock Noctalia's host API and test the Lua-compatible Luau
source directly: initial load, overlap suppression, click refresh, all color
boundaries, malformed values, out-of-range values, timeout, nonzero exit,
rejected subprocess launch, stale retention, first-run errors, and recovery.
The native Noctalia runtime must also be checked when changing host API calls.
