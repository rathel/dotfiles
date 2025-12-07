#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Chezmoi Interactive Editor
# 
# Fuzzy-find and edit chezmoi-managed files, with automatic git commit/push.
# ============================================================================

# --- Configuration ---
PREFERRED_TERMINAL="alacritty"
FALLBACK_TERMINALS=(foot ghostty kitty urxvt xterm)
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

# Load environment if available
load_env() {
    set +u
    # shellcheck disable=SC1091
    [[ -f "$HOME/.myenv" ]] && source "$HOME/.myenv"
    set -u
}

# Select target file interactively
select_target() {
    local -a lines
    mapfile -t lines < <(
        chezmoi managed -p absolute -x dirs | 
        sk --ansi \
           --with-nth=-2,-1 \
           --delimiter='/' \
           --print-query \
           --prompt="Edit: " \
           --preview='bat --color=always --style=plain {}' \
           --preview-window='right:60%:wrap' || true
    )
    
    local query="${lines[0]:-}"
    local pick="${lines[1]:-}"
    
    # Prefer selection, fall back to query
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

# Ensure file exists and is managed by chezmoi
ensure_managed() {
    local target="$1"
    
    if [[ ! -e "$target" ]]; then
        log "Creating new file: $target"
        mkdir -p "$(dirname "$target")"
        touch "$target"
        chezmoi add "$target" || die "Failed to add $target to chezmoi"
    fi
}

# Get chezmoi source path for a target
get_source_path() {
    local target="$1"
    local src_path
    
    if src_path=$(chezmoi source-path "$target" 2>/dev/null); then
        echo "$src_path"
    else
        log "Warning: $target not managed by chezmoi, editing directly"
        echo "$target"
    fi
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

# Create the edit-commit-push script
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

# Edit the file
"$EDITOR" "$REL_PATH"

# Check for changes
if git diff --quiet -- "$REL_PATH" && git diff --cached --quiet -- "$REL_PATH"; then
    echo ""
    echo "No changes detected."
    read -rp "Press Enter to close..." _
    exit 0
fi

# Stage changes
git add "$REL_PATH"

# Show diff
echo ""
echo "Changes to be committed:"
echo "----------------------------------------"
git diff --cached --stat -- "$REL_PATH"
echo ""

# Commit with descriptive message
commit_msg="Update $REL_PATH"
if git commit -m "$commit_msg"; then
    echo ""
    echo "✓ Committed successfully"
else
    echo ""
    echo "✗ Commit failed"
    read -rp "Press Enter to close..." _
    exit 1
fi

# Push changes
echo ""
echo "Pushing to remote..."
if git push; then
    echo ""
    echo "✓ Successfully pushed changes"
    sleep 1
else
    echo ""
    echo "✗ Push failed - check your connection and permissions"
    read -rp "Press Enter to close..." _
    exit 1
fi
SCRIPT_EOF
    
    chmod +x "$script_path"
    echo "$script_path"
}

# --- Main ---

main() {
    load_env
    
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
