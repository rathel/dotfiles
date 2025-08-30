#!/usr/bin/env bash
set -Eeuo pipefail

# --- Helpers ---------------------------------------------------------------

get_volume_info() {
  # Example outputs:
  #   "Volume: 0.70"
  #   "Volume: 0.00 [MUTED]"
  local line
  line="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"

  # percent (rounded to nearest int)
  local val
  val="$(awk 'match($0, /([0-9]+\.[0-9]+)/, m){print m[1]}' <<<"$line")"
  local percent
  percent="$(awk -v v="${val:-0}" 'BEGIN{printf("%.0f", v*100)}')"

  # muted flag
  local muted=0
  grep -qi 'muted' <<<"$line" && muted=1

  printf "%s %s\n" "$percent" "$muted"
}

notify_volume() {
  local percent="$1"
  local muted="$2"

  local text icon
  if [[ "$muted" -eq 1 ]]; then
    text="Volume: muted"
    icon="audio-volume-muted"
  else
    text="Volume: ${percent}%"
    if   (( percent == 0 ));  then icon="audio-volume-muted"
    elif (( percent < 34 ));  then icon="audio-volume-low"
    elif (( percent < 67 ));  then icon="audio-volume-medium"
    else                          icon="audio-volume-high"
    fi
  fi

  # Hints:
  #  - string:synchronous groups notifications so they replace each other
  #  - int:value is used by some servers to show a slider
  notify-send -a "Volume" -i "$icon" \
    -h string:synchronous:volume \
    -h int:value:"${percent}" \
    "$text"
}

# --- Init ------------------------------------------------------------------

# Send an initial notification
read -r last_percent last_muted < <(get_volume_info)
notify_volume "$last_percent" "$last_muted"

# --- Monitor for changes ---------------------------------------------------

# Use pactl to subscribe to sink-related events; on each event, re-read via wpctl
pactl subscribe | stdbuf -oL grep --line-buffered -E "sink|server|card" | \
while IFS= read -r _; do
  read -r percent muted < <(get_volume_info)

  # Only notify when there is a change
  if [[ "$percent" != "$last_percent" || "$muted" != "$last_muted" ]]; then
    notify_volume "$percent" "$muted"
    last_percent="$percent"
    last_muted="$muted"
  fi
done

