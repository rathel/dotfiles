-- A singleton service avoids spawning one Codex app-server per monitor.
local busy = false
noctalia.setUpdateInterval(60000)

local function failed()
    local usage = noctalia.state.get("usage") or {}
    usage.error = "Refresh failed; showing the last successful reading, if available."
    noctalia.state.set("usage", usage)
    noctalia.log("Codex usage refresh failed; retrying in one minute")
end

local function refresh()
    if busy then
        return
    end
    busy = true
    local accepted = noctalia.runAsync({ noctalia.expandPath("~/.local/bin/codex-usage") }, function(result)
        busy = false
        if result.exitCode ~= 0 or result.timedOut then
            failed()
            return
        end
        local short, weekly = string.match(result.stdout or "", "^%s*(%d+)%s+(%d+)%s*$")
        short, weekly = tonumber(short), tonumber(weekly)
        if not short or not weekly or short > 100 or weekly > 100 then
            failed()
            return
        end
        noctalia.state.set("usage", {
            short = short,
            weekly = weekly,
            updated = os.time(),
        })
    end)
    if not accepted then
        busy = false
        failed()
    end
end

function update()
    refresh()
end

function onIpc(event)
    if event == "refresh" then
        refresh()
    end
end

noctalia.state.watch("refresh", refresh)
refresh()
