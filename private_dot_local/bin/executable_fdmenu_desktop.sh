
#!/usr/bin/env bash
set -euo pipefail

# Optional: force cache rebuild
force_rebuild="${1-}"

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

# Build a quick signature from directory mtimes (fast; updates on create/delete/rename).
build_sig() {
  for d in "${find_args[@]}"; do
    # "%Y %n" => epoch_mtime + path
    stat -c '%Y %n' "$d" 2>/dev/null || printf '0 %s\n' "$d"
  done
}

current_sig="$(build_sig | sort)"
# Hash keeps sig file compact and comparable
current_sig_hash="$(printf '%s' "$current_sig" | sha256sum | cut -d' ' -f1)"

need_rebuild=true
if [[ -f "$cache_entries" && -s "$cache_entries" && -f "$cache_sig" && -s "$cache_sig" && "$force_rebuild" != "--rebuild" ]]; then
  saved_hash="$(cut -d' ' -f1 < "$cache_sig" 2>/dev/null || true)"
  if [[ "$saved_hash" == "$current_sig_hash" ]]; then
    need_rebuild=false
  fi
fi

# --- Rebuild cache if needed -------------------------------------------------
if "$need_rebuild"; then
  tmp_entries="$(mktemp)"
  # Collect entries as "Name\tCommand"
  while IFS= read -r -d '' file; do
    case $file in
      *.desktop)
        name=''
        exec=''
        in_section=false
        # Only parse [Desktop Entry] section for Name/Exec (avoids translations & junk)
        while IFS= read -r line; do
          [[ $line == \[*\] ]] && in_section=false
          [[ $line == "[Desktop Entry]" ]] && in_section=true
          $in_section || continue
          case $line in
            Name=*) name=${line#Name=} ;;
            Exec=*) exec=${line#Exec=} ;;
          esac
          [[ $name && $exec ]] && break
        done < "$file"
        # Remove placeholders like %f, %u, etc.
        exec=${exec//%[fFuUdDnNickvm]/}
        # Trim trailing spaces left by placeholder removal
        exec=${exec%%+([[:space:]])}
        if [[ $name && $exec ]]; then
          printf '%s\t%s\n' "$name" "$exec" >>"$tmp_entries"
        fi
        ;;
      *.AppImage|*.sh)
        name=$(basename "$file")
        printf '%s\t%s\n' "$name" "$file" >>"$tmp_entries"
        ;;
    esac
  done < <(fd -0 -t f -t l -e desktop -e sh -e AppImage . "${find_args[@]}" 2>/dev/null || true)

  # If nothing found, write empty cache and continue (script will handle it)
  : > "$cache_entries"
  if [[ -s "$tmp_entries" ]]; then
    # Deduplicate by name, keep first occurrence
    awk -F'\t' '!seen[$1]++' "$tmp_entries" > "$cache_entries"
  fi
  rm -f "$tmp_entries"

  # Save signature hash (first line) and a readable copy (below) for debugging
  {
    printf '%s  dirs-mtime-hash\n' "$current_sig_hash"
    printf '# dirs mtime snapshot:\n%s\n' "$current_sig"
  } > "$cache_sig"
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
  nohup setsid sh -c "$cmd" >/dev/null 2>&1 &
  sleep 0.2
done


