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

# Resolve chezmoi's *source* path so you edit the managed file, not the live one.
if src_path=$(chezmoi source-path "$target" 2>/dev/null); then
  edit_path="$src_path"
else
  # Fallback: edit the target directly if for some reason it's not managed
  edit_path="$target"
fi

# Choose a "normal" terminal to spawn
term="${TERMINAL:-alacritty}"

if ! command -v "$term" >/dev/null 2>&1; then
  for t in ghostty foot alacritty urxvt xterm; do
    if command -v "$t" >/dev/null 2>&1; then
      term="$t"
      break
    fi
  done
fi

# Spawn Neovim in a new terminal window, detached from the scratch terminal
setsid -f "$term" -e nvim "$edit_path" >/dev/null 2>&1 &

sleep 0.5

