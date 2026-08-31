-- Hyprland 0.56 Lua configuration.
-- Migrated from hyprland.conf.legacy; the legacy file is kept for reference.

local mainMod = "SUPER"
local profileBin = "/home/rathel/.local/state/nix/profiles/profile/bin"

-- Monitors, input, and environment
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
        gaps_in = 10,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = "rgb(88c0d0)",
            inactive_border = "rgb(4c566a)",
        },
        layout = "dwindle",
        resize_on_border = true,
    },
    decoration = {
        rounding = 0,
        blur = {
            enabled = true,
            size = 30,
            passes = 3,
            new_optimizations = true,
        },
        shadow = { enabled = false },
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 0,
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
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slide" })

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
end)

-- Applications and utility actions
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("foot"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("foot --title=scratch -e /home/rathel/.local/bin/cm-edit.sh"))
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd("/home/rathel/.local/bin/pi-tofi.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("/home/rathel/.local/bin/launch-players.sh"))
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
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
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
hl.bind(mainMod .. " + U", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + I", hl.dsp.focus({ workspace = "e-1" }))
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
hl.bind(mainMod .. " + minus", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + equal", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind(mainMod .. " + O", hl.dsp.workspace.toggle_special("overview"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind("CTRL + ALT + delete", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprctl dispatch dpms off"))
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
rule("thunderbird-compose", { class = "^(thunderbird)$", title = "^Write:" }, { float = true })
rule("thunderbird-reminders", { class = "^(thunderbird-beta)$", title = "^Reminders$" }, { float = true, size = "30% 30%" })
