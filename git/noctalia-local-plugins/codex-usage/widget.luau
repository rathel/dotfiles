local function render(usage)
    usage = usage or {}
    barWidget.setGlyph("robot")
    if usage.short == nil or usage.weekly == nil then
        barWidget.setText("5h — 7d —")
        barWidget.setColor("on_surface")
        barWidget.setGlyphColor("on_surface")
        barWidget.setTooltip("Codex usage unavailable. Click to retry.")
        return
    end

    local highest = math.max(usage.short, usage.weekly)
    -- Match the old Quickshell bar's Catppuccin Mocha thresholds and colors.
    local color = highest >= 90 and "#f38ba8" or highest >= 70 and "#f9e2af" or "#a6e3a1"
    barWidget.setText(string.format("5h %d%% 7d %d%%", usage.short, usage.weekly))
    barWidget.setColor(color)
    barWidget.setGlyphColor(color)
    local tooltip = string.format("Codex subscription usage (used, not remaining)\nFive-hour: %d%%\nWeekly: %d%%", usage.short, usage.weekly)
    if usage.updated then
        tooltip = tooltip .. "\nUpdated: " .. noctalia.formatTime("{:%H:%M:%S}", usage.updated)
    end
    if usage.error then
        tooltip = tooltip .. "\n" .. usage.error
    end
    barWidget.setTooltip(tooltip .. "\nClick to refresh. Updates every minute.")
end

function onClick()
    noctalia.state.set("refresh", noctalia.nowMs())
end

function onIpc(event)
    if event == "refresh" then
        onClick()
    elseif event == "status" then
        noctalia.log("Codex widget " .. tostring(barWidget.outputName()) .. ": " .. (noctalia.json.encode(noctalia.state.get("usage")) or "unavailable"))
    end
end

noctalia.state.watch("usage", render)
render(noctalia.state.get("usage"))
