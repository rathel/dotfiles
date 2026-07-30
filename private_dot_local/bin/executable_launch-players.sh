#!/usr/bin/env bash

set -euo pipefail

jellyfin_url=${MEDIA_LAUNCHER_JELLYFIN_URL:-http://raspberrypi-plex:8096/web/}

notify_error() {
    if command -v notify-send >/dev/null 2>&1 &&
        notify-send --urgency=critical "Media launcher" "$1"; then
        return
    fi

    printf 'launch-players: %s\n' "$1" >&2
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        notify_error "Required command not found: $1"
        exit 1
    fi
}

for command in fuzzel xdg-open; do
    require_command "$command"
done

services=(
    "Netflix"
    "Amazon Prime Video"
    "Disney+"
    "Jellyfin"
)

urls=(
    "https://www.netflix.com/"
    "https://www.amazon.com/gp/video/storefront"
    "https://www.disneyplus.com/"
    "$jellyfin_url"
)

if ! service=$(printf '%s\n' "${services[@]}" | fuzzel --dmenu --only-match --prompt='Streaming service: '); then
    exit 0
fi

[[ -n $service ]] || exit 0

for index in "${!services[@]}"; do
    if [[ $service == "${services[$index]}" ]]; then
        if ! xdg-open "${urls[$index]}"; then
            notify_error "Failed to open ${services[$index]}"
            exit 1
        fi
        exit 0
    fi
done

notify_error "Invalid streaming service selection: $service"
exit 1
