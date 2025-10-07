
#!/usr/bin/env bash
set -euo pipefail

# Allow missing variables while sourcing user env, then re-enable -u
set +u
if [ -f "$HOME/.myenv" ]; then 
	source "$HOME/.myenv"
fi
set -u

# --- Args ---------------------------------------------------------------------
force_rebuild=false
for arg in "$@"; do
  case "$arg" in
    -r|--rebuild) force_rebuild=true ;;
  esac
done

# --- Requirements -------------------------------------------------------------
for cmd in sk fd awk sha256sum stat findmnt; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf '%s command not found. Please install %s to use this script.\n' "$cmd" "$cmd" >&2
    exit 1
  fi
done

# --- Search roots -------------------------------------------------------------
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

# --- Cache setup --------------------------------------------------------------
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/sk-launch"
cache_entries="$cache_dir/entries.tsv"
cache_sig="$cache_dir/sig.txt"
mkdir -p "$cache_dir"

# Consider the cache "fresh" for this many seconds (skip sig/hash during that time)
: "${MAX_AGE_SEC:=10800}"   # 3 hours; tune to taste

# Detect whether a path is on NFS (fast)
is_nfs() {
  local fs
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

# --- Rebuild cache ------------------------------------------------------------
rebuild_cache() {
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  # 1) .desktop entries → "Label<TAB>Exec"
  #    - Iterate files (NUL-delimited) and parse [Desktop Entry] content
  fd -H -a -t f -e desktop -0 . -- "${find_args[@]}" \
  | while IFS= read -r -d '' f; do
      awk '
        BEGIN { inDE=0; name=""; exec=""; nodisp="false" }
        # Enter Desktop Entry section; leave on next [Section]
        /^\[Desktop Entry\]/ { inDE=1; next }
        /^\[/ && $0 !~ /^\[Desktop Entry\]/ { inDE=0; next }

        inDE && /^Name=/ && name==""     { sub(/^Name=/,""); name=$0 }
        inDE && /^Exec=/ && exec==""     { sub(/^Exec=/,""); exec=$0 }
        inDE && /^NoDisplay=/            { sub(/^NoDisplay=/,""); nodisp=tolower($0) }

        END {
          if (name != "" && exec != "" && nodisp != "true") {
            gsub(/%[fFuUikcDdNvm]/, "", exec);   # strip placeholders
            sub(/[[:space:]]+$/, "", exec);      # trim trailing spaces
            printf "%s\t%s\n", name, exec
          }
        }
      ' "$f"
    done >> "$tmp"


  # 2) Executables in user bins/scripts → "Label<TAB>Path"
  #    (fd -t x only lists executable files; avoids piling from /usr/share/applications)
  fd -H -a -t x . -- "$HOME/Applications" "$HOME/.local/bin" "$HOME/pg4uk-f7ecq/Scripts" 2>/dev/null \
    | awk '{cmd=$0; sub(/^.*\//,"",cmd); printf "%s\t%s\n", cmd, $0}' >> "$tmp" || true

  # 3) Dedup on label (first field), keep first occurrence
  awk -F '\t' '!seen[$1]++' "$tmp" > "$cache_entries"

  # 4) Save current signature hash (for non-NFS dirs)
  current_sig="$(build_sig | sort)"
  printf '%s  -\n' "$(printf '%s' "$current_sig" | sha256sum | cut -d" " -f1)" > "$cache_sig"
}

# --- Rebuild decision ---------------------------------------------------------
need_rebuild=true
current_time=$(date +%s)
cache_mtime=0
if [[ -f "$cache_entries" ]]; then
  cache_mtime=$(stat -c %Y "$cache_entries" 2>/dev/null || echo 0)
fi

if [[ $force_rebuild == false ]]; then
  # Fast path: age fresh -> skip sig/hash
  if [[ -s "$cache_entries" && $(( current_time - cache_mtime )) -lt $MAX_AGE_SEC ]]; then
    need_rebuild=false
  else
    # Compare signature for non-NFS dirs only
    current_sig="$(build_sig | sort)"
    current_sig_hash="$(printf '%s' "$current_sig" | sha256sum | cut -d' ' -f1)"
    if [[ -f "$cache_sig" && -s "$cache_sig" && -s "$cache_entries" ]]; then
      saved_hash="$(cut -d' ' -f1 < "$cache_sig" 2>/dev/null || true)"
      if [[ "$saved_hash" == "$current_sig_hash" ]]; then
        need_rebuild=false
      fi
    fi
  fi
fi

if [[ $need_rebuild == true ]]; then
  [[ $force_rebuild == true ]] && printf '[fdmenu] Forced rebuild.\n' >&2
  rebuild_cache
fi

# --- Load from cache ----------------------------------------------------------
if [[ ! -s "$cache_entries" ]]; then
  printf 'No launchable entries found.\n' >&2
  exit 0
fi

# --- Picker -------------------------------------------------------------------
selection=$(
  cat "$cache_entries" \
  | sk --prompt="Run: " --ansi --with-nth=1 --delimiter=$'\t' --no-sort || true
)

# User escaped or sk had no input
[[ -z "$selection" ]] && exit 0

# --- Launch selected commands -------------------------------------------------
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
  nohup setsid -f sh -c "$cmd" >/dev/null 2>&1 &
  sleep 0.2
done

