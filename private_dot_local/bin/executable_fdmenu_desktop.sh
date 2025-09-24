#!/usr/bin/env bash
set -euo pipefail

set +u
source "$HOME/.myenv"
set -u

# Ensure required commands are available
for cmd in sk fd awk sha256sum stat; do
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

# --- Cache setup -------------------------------------------------------------
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/sk-launch"
cache_entries="$cache_dir/entries.tsv"
cache_sig="$cache_dir/sig.txt"
mkdir -p "$cache_dir"

# Consider the cache "fresh" for this many seconds (skip sig/hash during that time)
: "${MAX_AGE_SEC:=10800}"   # 3 hours; tune to taste

# Detect whether a path is on NFS (fast)
is_nfs() {
  # findmnt is quicker than parsing /proc/mounts repeatedly
  local p fs
  fs=$(findmnt -n -o FSTYPE --target "$1" 2>/dev/null || echo "")
  [[ "$fs" == nfs* ]]
}

# Build a signature from directory mtimes, but skip NFS mounts to avoid slow stats.
build_sig() {
  for d in "${find_args[@]}"; do
    if is_nfs "$d"; then
      printf 'NFS %s\n' "$d"
    else
      # "%Y %n" => epoch_mtime + path
      stat -c '%Y %n' "$d" 2>/dev/null || printf '0 %s\n' "$d"
    fi
  done
}

current_time=$(date +%s)
cache_mtime=0
if [[ -f "$cache_entries" ]]; then
  cache_mtime=$(stat -c %Y "$cache_entries" 2>/dev/null || echo 0)
fi

need_rebuild=true
force_rebuild="${force_rebuild:-}"

# 1) Fast path: cache still "fresh" by age → instant start
if [[ -s "$cache_entries" && -n "$cache_mtime" && $(( current_time - cache_mtime )) -lt $MAX_AGE_SEC && "$force_rebuild" != "--rebuild" ]]; then
  need_rebuild=false
else
  # 2) Otherwise, compare signature for non-NFS dirs only
  current_sig="$(build_sig | sort)"
  current_sig_hash="$(printf '%s' "$current_sig" | sha256sum | cut -d' ' -f1)"
  if [[ -f "$cache_sig" && -s "$cache_sig" && -s "$cache_entries" && "$force_rebuild" != "--rebuild" ]]; then
    saved_hash="$(cut -d' ' -f1 < "$cache_sig" 2>/dev/null || true)"
    if [[ "$saved_hash" == "$current_sig_hash" ]]; then
      need_rebuild=false
    fi
  fi
fi

# --- Load from cache ---------------------------------------------------------
if [[ ! -s "$cache_entries" ]]; then
  printf 'No launchable entries found.\n' >&2
  exit 0
fi

# Present choices (already deduped, but keep --with-nth for safety)
selection=$(
  cat "$cache_entries" |
  sk --prompt="Run: " --ansi --with-nth=1 --delimiter=$'\t' || true
)

# User escaped or sk had no input
[[ -z "$selection" ]] && exit 0

# Extract command(s) from selection (supports multi-select if enabled in sk config)
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
      cmd="alacritty --title=scratch $cmd"
      ;;
  esac

  # Launch detached from the picker terminal
  nohup setsid -f sh -c "$cmd" >/dev/null 2>&1 &
  sleep 0.2
done


