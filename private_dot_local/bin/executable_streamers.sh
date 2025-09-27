
# ...keep your header and variables...

# helper unchanged...

while :; do
  notify-send -t 5000 "Starting streamers cycle" || true

  # strip comments/blank lines, trim, remove optional quotes, and remove trailing CR
  mapfile -t streamers < <(
    awk '
      /^[[:space:]]*(#|$)/ { next }                    # skip comments/blank
      { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0) }  # trim
      { sub(/^"/, "", $0); sub(/"$/, "", $0) }         # strip outer quotes
      { sub(/\r$/, "", $0) }                           # drop trailing CR
      NF { print }
    ' "$LIST"
  )

  job_count=0  # reset each cycle

  for i in "${streamers[@]}"; do
    url="$i"
    [[ "$url" =~ ^https?:// ]] || url="https://$url"

    lock="$(lock_path "$url")"
    if mkdir "$lock" 2>/dev/null; then
      (
        trap 'rm -rf "$lock" 2>/dev/null || true' EXIT
        printf '%s\n' "$url" > "$lock/streaming_url.txt"
        yt-dlp -S "res:720,ext" \
               -o "$HOME/plex/Streamers/%(webpage_url_domain)s_%(title)s.%(ext)s" \
               --no-continue --no-part -- "$url"
      ) &
      ((job_count++))
      if (( job_count >= max_jobs )); then
        # Always free a slot, even if the child failed
        wait -n || true
        ((job_count--))
      fi
    fi
    sleep 5
  done

  # Drain remaining jobs — always decrement
  while (( job_count > 0 )); do
    wait -n || true
    ((job_count--))
  done

  sleep 60m
done

