-- Run from this directory's parent: luajit tests/codex-usage.lua
local state, watchers, requests, presentation = {}, {}, {}, {}
local accepted = true
local now = 1000
noctalia = {
    setUpdateInterval = function(ms) assert(ms == 60000) end,
    expandPath = function(path) assert(path == "~/.local/bin/codex-usage"); return "/home/test/.local/bin/codex-usage" end,
    runAsync = function(argv, callback)
        assert(argv[1] == "/home/test/.local/bin/codex-usage" and #argv == 1)
        if accepted then table.insert(requests, callback) end
        return accepted
    end,
    state = {
        get = function(key) return state[key] end,
        set = function(key, value)
            state[key] = value
            if watchers[key] then watchers[key](value) end
        end,
        watch = function(key, callback) watchers[key] = callback end,
    },
    log = function() end,
    formatTime = function() return "12:00:00" end,
    nowMs = function() now = now + 1; return now end,
}
barWidget = {}
for _, name in ipairs({ "Text", "Glyph", "Color", "GlyphColor", "Tooltip" }) do
    barWidget["set" .. name] = function(value) presentation[name] = value end
end

local function complete(stdout, code, timedOut)
    local callback = table.remove(requests, 1)
    assert(callback, "no pending request")
    callback({ stdout = stdout, exitCode = code or 0, timedOut = timedOut or false })
end

dofile("codex-usage/service.luau")
local serviceUpdate, serviceIpc = update, onIpc
assert(#requests == 1)
serviceUpdate()
serviceIpc("refresh")
assert(#requests == 1, "overlapping requests must be suppressed")

dofile("codex-usage/widget.luau")
assert(presentation.Text == "5h — 7d —")
complete("6\t2\n")
assert(presentation.Text == "5h 6% 7d 2%")
assert(presentation.Color == "#a6e3a1")
assert(presentation.Glyph == "robot")
assert(presentation.Tooltip:find("used, not remaining", 1, true))

for _, case in ipairs({
    { "69\t0\n", "#a6e3a1" },
    { "0\t70\n", "#f9e2af" },
    { "89\t0\n", "#f9e2af" },
    { "0\t90\n", "#f38ba8" },
    { "100 100\n", "#f38ba8" },
}) do
    onClick()
    assert(#requests == 1, "click must request a refresh")
    complete(case[1])
    assert(presentation.Color == case[2])
    assert(presentation.GlyphColor == case[2])
end

for _, bad in ipairs({ "", "garbage", "6", "-1\t2", "101\t2", "2\t101", "6\t2 extra", "6.5\t2" }) do
    serviceUpdate()
    complete(bad)
    assert(presentation.Text == "5h 100% 7d 100%", "bad data must not replace the last good reading")
    assert(presentation.Tooltip:find("Refresh failed", 1, true))
end
serviceUpdate()
complete("", 1)
assert(presentation.Text == "5h 100% 7d 100%")
serviceUpdate()
complete("0\t0", 0, true)
assert(presentation.Text == "5h 100% 7d 100%")
accepted = false
serviceUpdate()
assert(#requests == 0)
assert(state.usage.error)
accepted = true
onIpc("refresh")
complete("0\t0\n")
assert(presentation.Text == "5h 0% 7d 0%")
assert(state.usage.error == nil, "successful retry must clear the error")

state.usage = nil
serviceUpdate()
complete("", 1)
assert(presentation.Text == "5h — 7d —", "first-run failure must not invent usage")
serviceUpdate()
complete("1\t2\n")
assert(presentation.Text == "5h 1% 7d 2%")
print("Codex usage tests passed (polling, overlap, click, colors, errors, recovery)")
