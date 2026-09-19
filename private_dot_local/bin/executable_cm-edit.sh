#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   cm-edit                 # pick a file in Tofi or Fuzzel, open it in Zed, and wait
#   cm-edit helix           # pick a file in Tofi or Fuzzel, open it in helix
#   cm-edit -- nvim         # pick a file in Tofi or Fuzzel, open it in nvim
#
# Tip: if you want to pass editor flags reliably, use:
#   cm-edit -- zed --wait

default_editor=(zed --wait)

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
  editor=("${default_editor[@]}")
fi

# Build a small, hand-editable list. Tofi selects one item, unlike sk's
# multi-select mode; Fuzzel is the fallback picker. Keep vendor/generated and
# presentation-only files out.
is_editable_target() {
  local target="$1"
  local source

  case "$target" in
    "$HOME"/.config/*|"$HOME"/.emacs.d/*|"$HOME"/.local/bin/*|"$HOME"/.pi/agent/*)
      ;;
    *)
      return 1
      ;;
  esac

  case "$target" in
    */themes/*|*/plugins/*|*/colors/*|*/assets/*|*/docs/*|*/tests/*|\
    */workflows/*|*/ISSUE_TEMPLATE/*|*/__pycache__/*|\
    *.md|*.age|*.gif|*.png|*.svg|*.webp|*.pyc|*/.keep)
      return 1
      ;;
  esac

  # Never open an encrypted chezmoi source directly in Zed.
  source="$(chezmoi source-path "$target" 2>/dev/null)" || return 1
  [[ "$source" != *.age ]]
}

candidates=()
while IFS= read -r target; do
  if is_editable_target "$target"; then
    candidates+=("$target")
  fi
done < <(chezmoi managed --include=files --path-style=absolute)

((${#candidates[@]} > 0)) || {
  printf 'No editable chezmoi files found.\n' >&2
  exit 1
}

display_targets=()
for target in "${candidates[@]}"; do
  display_targets+=("~${target#"$HOME"}")
done

picker=()
if command -v tofi >/dev/null 2>&1; then
  picker=(tofi --prompt-text 'edit: ' --require-match=true --fuzzy-match=true)
elif command -v fuzzel >/dev/null 2>&1; then
  picker=(fuzzel --dmenu --prompt 'edit: ')
else
  printf 'cm-edit: either tofi or fuzzel is required.\n' >&2
  exit 1
fi

if ! selected_display=$(
  printf '%s\n' "${display_targets[@]}" |
    "${picker[@]}"
); then
  # Escape cancels the picker.
  exit 0
fi

[[ -n "$selected_display" ]] || exit 0
target="${selected_display/#\~/$HOME}"

# Convert the selected target path to its chezmoi source path.
sources=()
filenames=()
src="$(chezmoi source-path "$target")"
if [[ ! -e "$src" ]]; then
  printf 'Refusing to edit missing chezmoi source: %s\n' "$src" >&2
  exit 1
fi
sources+=("$src")
filenames+=("$(basename "$target")")

# Open editor with the selected source file
"${editor[@]}" "${sources[@]}"

# Offer to commit, push, and apply the selected source paths only if they changed.
if ! chezmoi git -- diff --quiet --cached -- "${sources[@]}" ||
  ! chezmoi git -- diff --quiet -- "${sources[@]}"; then
  printf 'Changed source: %s\n' "${sources[*]}"
  read -r -p "Commit this change? [y/N] " commit_answer
  if [[ "$commit_answer" =~ ^[Yy]$ ]]; then
    chezmoi git -- commit --only -m "${filenames[*]}" -- "${sources[@]}"

    read -r -p "Push this commit to origin? [y/N] " push_answer
    if [[ "$push_answer" =~ ^[Yy]$ ]]; then
      chezmoi git -- push
    fi

    read -r -p "Apply the change now? [y/N] " apply_answer
    if [[ "$apply_answer" =~ ^[Yy]$ ]]; then
      chezmoi apply
    fi
  else
    printf 'Leaving the change uncommitted and unapplied.\n'
  fi
fi
