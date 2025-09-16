#!/usr/bin/env bash
set -euo pipefail

# Ensure required tools exist
for cmd in sk setsid; do
  command -v "$cmd" >/dev/null 2>&1 || { printf '%s not found.\n' "$cmd" >&2; exit 1; }
done

# Use literal tabs via $'...\t...' so --delimiter=$'\t' works
sites=(
  $'Amazon Prime Video\thttps://amazon.com/gp/video/storefront'
  $'Plex\thttps://app.plex.tv/desktop'
  $'Netflix\thttps://netflix.com'
  $'Spotify\thttps://spotify.com'
)

browsers=(
  $'Firefox\tfirefox'
  $'Chrome\tgoogle-chrome-stable'
  $'Microsoft Edge\tmicrosoft-edge-stable'
  $'Vivaldi\tvivaldi'
)

# Pick site and browser (escape tab in --delimiter)
selection="$(printf '%s\n' "${sites[@]}" | sk --with-nth=1 --delimiter=$'\t' || true)"
[[ -z "$selection" ]] && exit 0

browser_pick="$(printf '%s\n' "${browsers[@]}" | sk --with-nth=1 --delimiter=$'\t' || true)"
[[ -z "$browser_pick" ]] && exit 0

# Split "Label<TAB>Value" into fields
IFS=$'\t' read -r _site_label site_url <<<"$selection"
IFS=$'\t' read -r _browser_label browser_cmd <<<"$browser_pick"

# Optional: verify browser exists
if ! command -v "$browser_cmd" >/dev/null 2>&1; then
  printf 'Selected browser "%s" is not installed.\n' "$browser_cmd" >&2
  exit 1
fi

# Launch detached; pass args separately (no eval, no word-splitting surprises)
# Example: firefox kiosk profile (uncomment and adjust if desired)
# exec_cmd=( "$browser_cmd" -P kiosk --kiosk "$site_url" )
exec_cmd=( "$browser_cmd" --app="$site_url" )

setsid -f -- "${exec_cmd[@]}" >/dev/null 2>&1 &

sleep 2
