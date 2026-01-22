#!/bin/env bash
set -euo pipefail

editor_dir="$HOME/Applications/Productivity"

editor="${1:-nvim}"

file="$(chezmoi managed --include=files --path-style=absolute --source-path | sk --preview="bat {}" --preview-window right:30%)"
file="$(chezmoi source-path "$file")"

if [ -n "$file" ]; then
    # "$editor" "$file"
    basename "$file"
fi
