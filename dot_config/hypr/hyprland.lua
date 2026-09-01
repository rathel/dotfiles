-- Hyprland 0.56 Lua configuration.
-- Migrated from hyprland.conf.legacy; the legacy file is kept for reference.

local mainMod = "SUPER"
local profileBin = "/home/rathel/.local/state/nix/profiles/profile/bin"

-- A master pane with a vertically scrolling stack on the right. Hyprland's
-- built-in master and scrolling layouts cannot be combined, so this keeps the
-- useful parts of both in a small Lua layout.
local masterStackState = {}
local masterStackRatio = 0.60
local masterStackGap = 3
-- Keep the master and stack columns logically adjacent so directional focus
-- can move between them; target placement still supplies the visual gaps.
local masterStackColumnGap = 0
local masterStackCardRatio = 0.70

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function masterStackTargetId(target)
    local window = target.window
    return window and tostring(window.stable_id) or tostring(target.index)
end

local function masterStackWorkspaceKey(target)
    local window = target.window
    local workspace = window and window.workspace
    if workspace then
        return tostring(workspace.id)
    end
    return "default"
end

local function masterStackIndexOf(values, value)
    for index, candidate in ipairs(values) do
        if candidate == value then
            return index
        end
    end
end

local function masterStackSync(ctx)
    local stateKey = masterStackWorkspaceKey(ctx.targets[1])
    local state = masterStackState[stateKey]
    local restoring = false
    if not state then
        state = { order = {}, master = nil, offset = 0 }
        masterStackState[stateKey] = state
        restoring = true
    end

    local targets = {}
    local present = {}
    for _, target in ipairs(ctx.targets) do
        local id = masterStackTargetId(target)
        targets[id] = target
        present[id] = true
    end

    local order = {}
    if restoring then
        -- A Lua reload destroys this table, but the layout targets retain their
        -- last boxes. Reconstruct the master and stack order from those boxes
        -- so a reload does not reset the visible stack position.
        local positioned = {}
        for _, target in ipairs(ctx.targets) do
            local box = target.box
            if box and box.w > 0 and box.h > 0 then
                table.insert(positioned, {
                    id = masterStackTargetId(target),
                    box = box,
                })
            end
        end

        table.sort(positioned, function(left, right)
            return left.box.w > right.box.w
        end)

        local looksLikeMasterStack = #positioned == #ctx.targets
            and (#positioned == 1 or positioned[1].box.w > positioned[2].box.w * 1.1)
        if looksLikeMasterStack then
            state.master = positioned[1].id
            table.insert(order, state.master)

            local stack = {}
            for index = 2, #positioned do
                table.insert(stack, positioned[index])
            end
            table.sort(stack, function(left, right)
                return left.box.y < right.box.y
            end)
            for _, entry in ipairs(stack) do
                table.insert(order, entry.id)
            end

            if #stack > 0 then
                local cardHeight = ctx.area.h
                if #stack > 1 then
                    cardHeight = math.max(1, ctx.area.h * masterStackCardRatio)
                end
                local maxOffset = math.max(0,
                    #stack * cardHeight + (#stack - 1) * masterStackGap - ctx.area.h)
                state.offset = clamp(ctx.area.y - stack[1].box.y, 0, maxOffset)
            end
        end
    end
    for _, id in ipairs(state.order) do
        if present[id] then
            table.insert(order, id)
        end
    end

    -- Insert newly opened windows before the existing stack, rather than at
    -- its bottom. Keep the order in which multiple windows arrive.
    local newIds = {}
    for _, target in ipairs(ctx.targets) do
        local id = masterStackTargetId(target)
        if not masterStackIndexOf(order, id) then
            table.insert(newIds, id)
        end
    end

    local insertAt
    for index, id in ipairs(order) do
        if id ~= state.master then
            insertAt = index
            break
        end
    end
    if not insertAt then
        insertAt = #order + 1
    end
    for _, id in ipairs(newIds) do
        table.insert(order, insertAt, id)
        insertAt = insertAt + 1
    end
    state.order = order

    if not state.master or not present[state.master] then
        state.master = order[1]
        state.offset = 0
    end

    return state, targets
end

local function masterStackGeometry(area, stackCount)
    local masterWidth = (area.w - masterStackColumnGap) * masterStackRatio
    local stackX = area.x + masterWidth + masterStackColumnGap
    local stackWidth = math.max(1, area.w - masterWidth - masterStackColumnGap)
    local cardHeight = area.h

    if stackCount > 1 then
        cardHeight = math.max(1, area.h * masterStackCardRatio)
    end

    local step = cardHeight + masterStackGap
    local contentHeight = stackCount * cardHeight + math.max(0, stackCount - 1) * masterStackGap
    local maxOffset = math.max(0, contentHeight - area.h)

    return {
        masterWidth = math.max(1, masterWidth),
        stackX = stackX,
        stackWidth = stackWidth,
        cardHeight = cardHeight,
        step = step,
        maxOffset = maxOffset,
    }
end

hl.layout.register("master-stack", {
    recalculate = function(ctx)
        if #ctx.targets == 0 then
            return
        end

        local state, targets = masterStackSync(ctx)
        local master = targets[state.master]
        if not master then
            return
        end

        local area = ctx.area
        local stackIds = {}
        for _, id in ipairs(state.order) do
            if id ~= state.master then
                table.insert(stackIds, id)
            end
        end

        if #stackIds == 0 then
            master:place(area)
            return
        end

        local geometry = masterStackGeometry(area, #stackIds)
        state.offset = clamp(state.offset or 0, 0, geometry.maxOffset)

        master:place({
            x = area.x,
            y = area.y,
            w = geometry.masterWidth,
            h = area.h,
        })

        for index, id in ipairs(stackIds) do
            local target = targets[id]
            if target then
                target:place({
                    x = geometry.stackX,
                    y = area.y + (index - 1) * geometry.step - state.offset,
                    w = geometry.stackWidth,
                    h = geometry.cardHeight,
                })
            end
        end
    end,

    layout_msg = function(ctx, message)
        if #ctx.targets == 0 then
            return true
        end

        local command, argument = message:match("^(%S+)%s*(.*)$")
        local state, targets = masterStackSync(ctx)
        local stackCount = #state.order - 1
        local geometry = masterStackGeometry(ctx.area, math.max(0, stackCount))

        if command == "scroll" then
            local amount = math.max(ctx.area.h * 0.45, geometry.cardHeight * 0.65)
            if argument == "up" then
                state.offset = (state.offset or 0) - amount
            elseif argument == "down" then
                state.offset = (state.offset or 0) + amount
            else
                return "master-stack: expected scroll up or scroll down"
            end
            state.offset = clamp(state.offset, 0, geometry.maxOffset)
        elseif command == "reset" then
            state.offset = 0
        elseif command == "select" then
            -- Directional focus is unreliable here because the stack cards
            -- overlap. Select explicitly from the layout's stable order.
            if argument == "master" then
                local selected = targets[state.master]
                if selected and selected.window then
                    hl.dispatch(hl.dsp.focus({ window = selected.window }))
                end
            elseif stackCount > 0 then
                local stackIds = {}
                for _, id in ipairs(state.order) do
                    if id ~= state.master then
                        table.insert(stackIds, id)
                    end
                end

                local activeIndex
                for index, id in ipairs(stackIds) do
                    local target = targets[id]
                    if target and target.window and target.window.active then
                        activeIndex = index
                        break
                    end
                end

                local selectedIndex
                if argument == "next" then
                    selectedIndex = activeIndex and (activeIndex % #stackIds) + 1 or 1
                elseif argument == "previous" then
                    selectedIndex = activeIndex and ((activeIndex - 2) % #stackIds) + 1 or #stackIds
                else
                    return "master-stack: expected select master, select next, or select previous"
                end

                local selected = targets[stackIds[selectedIndex]]
                if selected and selected.window then
                    -- Explicit selection recenters; unrelated focus changes
                    -- (for example switching monitors) leave the offset alone.
                    local centeredOffset = (selectedIndex - 1) * geometry.step
                        + geometry.cardHeight / 2 - ctx.area.h / 2
                    state.offset = clamp(centeredOffset, 0, geometry.maxOffset)
                    hl.dispatch(hl.dsp.focus({ window = selected.window }))
                end
            end
        elseif command == "reorder" then
            local stackIds = {}
            for _, id in ipairs(state.order) do
                if id ~= state.master then
                    table.insert(stackIds, id)
                end
            end

            local activeIndex
            for index, id in ipairs(stackIds) do
                local target = targets[id]
                if target and target.window and target.window.active then
                    activeIndex = index
                    break
                end
            end

            local delta
            if argument == "up" then
                delta = -1
            elseif argument == "down" then
                delta = 1
            else
                return "master-stack: expected reorder up or reorder down"
            end

            local newIndex = activeIndex and activeIndex + delta
            if newIndex and newIndex >= 1 and newIndex <= #stackIds then
                stackIds[activeIndex], stackIds[newIndex] = stackIds[newIndex], stackIds[activeIndex]
                state.order = { state.master }
                for _, id in ipairs(stackIds) do
                    table.insert(state.order, id)
                end

                -- Follow the moved window so it remains visible as it is
                -- reordered through the vertically scrolling stack.
                local centeredOffset = (newIndex - 1) * geometry.step
                    + geometry.cardHeight / 2 - ctx.area.h / 2
                state.offset = clamp(centeredOffset, 0, geometry.maxOffset)
            end
        elseif command == "promote" then
            for id, target in pairs(targets) do
                if target.window and target.window.active then
                    state.master = id
                    state.offset = 0
                    break
                end
            end
        else
            return "master-stack: expected select master, select next, select previous, scroll up, scroll down, reset, reorder up, reorder down, or promote"
        end

        return true
    end,
})

-- The stack offset is workspace-local and is intentionally not changed by
-- ordinary focus events, so monitor/workspace switches restore the same view.

-- Monitors, input, and environment. DP-2 is now left of DP-1.
hl.monitor({ output = "DP-2", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "1920x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = true,
        follow_mouse = 0,
        touchpad = {
            tap_to_click = true,
            natural_scroll = true,
        },
    },
    general = {
        gaps_in = 12,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = "rgb(88c0d0)",
            inactive_border = "rgb(4c566a)",
        },
        layout = "lua:master-stack",
        resize_on_border = true,
    },
    decoration = {
        rounding = 5,
        blur = {
            enabled = true,
            size = 30,
            passes = 3,
            new_optimizations = true,
        },
        dim_inactive = true,
        dim_strength = 0.08,
        shadow = {
            enabled = true,
            range = 8,
            render_power = 3,
            color = "rgba(00000055)",
        },
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        -- Permit focus requests under a maximized window by transferring
        -- maximize state instead of trapping focus on the old window.
        on_focus_under_fullscreen = 1,
        vrr = 0,
    },
    binds = {
        -- Let directional focus continue onto an adjacent monitor at the edge.
        window_direction_monitor_fallback = true,
    },
})

hl.env("CHROME_USE_OZONE", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("GDK_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "lxqt")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("WARP_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("PATH", profileBin .. ":/home/rathel/.local/bin:/usr/local/bin:/usr/bin:/bin")

-- Animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.animation({ leaf = "global", enabled = true, speed = 1, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slidevert" })

-- Autostart only programs present on this system. Personal missing helpers from
-- the legacy config are intentionally not started.
hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell --no-duplicate")
    hl.exec_cmd("mako")
    hl.exec_cmd("steam -silent")
    hl.exec_cmd("wlsunset -l 34 -L -104")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("udiskie -t")
    hl.exec_cmd("/home/rathel/.local/bin/wallpaper.sh")
    -- Keep clipboard contents after the source application exits.
    hl.exec_cmd(profileBin .. "/wl-paste --type text --watch " .. profileBin .. "/cliphist store")
    hl.exec_cmd(profileBin .. "/wl-paste --type image --watch " .. profileBin .. "/cliphist store")
end)

-- Applications and utility actions
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("foot"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("foot --title=scratch -e /home/rathel/.local/bin/cm-edit.sh"))
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd("/home/rathel/.local/bin/pi-tofi.sh"))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("foot --title=scratch -e sh"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("tofi-drun"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("fish -c 'infisical-env steam -- /home/rathel/git/fuzzel-steam-launcher/tofi-steam.sh'"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/rathel/.local/bin/host-picker"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("thunderbird"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("/home/rathel/Applications/Communication/beeper.AppImage"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("/home/rathel/.local/bin/launch-shadowtech.sh"))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("swaylock -f -c 2e3440"))

-- Audio and media
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Focus, movement, and workspaces
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
for _, key in ipairs({ "left", "down", "up", "right" }) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = key }))
end
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
-- Explicit stack selection avoids directional-focus ambiguity caused by the
-- overlapping stack cards. Selecting a stack item also recenters the stack.
hl.bind(mainMod .. " + J", hl.dsp.layout("select next"))
hl.bind(mainMod .. " + K", hl.dsp.layout("select previous"))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind("ALT + TAB", hl.dsp.focus({ last = true }))

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.window.move({ workspace = 10 }))
hl.bind(mainMod .. " + PAGE_DOWN", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + PAGE_UP", hl.dsp.focus({ workspace = "e-1" }))
-- These bindings are defined below, after the dynamic workspace helper.
-- Niri-like monitor-local workspace navigation. Hyprland's m+1/m-1
-- only visit workspaces that already exist, so create the next one when
-- moving down past the last workspace on this monitor.
local function focusVerticalWorkspace(direction)
    local monitor = hl.get_active_monitor()
    local current = hl.get_active_workspace(monitor)
    if not monitor or not current then
        return
    end

    local workspaces = {}
    for _, workspace in ipairs(hl.get_workspaces()) do
        local owner = workspace.monitor
        local sameMonitor = owner == monitor
            or owner == monitor.name
            or owner == monitor.id
        if not workspace.special and sameMonitor then
            table.insert(workspaces, workspace)
        end
    end

    table.sort(workspaces, function(left, right)
        return left.id < right.id
    end)

    local currentIndex
    for index, workspace in ipairs(workspaces) do
        if workspace.id == current.id then
            currentIndex = index
            break
        end
    end

    if not currentIndex then
        return
    end

    local target = workspaces[currentIndex + direction]
    if target then
        hl.dispatch(hl.dsp.focus({ workspace = target.id }))
    elseif direction > 0 then
        hl.dispatch(hl.dsp.focus({ workspace = "emptynm" }))
    end
end

hl.bind(mainMod .. " + U", function()
    focusVerticalWorkspace(1)
end)
hl.bind(mainMod .. " + I", function()
    focusVerticalWorkspace(-1)
end)
hl.bind(mainMod .. " + CTRL + PAGE_DOWN", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + PAGE_UP", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + U", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + I", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + mouse_down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + mouse_up", hl.dsp.window.move({ workspace = "e-1" }))

for _, dir in ipairs({ "left", "down", "up", "right" }) do
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.focus({ monitor = dir }))
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. dir, hl.dsp.window.move({ monitor = dir }))
end
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.focus({ monitor = "d" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.focus({ monitor = "u" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.focus({ monitor = "r" }))
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + SHIFT + J", hl.dsp.window.move({ monitor = "d" }))
hl.bind(mainMod .. " + CTRL + SHIFT + K", hl.dsp.window.move({ monitor = "u" }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ monitor = "r" }))

-- Window actions
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "unset" }))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(profileBin .. "/cliphist list | tofi --prompt-text clipboard | " .. profileBin .. "/cliphist decode | " .. profileBin .. "/wl-copy"))
hl.bind(mainMod .. " + minus", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + equal", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind(mainMod .. " + O", hl.dsp.workspace.toggle_special("overview"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind("CTRL + ALT + delete", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprctl dispatch dpms off"))

-- Keyboard navigation selects a stack item and automatically scrolls it into
-- view. Mouse scrolling remains focus-neutral.
hl.bind(mainMod .. " + ALT + H", hl.dsp.layout("select master"))
hl.bind(mainMod .. " + ALT + J", hl.dsp.layout("select next"))
hl.bind(mainMod .. " + ALT + K", hl.dsp.layout("select previous"))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.layout("reorder down"))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.layout("reorder up"))
hl.bind(mainMod .. " + ALT + R", hl.dsp.layout("reset"))
hl.bind(mainMod .. " + ALT + Return", hl.dsp.layout("promote"))
hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.layout("scroll down"))
hl.bind(mainMod .. " + ALT + mouse_up", hl.dsp.layout("scroll up"))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots using the installed grim/slurp tools.
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))
hl.bind(mainMod .. " + CTRL + F12", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp -o)\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))
hl.bind(mainMod .. " + ALT + F12", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))

-- Window rules
local function rule(name, match, effects)
    effects.name = name
    effects.match = match
    hl.window_rule(effects)
end

rule("steam-toast-no-focus", { class = "^(steam)$", title = "^notificationtoasts_[0-9]+_desktop$" }, { no_focus = true, float = true })
rule("unfocused-opacity", { focus = false }, { opacity = "0.9 override 0.9 override" })
rule("media-opacity", { title = "^(▶.*|Netflix.*)$" }, { opacity = "1.0 override 1.0 override" })
rule("firefox-picture-in-picture", { class = "^(firefox-dev)$", title = "^Picture-in-Picture$" }, { float = true, size = "50% 50%", move = "50% 50%" })
rule("scratch-terminal", { title = "^scratch$" }, { float = true, size = "40% 40%" })
rule("termdown", { title = "^termdown$" }, { float = true, size = "20% 20%", move = "79% 1%" })
rule("vlc-floating", { class = "^(vlc)$" }, { float = true })
rule("chrome-floating", { class = "^(chrome-nngceckbapebfimnlniiiahkandclblb-Default)$" }, { float = true })
rule("thunar-progress", { class = "^(thunar)$", title = "^File Operation Progress$" }, { float = true })
rule("fladder", { class = "^(Fladder)$" }, { float = true, workspace = "3", monitor = "DP-3", maximize = true })
rule("mpv-popup", { class = "^(mpv)$" }, { float = true, size = "20% 20%", move = "79% 1%", immediate = true })
rule("mpv-otmpv", { class = "^(mpv)$", title = "^otmpv$" }, { move = "79% 58%" })
rule("mpv-streamers", { class = "^(mpv)$", title = "^Streamers$" }, { move = "79% 35%" })
-- Keep all Thunderbird windows out of the master-stack layout. Thunderbird
-- opens compose/reply windows separately and their titles change after opening.
rule("thunderbird-floating", { class = "^(thunderbird)$" }, { float = true })
rule("thunderbird-reminders", { class = "^(thunderbird-beta)$", title = "^Reminders$" }, { float = true, size = "30% 30%" })
