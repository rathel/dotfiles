#!/usr/bin/env bash

sleep 10

set -Eeuo pipefail
IFS=$'\n\t'

LIST="$HOME/.config/streamers.txt"

# Turn a URL into a safe, unique-ish lock path
lock_path() {
	# human-readable: replace / : with _
	local key="${1//\//_}"
	key="${key//:/_}"
	printf '/tmp/streamlock_%s.lock' "$key"
}

while :; do
	notify-send -t 5000 "Starting streamers cycle" || true
	# Load/clean list each cycle: strip comments/blank lines and optional surrounding quotes
	mapfile -t streamers < <(
		awk '
		/^[[:space:]]*(#|$)/ { next }                            # skip comments/blank
			{ gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0) }          # trim
			{ sub(/^"/, "", $0); sub(/"$/, "", $0) }                 # strip outer quotes
			NF { print }
			' "$LIST"
		)

		for i in "${streamers[@]}"; do
			# Prepend scheme if missing
			url="$i"
			[[ "$url" =~ ^https?:// ]] || url="https://$url"

			lock="$(lock_path "$url")"
			# atomic lock using mkdir
			if mkdir "$lock" 2>/dev/null; then
				# notify-send -t 5000 "Streaming: ${url##*/}" || true
				(
					# on exit, remove lock no matter what
					trap 'rm -fr "$lock" 2>/dev/null || true' EXIT
					echo "$url" > "$lock/streaming_url.txt"
					# nohup mpv --no-terminal --title="Streamers" -- "$url" &
					yt-dlp -S "res:720" -o "$HOME/plex/Streamers/%(webpage_url_domain)s_%(title)s.%(ext)s" -- "$url"
					) &
			fi
		done

   sleep 5

done

sleep 60m
done
