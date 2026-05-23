#!/bin/env bash

browsers=(
  "Chrome"
  "Edge"
  "Firefox"
  "Vivaldi"
)

set +u
source "$HOME/.myenv"
set -u

common_options="--ozone-platform=wayland --app=https://pc.shadow.tech"

browser=$(
  printf "%s\n" "${browsers[@]}" |
    fuzzel --dmenu --prompt "Select browser to launch ShadowTech: " --lines "${#browsers[@]}"
)

case "$browser" in
Edge)
  notify-send "Launching ShadowTech with Microsoft Edge..."
  setsid -w sh -c "microsoft-edge-stable $common_options" >/dev/null 2>&1 &
  ;;
Chrome)
  notify-send "Launching ShadowTech with Google Chrome..."
  # setsid -f sh -c "google-chrome-stable --ozone-platform=wayland --app=https://pc.shadow.tech" &
  setsid -w sh -c "chromium --app=https://pc.shadow.tech" >/dev/null 2>&1 &
  ;;
Vivaldi)
  notify-send "Launching ShadowTech with Vivaldi..."
  setsid -w sh -c "vivaldi-stable $common_options" >/dev/null 2>&1 &
  ;;
Firefox)
  notify-send "Launching ShadowTech with Firefox..."
  setsid -w sh -c "firefox --new-window https://pc.shadow.tech" >/dev/null 2>&1 &
  ;;
"")
  exit 0
  ;;
*)
  echo "Usage: $0 {chrome|edge|firefox|vivaldi}"
  exit 1
  ;;
esac

sleep 0.5

# gamescope -f -w 1920 -h 1080 -W 1920 -H 1080 --force-grab-cursor --backend sdl -- google-chrome-stable --app=https://pc.shadow.tech
#
