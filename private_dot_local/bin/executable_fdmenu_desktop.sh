#!/usr/bin/env bash
set -euo pipefail

source ~/.config/sk_options.sh

# Ensure required commands are available
for cmd in sk fd; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf '%s command not found. Please install %s to use this script.\n' "$cmd" "$cmd" >&2
    exit 1
  fi
done

search_dirs=(
  "$HOME/.local/bin"
  "$HOME/.local/share/applications"
  "$HOME/Applications"
  "$HOME/pg4uk-f7ecq/Scripts"
  "/usr/share/applications"
)

# Filter to existing dirs so fd doesn't fail under `set -e`
find_args=()
for d in "${search_dirs[@]}"; do
  [[ -d "$d" ]] && find_args+=("$d")
done

# If nothing to search, bail early
if ((${#find_args[@]} == 0)); then
  printf 'No valid directories to search.\n' >&2
  exit 1
fi

# Collect entries as "Name\tCommand"
entries=()
while IFS= read -r -d '' file; do
  case $file in
    *.desktop)
      name=''
      exec=''
      while IFS= read -r line; do
        case $line in
          Name=*) name=${line#Name=} ;;
          Exec=*) exec=${line#Exec=} ;;
        esac
        [[ $name && $exec ]] && break
      done < "$file"
      # Remove placeholders like %f, %u, etc.
      exec=${exec//%[fFuUdDnNickvm]/}
      if [[ $name && $exec ]]; then
        entries+=("$name"$'\t'"$exec")
      fi
      ;;
    *.AppImage|*.sh)
      name=$(basename "$file")
      entries+=("$name"$'\t'"$file")
      ;;
  esac
done < <(fd -0 -t f -t l -e desktop -e sh -e AppImage . "${find_args[@]}" 2>/dev/null || true)

# If nothing found, exit cleanly
if ((${#entries[@]} == 0)); then
  printf 'No launchable entries found.\n' >&2
  exit 0
fi

# Present choices, deduplicating by name
selection=$(
  printf '%s\n' "${entries[@]}" |
  awk -F'\t' '!seen[$1]++' |
  sk --prompt="Run: " --ansi --with-nth=1 --delimiter=$'\t' || true
)

# User escaped or sk had no input
[[ -z "$selection" ]] && exit 0

# Extract command(s)
printf '%s\n' "$selection" | cut -f2 | while IFS= read -r cmd; do
  # Decide tweaks based on the program basename (first token)
  prog=${cmd%% *}
  prog_base=$(basename "$prog")

  case "$prog_base" in
    google-chrome*|vivaldi-stable|brave|chromium|opera)
      cmd="$cmd --ozone-platform=wayland"
      ;;
    ShadowPC.AppImage)
      cmd="gamescope -H 1080 -W 1920 -- $cmd"
      ;;
    *.sh)
      cmd="kitty --title=scratch $cmd"
      ;;
  esac

  # Launch detached from the picker terminal
  nohup setsid sh -c "$cmd" >/dev/null 2>&1 &
  sleep 0.2
done

