#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Chezmoi Interactive Editor
# 
# Fuzzy-find and edit chezmoi-managed files, with optional git commit/push.
# ============================================================================

# --- Configuration ---
PREFERRED_TERMINAL="alacritty"
FALLBACK_TERMINALS=(foot ghostty urxvt xterm)
EDITOR="${EDITOR:-nvim}"

# --- Helper Functions ---

die() {
    notify-send "Chezmoi Edit Error" "$1"
    echo "ERROR: $1" >&2
    exit 1
}

log() {
    echo "[chezmoi-edit] $*" >&2
}

# Select target file. Skim is preferred; Fuzzel is a simpler fallback.
select_target() {
    if ! command -v sk >/dev/null 2>&1; then
        if command -v fuzzel >/dev/null 2>&1; then
            chezmoi managed -p absolute -x dirs |
                fuzzel --dmenu --prompt='Edit: '
            return
        fi
        die "File picker required: install sk or fuzzel"
    fi

    local preview='cat {}'
    if command -v bat >/dev/null 2>&1; then
        preview='bat --color=always --style=plain {}'
    fi

    local -a lines
    mapfile -t lines < <(
        chezmoi managed -p absolute -x dirs |
        sk --ansi \
           --with-nth=-2,-1 \
           --delimiter='/' \
           --print-query \
           --prompt="Edit: " \
           --preview="$preview" \
           --preview-window='right:60%:wrap' || true
    )

    local query="${lines[0]:-}"
    local pick="${lines[1]:-}"

    # Prefer selection, fall back to query.
    echo "${pick:-$query}"
}

# Normalize path (expand ~, make absolute)
normalize_path() {
    local path="$1"
    
    # Expand tilde
    path="${path/#\~/$HOME}"
    
    # Make absolute if relative
    if [[ ! "$path" = /* ]]; then
        path="${HOME%/}/$path"
    fi
    
    echo "$path"
}

# Ensure the existing target is managed; never create or add files here.
ensure_managed() {
    local target="$1"

    if [[ ! -e "$target" ]]; then
        die "Refusing to create an unapproved file: $target"
    fi

    if ! chezmoi source-path "$target" >/dev/null 2>&1; then
        die "Target is not managed by chezmoi: $target"
    fi
}

# Get chezmoi source path for a managed target
get_source_path() {
    local target="$1"
    local src_path

    if ! src_path=$(chezmoi source-path "$target" 2>/dev/null); then
        die "Refusing to edit an unmanaged target: $target"
    fi

    if [[ "$src_path" == *.age ]]; then
        die "Encrypted targets must be edited with 'chezmoi edit': $target"
    fi

    echo "$src_path"
}

# Get relative path from repo root
get_relative_path() {
    local full_path="$1"
    local repo_root="$2"
    
    if command -v realpath >/dev/null 2>&1; then
        realpath --relative-to="$repo_root" "$full_path"
    else
        echo "${full_path#"$repo_root"/}"
    fi
}

# Find available terminal emulator
find_terminal() {
    # Check preferred terminal first
    if command -v "$PREFERRED_TERMINAL" >/dev/null 2>&1; then
        echo "$PREFERRED_TERMINAL"
        return 0
    fi
    
    # Fall back to alternatives
    for term in "${FALLBACK_TERMINALS[@]}"; do
        if command -v "$term" >/dev/null 2>&1; then
            log "Using fallback terminal: $term"
            echo "$term"
            return 0
        fi
    done
    
    return 1
}

# Create the edit script
create_edit_script() {
    local repo_root="$1"
    local rel_path="$2"
    local script_path
    
    script_path="$(mktemp /tmp/chezmoi-edit-XXXXXX.sh)"
    
    cat >"$script_path" <<'SCRIPT_EOF'
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$1"
REL_PATH="$2"
EDITOR="${EDITOR:-nvim}"

cd "$REPO_ROOT"

echo "Editing: $REL_PATH"
echo "----------------------------------------"

# Edit the file. Split the common `EDITOR="zed --wait"` form into argv.
read -r -a editor_cmd <<< "${EDITOR:-nvim}"
"${editor_cmd[@]}" "$REL_PATH"

# Check for changes
if git diff --quiet -- "$REL_PATH" && git diff --cached --quiet -- "$REL_PATH"; then
    echo ""
    echo "No changes detected."
    read -rp "Press Enter to close..." _
    exit 0
fi

# Show the diff without staging or publishing anything automatically.
echo ""
echo "Changes:"
echo "----------------------------------------"
git diff -- "$REL_PATH"
git diff --cached --stat -- "$REL_PATH"
echo ""

read -rp "Commit this change? [y/N] " commit_answer
if [[ ! "$commit_answer" =~ ^[Yy]$ ]]; then
    echo "Leaving changes uncommitted."
    read -rp "Press Enter to close..." _
    exit 0
fi

git add -- "$REL_PATH"
commit_msg="Update $REL_PATH"
if git commit --only -m "$commit_msg" -- "$REL_PATH"; then
    echo ""
    echo "✓ Committed successfully"
else
    echo ""
    echo "✗ Commit failed"
    read -rp "Press Enter to close..." _
    exit 1
fi

read -rp "Push this commit to origin? [y/N] " push_answer
if [[ "$push_answer" =~ ^[Yy]$ ]]; then
    if git push; then
        echo "✓ Successfully pushed changes"
    else
        echo "✗ Push failed - check your connection and permissions" >&2
        read -rp "Press Enter to close..." _
        exit 1
    fi
else
    echo "Commit kept locally; not pushed."
fi
read -rp "Press Enter to close..." _
SCRIPT_EOF
    
    chmod +x "$script_path"
    echo "$script_path"
}

# --- Main ---

main() {
    # Select target file
    local target
    target=$(select_target)
    [[ -z "$target" ]] && exit 0  # User cancelled
    
    # Normalize and ensure file exists
    target=$(normalize_path "$target")
    ensure_managed "$target"
    
    notify-send "Chezmoi Edit" "Opening $target"
    
    # Get paths
    local repo_root edit_path rel_path
    repo_root="$(chezmoi source-path)"
    edit_path=$(get_source_path "$target")
    rel_path=$(get_relative_path "$edit_path" "$repo_root")
    
    # Find terminal
    local terminal
    terminal=$(find_terminal) || die "No suitable terminal emulator found"
    
    # Create edit script
    local script_path
    script_path=$(create_edit_script "$repo_root" "$rel_path")
    
    # Clean up script on exit
    trap "rm -f '$script_path'" EXIT
    
    # Launch terminal
    log "Launching $terminal"
    sleep 1
    setsid -f "$terminal" -e bash "$script_path" "$repo_root" "$rel_path" \
        >/dev/null 2>&1 &
}

main "$@"
