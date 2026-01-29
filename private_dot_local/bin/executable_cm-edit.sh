#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   cm-edit                 # pick file(s), open in nvim
#   cm-edit helix           # pick file(s), open in helix
#   cm-edit code --wait     # pick file(s), open in VS Code and wait
#
# Tip: if you want to pass editor flags reliably, use:
#   cm-edit -- code --wait

default_editor="nvim"

# If user provides an editor command, use it. Support `--` to separate.
editor=()
if [[ "${1:-}" == "--" ]]; then
  shift
  # everything after -- is the editor command
  if [[ $# -gt 0 ]]; then
    editor=("$@")
  fi
else
  # if they pass anything, treat it as the editor command
  if [[ $# -gt 0 ]]; then
    editor=("$@")
  fi
fi

if [[ ${#editor[@]} -eq 0 ]]; then
  editor=("$default_editor")
fi

# Build the list (absolute target paths) and select (multi-select enabled with -m).
# We convert each target path to its chezmoi source path for editing.
mapfile -t selected < <(
  chezmoi managed --include=files --path-style=absolute \
  | sk -m --prompt='chezmoi> ' \
       --preview='chezmoi source-path {} | xargs -I{} sh -c "test -f \"{}\" && (bat --style=plain --color=always \"{}\" || sed -n \"1,200p\" \"{}\") || echo \"(no source file)\""' \
       --preview-window='right:60%'
)

# If user hit escape / no selection
[[ ${#selected[@]} -gt 0 ]] || exit 0

# Convert target path(s) -> source path(s)
sources=()
for target in "${selected[@]}"; do
  src="$(chezmoi source-path "$target")"
  sources+=("$src")
done

# Open editor with all selected source files
exec "${editor[@]}" "${sources[@]}"
