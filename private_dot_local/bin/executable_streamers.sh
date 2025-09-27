#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

max_jobs=${MAX_JOBS:-2}
LIST=${LIST:-"$HOME/.config/streamers.txt"}
OUTDIR=${OUTDIR:-"$HOME/plex/Streamers"}
LOG=${LOG:-"$HOME/.local/share/streamers.log"}

sleep 2 || true
mkdir -p "$OUTDIR" "$(dirname "$LOG")"

log(){ printf '%s %s\n' "$(date -Is)" "$*" | tee -a "$LOG" >&2; }

lock_path() {
  local key="${1//\//_}"; key="${key//:/_}"
  printf '/tmp/streamlock_%s.lock' "$key"
}

# 1) Clean stale locks (older than 2h) so we don't silently skip URLs forever
find /tmp -maxdepth 1 -type d -name 'streamlock_*.lock' -mmin +120 -print -exec rm -rf {} + 2>/dev/null || true

while :; do
  log "== New cycle start (max_jobs=$max_jobs) =="

  if [[ ! -e "$LIST" ]]; then
    log "List '$LIST' missing; sleeping 60s"
    sleep 60
    continue
  fi

  # 2) Load + sanitize list and strip trailing CRs
  mapfile -t streamers < <(
    awk '
      /^[[:space:]]*(#|$)/ { next }
      { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0) }
      { sub(/^"/, "", $0); sub(/"$/, "", $0) }
      { sub(/\r$/, "", $0) }
      NF { print }
    ' "$LIST"
  )

  if ((${#streamers[@]}==0)); then
    log "No entries in '$LIST' after cleaning; sleeping 60s"
    sleep 60
    continue
  fi

  log "Loaded ${#streamers[@]} URLs:"
  for u in "${streamers[@]}"; do log "  - $u"; done

  job_count=0

  for raw in "${streamers[@]}"; do
    url="$raw"; [[ "$url" =~ ^https?:// ]] || url="https://$url"
	if ! yt-dlp -J --skip-download -- "$url" >/dev/null 2>&1; then
	  log "OFFLINE: $url"
	  sleep 1
	  continue
	fi
    lock="$(lock_path "$url")"

    # Show why we skip
    if [[ -e "$lock" ]]; then
      log "SKIP (locked): $url -> $lock"
      continue
    fi

    if mkdir "$lock" 2>/dev/null; then
      log "START: $url (lock=$lock) | active=$job_count"
      (
        trap 'rm -rf "$lock" 2>/dev/null || true' EXIT
        printf '%s\n' "$url" > "$lock/streaming_url.txt"

        # 3) Print the resolved file name to the log even if download fails
        yt-dlp \
          -S "res:720,ext" \
          -o "$OUTDIR/%(webpage_url_domain)s_%(title)s.%(ext)s" \
          --no-continue --no-part \
	  -i --ignore-no-formats-error \
	  --retries 3 --fragment-retries 3 \
          --print before_dl:"DL: %(webpage_url_domain)s | %(title).80s" \
          --print after_move:"SAVED: %(filepath)s" \
          --no-warnings --restrict-filenames \
          -- "$url"
      ) >>"$LOG" 2>&1 &

      ((job_count++))
      if (( job_count >= max_jobs )); then
        log "CAP reached ($job_count). Waiting for a slot…"
        # 4) Always free a slot regardless of child exit code
        wait -n || true
        ((job_count--))
        log "Slot freed. active=$job_count"
      fi
    else
      log "SKIP (mkdir lock failed): $url (lock exists?)"
    fi

    sleep 1
  done

  # Drain remaining jobs
  while (( job_count > 0 )); do
    log "Draining… active=$job_count"
    wait -n || true
    ((job_count--))
  done

  log "Cycle complete. Sleeping 5m…"
  sleep 5m
done

