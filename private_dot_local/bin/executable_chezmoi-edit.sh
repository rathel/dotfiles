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
  : > "$target"                   # create empty file
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

# chezmoi source repo root (usually ~/.local/share/chezmoi)
repo_root="$(chezmoi source-path)"

# Get path relative to repo root for nicer git add/commit
if command -v realpath >/dev/null 2>&1; then
  rel_path="$(realpath --relative-to="$repo_root" "$edit_path")"
else
  rel_path="${edit_path#"$repo_root"/}"
fi

# --- choose a terminal explicitly to avoid surprises ---
# If you know you always want kitty, just hardcode it:
term="alacritty"

# If kitty isn't installed, fall back through a list
if ! command -v "$term" >/dev/null 2>&1; then
  for t in foot ghostty alacritty urxvt xterm; do
    if command -v "$t" >/dev/null 2>&1; then
      term="$t"
      break
    fi
  done
fi

# If we *still* don't have a terminal, bail with an error
if ! command -v "$term" >/dev/null 2>&1; then
  notify-send "No suitable terminal found for chezmoi edit."
  exit 1
fi

# --- build a small helper script that runs inside the new terminal ---
tmp_script="$(mktemp /tmp/chezmoi-edit-XXXXXX.sh)"

cat >"$tmp_script" <<EOF
#!/usr/bin/env bash
set -euo pipefail

cd "$repo_root"

# Edit the file
nvim "$rel_path"

# If no changes, don't commit
if git diff --quiet -- "$rel_path"; then
  echo "No changes to commit for $rel_path."
  read -rp "Press Enter to close..." _
  exit 0
fi

git add "$rel_path"

# You can tweak this commit message format
git commit -m "Update $rel_path" || {
  echo "git commit failed."
  read -rp "Press Enter to close..." _
  exit 1
}

# Push; if it fails, keep the window open so you can see why
if ! git push; then
  echo "git push failed."
  read -rp "Press Enter to close..." _
  exit 1
fi

echo "Done: committed and pushed $rel_path."
read -rp "Press Enter to close..." _
EOF

chmod +x "$tmp_script"

# Spawn the terminal running the helper script, detached from the scratch terminal
setsid -f "$term" -e "$tmp_script" >/dev/null 2>&1 &
