#!/usr/bin/env bash
set -euo pipefail

set +u
source "$HOME/.myenv"
set -u

# Let sk print the query (what you typed) and the actual selection (what you chose).
# If you choose nothing but type a path, we'll use the query as the target.
mapfile -t lines < <(chezmoi managed -p absolute -x dirs | sk --ansi --with-nth=-2,-1 --delimiter='/' --print-query --prompt="Edit: ")
query="${lines[0]:-}"
pick="${lines[1]:-}"

# Prefer a selected item; otherwise fall back to the typed query.
target="${pick:-$query}"

# If still empty (Esc with no query), bail.
[ -z "${target}" ] && exit 1

# Expand leading ~ if user typed it
case "$target" in
  "~/"*) target="${HOME}/${target#~/}" ;;
esac

# If it's relative (no leading /), make it relative to $HOME
case "$target" in
  /*) ;;                        # absolute already
  *)  target="${HOME%/}/$target" ;;
esac

# Create and add only if it doesn't exist yet
if [ ! -e "$target" ]; then
  mkdir -p "$(dirname "$target")"
  : > "$target"                   # create empty file atomically-ish
  chezmoi add "$target"
fi

notify-send "Editing $target."
# Launch editor detached; chezmoi edit works whether newly-added or already-managed

setsid -f chezmoi edit "$target" >/dev/null 2>&1 &

sleep 0.5

