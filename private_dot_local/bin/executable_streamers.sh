
#!/usr/bin/env bash
# Streamers downloader with per-URL locks + concurrency control.

set -Eeuo pipefail
IFS=$'\n\t'

max_jobs=${MAX_JOBS:-2}
LIST=${LIST:-"$HOME/.config/streamers.txt"}
OUTDIR=${OUTDIR:-"$HOME/plex/Streamers"}

# Optional small delay before first cycle (kept from your script)
sleep 10 || true

command -v yt-dlp >/dev/null || {
  echo "Error: yt-dlp not found in PATH." >&2
  exit 1
}

mkdir -p "$OUTDIR"

lock_path() {
  local key="${1//\//_}"
  key="${key//:/_}"
  printf '/tmp/streamlock_%s.lock' "$key"
}

while :; do
  # reset concurrency counter *each* cycle
  job_count=0

  notify-send -t 3000 "Starting streamers cycle" >/dev/null 2>&1 || true

  if [[ ! -s "$LIST" ]]; then
    echo "Note: '$LIST' not found or empty; sleeping." >&2
    sleep 5m
    continue
  fi

  # Load & sanitize streamer URLs
  mapfile -t streamers < <(
    awk '
      /^[[:space:]]*(#|$)/ { next }                    # skip comments/blank
      { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0) }  # trim
      { sub(/^"/, "", $0); sub(/"$/, "", $0) }         # strip outer quotes
      NF { print }
    ' "$LIST"
  )

  # Nothing to do?
  ((${#streamers[@]})) || { sleep 5m; continue; }

  for raw in "${streamers[@]}"; do
    url="$raw"
    [[ "$url" =~ ^https?:// ]] || url="https://$url"

    lock="$(lock_path "$url")"

    # mkdir-as-lock (atomic on same filesystem)
    if mkdir "$lock" 2>/dev/null; then
      (
        trap 'rm -rf "$lock" 2>/dev/null || true' EXIT
        printf '%s\n' "$url" > "$lock/streaming_url.txt"

        # Choose best <=720p; fall back to whatever works
        # -S is sort; this prefers <=720 and a/v merge
        yt-dlp \
          -S "res:720,ext" \
          -o "$OUTDIR/%(webpage_url_domain)s_%(title)s.%(ext)s" \
          --no-continue --no-part \
          -- "$url"
      ) &

      ((job_count++))
      if (( job_count >= max_jobs )); then
        # Wait for *one* job to finish, then decrement
        if wait -n 2>/dev/null; then ((job_count--)); fi
      fi
    fi

    sleep 5
  done

  # Drain any remaining jobs and keep job_count honest
  if (( job_count > 0 )); then
    while wait -n 2>/dev/null; do
      ((job_count--))
      (( job_count == 0 )) && break
    done
  fi

  sleep 60m
done

