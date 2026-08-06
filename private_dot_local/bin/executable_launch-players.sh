#!/usr/bin/env bash

set -euo pipefail

jellyfin_url=${MEDIA_LAUNCHER_JELLYFIN_URL:-http://raspberrypi-plex:8096/web/}
icon_dir=${MEDIA_LAUNCHER_ICON_DIR:-"$HOME/.local/share/icons/media-launcher"}

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
    "Amazon Prime Video"
    "Apple TV+"
    "Disney+"
    "Jellyfin"
    "Netflix"
    "Plex"
    "Spotify"
    "YouTube"
)

urls=(
    "https://www.amazon.com/gp/video/storefront"
    "https://tv.apple.com/"
    "https://www.disneyplus.com/"
    "$jellyfin_url"
    "https://www.netflix.com/"
    "https://app.plex.tv/desktop/"
    "https://open.spotify.com/"
    "https://www.youtube.com/"
)

icons=(
    "$icon_dir/amazon-prime.svg,amazon,amazon-store,web-browser"
    "$icon_dir/apple-tv-plus.svg,apple-tv,video-display,web-browser"
    "$icon_dir/disney-plus.svg,applications-multimedia,web-browser"
    "$icon_dir/jellyfin.svg,jellyfin,multimedia-video-player"
    "$icon_dir/netflix.svg,netflix,web-browser"
    "$icon_dir/plex.svg,plex,multimedia-video-player"
    "$icon_dir/spotify.svg,spotify,spotify-client,multimedia-audio-player"
    "$icon_dir/youtube.svg,youtube,youtube-web,web-browser"
)

print_menu_entries() {
    local index

    for index in "${!services[@]}"; do
        printf '%s\0icon\x1f%s\n' "${services[$index]}" "${icons[$index]}"
    done
}

if ! selected_index=$(
    print_menu_entries |
        fuzzel --dmenu --only-match --index --minimal-lines --lines="${#services[@]}" --prompt='Streaming service: '
); then
    exit 0
fi

if [[ ! $selected_index =~ ^[0-9]+$ ]] || ((selected_index >= ${#services[@]})); then
    notify_error "Invalid streaming service index: $selected_index"
    exit 1
fi

if ! xdg-open "${urls[$selected_index]}"; then
    notify_error "Failed to open ${services[$selected_index]}"
    exit 1
fi
