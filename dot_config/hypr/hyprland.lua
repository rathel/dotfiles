-- Hyprland 0.56 Lua configuration.

local home = assert(os.getenv("HOME"), "HOME is not set")
local mainMod = "SUPER"
local localBin = home .. "/.local/bin"
local profileBin = home .. "/.local/state/nix/profiles/profile/bin"
local lockCommand = "swaylock -f -c 2e3440"

local function bind(keys, description, action, options)
    options = options or {}
    options.description = description
    hl.bind(keys, action, options)
end

-- Custom master/scrolling-stack layout and its workspace-local state.
require("lua.master_stack")

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
            size = 12,
            passes = 2,
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
hl.env("PATH", profileBin .. ":" .. localBin .. ":/usr/local/bin:/usr/bin:/usr/games:/bin")

-- Animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.animation({ leaf = "global", enabled = true, speed = 1, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slidevert" })

-- Quickshell provides both the shell and notification service. Long-running
-- direct commands replace their launch shell with exec to avoid idle wrappers.
hl.on("hyprland.start", function()
    hl.exec_cmd("exec quickshell --no-duplicate")
    hl.exec_cmd("exec /usr/games/steam -silent")
    hl.exec_cmd("exec wlsunset -l 34 -L -104")
    hl.exec_cmd("exec kdeconnect-indicator")
    hl.exec_cmd("exec nm-applet")
    hl.exec_cmd("exec udiskie -t")
    hl.exec_cmd("exec " .. localBin .. "/wallpaper.sh")
    hl.exec_cmd("exec " .. localBin .. "/shadow-aware-swayidle")
    -- Keep clipboard contents after the source application exits and make any
    -- newly created history database private regardless of the session umask.
    hl.exec_cmd("umask 077; exec " .. profileBin .. "/wl-paste --type text --watch " .. profileBin .. "/cliphist store")
    hl.exec_cmd("umask 077; exec " .. profileBin .. "/wl-paste --type image --watch " .. profileBin .. "/cliphist store")
end)

-- Applications and utility actions
bind(mainMod .. " + T", "Open Foot terminal", hl.dsp.exec_cmd("exec foot"))
bind(mainMod .. " + P", "Open scratch editor", hl.dsp.exec_cmd("exec foot --title=scratch -e " .. localBin .. "/cm-edit.sh"))
bind(mainMod .. " + ALT + P", "Open Pi launcher", hl.dsp.exec_cmd("exec " .. localBin .. "/pi-tofi.sh"))
bind(mainMod .. " + M", "Toggle maximized window", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
bind(mainMod .. " + grave", "Open scratch shell", hl.dsp.exec_cmd("exec foot --title=scratch -e sh"))
bind(mainMod .. " + D", "Open application launcher", hl.dsp.exec_cmd("exec tofi-drun"))
bind(mainMod .. " + S", "Open Steam launcher", hl.dsp.exec_cmd("exec fish -c 'infisical-env steam -- " .. home .. "/git/fuzzel-steam-launcher/tofi-steam.sh'"))
bind(mainMod .. " + SHIFT + S", "Open SSH host picker", hl.dsp.exec_cmd("exec " .. localBin .. "/host-picker"))
bind(mainMod .. " + SHIFT + T", "Open Thunderbird", hl.dsp.exec_cmd("exec thunderbird"))
bind(mainMod .. " + B", "Open Firefox", hl.dsp.exec_cmd("exec firefox"))
bind(mainMod .. " + SHIFT + B", "Open Beeper", hl.dsp.exec_cmd("exec " .. home .. "/Applications/Communication/beeper.AppImage"))
bind(mainMod .. " + G", "Launch Shadow PC", hl.dsp.exec_cmd("exec " .. localBin .. "/launch-shadowtech.sh"))
bind("SUPER + ALT + L", "Lock the session", hl.dsp.exec_cmd("exec " .. lockCommand), { dont_inhibit = true })

-- Audio and media. Toggle actions deliberately do not repeat.
bind("XF86AudioRaiseVolume", "Raise output volume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Lower output volume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
bind("XF86AudioMute", "Toggle output mute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
bind("XF86AudioMicMute", "Toggle microphone mute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
bind("XF86AudioNext", "Play next track", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind("XF86AudioPause", "Toggle media playback", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPlay", "Toggle media playback", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", "Play previous track", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Focus, movement, and workspaces
bind(mainMod .. " + Q", "Close active window", hl.dsp.window.close())
for _, key in ipairs({ "left", "down", "up", "right" }) do
    bind(mainMod .. " + " .. key, "Focus window " .. key, hl.dsp.focus({ direction = key }))
end
bind(mainMod .. " + H", "Focus window left", hl.dsp.focus({ direction = "left" }))
-- Explicit stack selection avoids directional-focus ambiguity caused by the
-- overlapping stack cards. Selecting a stack item also recenters the stack.
bind(mainMod .. " + J", "Select next stack window", hl.dsp.layout("select next"))
bind(mainMod .. " + K", "Select previous stack window", hl.dsp.layout("select previous"))
bind(mainMod .. " + L", "Focus window right", hl.dsp.focus({ direction = "right" }))
bind("ALT + TAB", "Focus previously active window", hl.dsp.focus({ last = true }))

for i = 1, 9 do
    bind(mainMod .. " + " .. i, "Focus workspace " .. i, hl.dsp.focus({ workspace = i }))
    bind(mainMod .. " + CTRL + " .. i, "Move window to workspace " .. i, hl.dsp.window.move({ workspace = i }))
end
bind(mainMod .. " + 0", "Focus workspace 10", hl.dsp.focus({ workspace = 10 }))
bind(mainMod .. " + CTRL + 0", "Move window to workspace 10", hl.dsp.window.move({ workspace = 10 }))
-- Niri-like monitor-local workspace navigation. Existing workspaces are
-- traversed by ID; moving down past the last one creates the next empty
-- workspace on this monitor. Focus and window-move variants share semantics.
local function verticalWorkspaceTarget(direction)
    local monitor = hl.get_active_monitor()
    if not monitor then
        return
    end

    local current = hl.get_active_workspace(monitor)
    if not current then
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

    for index, workspace in ipairs(workspaces) do
        if workspace.id == current.id then
            local target = workspaces[index + direction]
            if target then
                return target.id
            end
            if direction > 0 then
                return "emptynm"
            end
            return
        end
    end
end

local function focusVerticalWorkspace(direction)
    local target = verticalWorkspaceTarget(direction)
    if target then
        hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
end

local function moveWindowVerticalWorkspace(direction)
    local target = verticalWorkspaceTarget(direction)
    if target then
        hl.dispatch(hl.dsp.window.move({ workspace = target }))
    end
end

bind(mainMod .. " + PAGE_DOWN", "Focus next monitor-local workspace", function() focusVerticalWorkspace(1) end)
bind(mainMod .. " + PAGE_UP", "Focus previous monitor-local workspace", function() focusVerticalWorkspace(-1) end)
bind(mainMod .. " + U", "Focus next monitor-local workspace", function() focusVerticalWorkspace(1) end)
bind(mainMod .. " + I", "Focus previous monitor-local workspace", function() focusVerticalWorkspace(-1) end)
bind(mainMod .. " + CTRL + PAGE_DOWN", "Move window to next monitor-local workspace", function() moveWindowVerticalWorkspace(1) end)
bind(mainMod .. " + CTRL + PAGE_UP", "Move window to previous monitor-local workspace", function() moveWindowVerticalWorkspace(-1) end)
bind(mainMod .. " + CTRL + U", "Move window to next monitor-local workspace", function() moveWindowVerticalWorkspace(1) end)
bind(mainMod .. " + CTRL + I", "Move window to previous monitor-local workspace", function() moveWindowVerticalWorkspace(-1) end)
bind(mainMod .. " + mouse_down", "Focus next monitor-local workspace", function() focusVerticalWorkspace(1) end)
bind(mainMod .. " + mouse_up", "Focus previous monitor-local workspace", function() focusVerticalWorkspace(-1) end)
bind(mainMod .. " + CTRL + mouse_down", "Move window to next monitor-local workspace", function() moveWindowVerticalWorkspace(1) end)
bind(mainMod .. " + CTRL + mouse_up", "Move window to previous monitor-local workspace", function() moveWindowVerticalWorkspace(-1) end)

for _, dir in ipairs({ "left", "down", "up", "right" }) do
    bind(mainMod .. " + SHIFT + " .. dir, "Focus monitor " .. dir, hl.dsp.focus({ monitor = dir }))
    bind(mainMod .. " + CTRL + SHIFT + " .. dir, "Move window to monitor " .. dir, hl.dsp.window.move({ monitor = dir }))
end
bind(mainMod .. " + SHIFT + H", "Focus monitor left", hl.dsp.focus({ monitor = "l" }))
bind(mainMod .. " + SHIFT + J", "Focus monitor down", hl.dsp.focus({ monitor = "d" }))
bind(mainMod .. " + SHIFT + K", "Focus monitor up", hl.dsp.focus({ monitor = "u" }))
bind(mainMod .. " + SHIFT + L", "Focus monitor right", hl.dsp.focus({ monitor = "r" }))
bind(mainMod .. " + CTRL + SHIFT + H", "Move window to monitor left", hl.dsp.window.move({ monitor = "l" }))
bind(mainMod .. " + CTRL + SHIFT + J", "Move window to monitor down", hl.dsp.window.move({ monitor = "d" }))
bind(mainMod .. " + CTRL + SHIFT + K", "Move window to monitor up", hl.dsp.window.move({ monitor = "u" }))
bind(mainMod .. " + CTRL + SHIFT + L", "Move window to monitor right", hl.dsp.window.move({ monitor = "r" }))

-- Window actions
bind(mainMod .. " + F", "Toggle fullscreen", hl.dsp.window.fullscreen({ action = "toggle" }))
bind(mainMod .. " + SHIFT + F", "Exit fullscreen", hl.dsp.window.fullscreen({ action = "unset" }))
bind(mainMod .. " + V", "Toggle floating window", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + SHIFT + V", "Open clipboard history", hl.dsp.exec_cmd(profileBin .. "/cliphist list | tofi --prompt-text clipboard | " .. profileBin .. "/cliphist decode | " .. profileBin .. "/wl-copy"))
bind(mainMod .. " + minus", "Shrink window width", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
bind(mainMod .. " + equal", "Grow window width", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
bind(mainMod .. " + SHIFT + minus", "Shrink window height", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
bind(mainMod .. " + SHIFT + equal", "Grow window height", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
bind(mainMod .. " + O", "Toggle overview workspace", hl.dsp.workspace.toggle_special("overview"))
bind(mainMod .. " + SHIFT + E", "Exit Hyprland", hl.dsp.exit())
bind("CTRL + ALT + delete", "Exit Hyprland", hl.dsp.exit())

local dpmsTimer
local function lockAndPowerOffDisplays()
    hl.exec_cmd("exec " .. lockCommand)
    if dpmsTimer then
        dpmsTimer:set_enabled(false)
    end
    dpmsTimer = hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "disable" }))
        dpmsTimer = nil
    end, { timeout = 1000, type = "oneshot" })
end

bind(mainMod .. " + SHIFT + P", "Lock and power off displays", lockAndPowerOffDisplays, { dont_inhibit = true })

-- Keyboard navigation selects a stack item and automatically scrolls it into
-- view. Mouse scrolling remains focus-neutral.
bind(mainMod .. " + ALT + H", "Focus master window", hl.dsp.layout("select master"))
bind(mainMod .. " + ALT + J", "Select next stack window", hl.dsp.layout("select next"))
bind(mainMod .. " + ALT + K", "Select previous stack window", hl.dsp.layout("select previous"))
bind(mainMod .. " + CTRL + J", "Move stack window down", hl.dsp.layout("reorder down"))
bind(mainMod .. " + CTRL + K", "Move stack window up", hl.dsp.layout("reorder up"))
bind(mainMod .. " + ALT + R", "Reset stack scroll", hl.dsp.layout("reset"))
bind(mainMod .. " + ALT + Return", "Promote active window to master", hl.dsp.layout("promote"))
bind(mainMod .. " + ALT + mouse_down", "Scroll window stack down", hl.dsp.layout("scroll down"))
bind(mainMod .. " + ALT + mouse_up", "Scroll window stack up", hl.dsp.layout("scroll up"))
bind(mainMod .. " + mouse:272", "Drag active window", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", "Resize active window", hl.dsp.window.resize(), { mouse = true })

-- Screenshots using the installed grim/slurp tools.
bind(mainMod .. " + F12", "Capture all outputs", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))
bind(mainMod .. " + CTRL + F12", "Capture selected output", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp -o)\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))
bind(mainMod .. " + ALT + F12", "Capture selected region", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))

-- Window rules
local function rule(name, match, effects)
    effects.name = name
    effects.match = match
    hl.window_rule(effects)
end

rule("steam-toast-no-focus", { class = "^(steam)$", title = "^notificationtoasts_[0-9]+_desktop$" }, { no_focus = true, float = true })
rule("unfocused-opacity", { focus = false }, { opacity = "0.9 override 0.9 override" })
rule("media-opacity", { title = "^(▶.*|Netflix.*)$" }, { opacity = "1.0 override 1.0 override" })
rule("firefox-picture-in-picture", { class = "^(firefox|firefox-dev)$", title = "^Picture-in-Picture$" }, { float = true, size = "50% 50%", move = "50% 50%" })
rule("scratch-terminal", { title = "^scratch$" }, { float = true, size = "40% 40%" })
rule("termdown", { title = "^termdown$" }, { float = true, size = "20% 20%", move = "79% 1%" })
rule("vlc-floating", { class = "^(vlc)$" }, { float = true })
rule("chrome-floating", { class = "^(chrome-nngceckbapebfimnlniiiahkandclblb-Default)$" }, { float = true })
rule("thunar-progress", { class = "^(thunar)$", title = "^File Operation Progress$" }, { float = true })
rule("fladder", { class = "^(Fladder)$" }, { float = true, workspace = "3", monitor = "DP-1", maximize = true })
rule("mpv-popup", { class = "^(mpv)$" }, { float = true, size = "20% 20%", move = "79% 1%", immediate = true })
rule("mpv-otmpv", { class = "^(mpv)$", title = "^otmpv$" }, { move = "79% 58%" })
rule("mpv-streamers", { class = "^(mpv)$", title = "^Streamers$" }, { move = "79% 35%" })
-- Keep all Thunderbird windows out of the master-stack layout. Thunderbird
-- opens compose/reply windows separately and their titles change after opening.
rule("thunderbird-floating", { class = "^(thunderbird)$" }, { float = true })
rule("thunderbird-reminders", { class = "^(thunderbird|thunderbird-beta)$", title = "^Reminders$" }, { float = true, size = "30% 30%" })
