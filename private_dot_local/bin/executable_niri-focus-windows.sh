#!/bin/bash
set -euo pipefail

set +u
source "$HOME/.myenv"
set -u

# Get JSON from niri
json=$(niri msg -j windows)

mapfile -t window_ids < <(jq -r '.[].id' <<<"$json")
mapfile -t window_labels < <(
  jq -r '.[] | [(.app_id // ""), (.title // "")] | @tsv' <<<"$json" |
    while IFS=$'\t' read -r app_id title; do
      printf '%s - %s\n' "${app_id:-Unknown}" "${title:-Untitled}"
    done
)

# Tofi prints the selected label rather than an index. Disambiguate duplicate
# labels so the selected label can still be mapped back to the window ID.
((${#window_ids[@]} > 0)) || exit 0
declare -A label_counts=()
for label in "${window_labels[@]}"; do
  label_counts["$label"]=$(( ${label_counts["$label"]:-0} + 1 ))
done

for i in "${!window_labels[@]}"; do
  label="${window_labels[i]}"
  if (( label_counts["$label"] > 1 )); then
    window_labels[i]="$label [window $((i + 1))]"
  fi
done

if ! selected_label=$(
  printf '%s\n' "${window_labels[@]}" |
    tofi \
      --prompt-text "Switch window: " \
      --num-results=15 \
      --fuzzy-match=true
); then
  exit 0
fi

[[ -n "$selected_label" ]] || exit 0

selected_id=
for i in "${!window_labels[@]}"; do
  if [[ "${window_labels[i]}" == "$selected_label" ]]; then
    selected_id="${window_ids[i]}"
    break
  fi
done

[[ -n "$selected_id" ]] || exit 1
niri msg action focus-window --id "$selected_id"
