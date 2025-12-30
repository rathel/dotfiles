#!/usr/bin/env bash
set -euo pipefail

THUNDERBIRD_DIR="$HOME/.thunderbird"
BACKUP_DIR="$HOME/pg4uk-f7ecq/Backups/thunderbird"

kill_thunderbird() {
    echo "Checking for running Thunderbird processes..."

    # Try to kill common process names
    local names=("thunderbird" "Thunderbird" "thunderbird-bin")
    local killed=false

    for name in "${names[@]}"; do
        if pgrep -x "$name" >/dev/null 2>&1; then
            echo "  Found running process: $name (killing)..."
            pkill -x "$name" || true
            killed=true
        fi
    done

    if [ "$killed" = true ]; then
        echo "Waiting for Thunderbird to exit..."
        for i in {1..10}; do
            sleep 1
            if ! pgrep -x thunderbird >/dev/null 2>&1 \
               && ! pgrep -x Thunderbird >/dev/null 2>&1 \
               && ! pgrep -x thunderbird-bin >/dev/null 2>&1; then
                echo "Thunderbird has exited."
                return 0
            fi
        done
        echo "Warning: Thunderbird processes may still be running."
    else
        echo "No Thunderbird processes found."
    fi
}

do_backup() {
    kill_thunderbird

    if [ ! -d "$THUNDERBIRD_DIR" ]; then
        echo "Error: Thunderbird profile directory '$THUNDERBIRD_DIR' not found."
        exit 1
    fi

    mkdir -p "$BACKUP_DIR"

    local timestamp
    timestamp="$(date +'%Y%m%d-%H%M%S')"

    local dest="${1:-"$BACKUP_DIR/thunderbird-$timestamp.tar.xz"}"

    echo "Backing up Thunderbird profile from:"
    echo "  $THUNDERBIRD_DIR"
    echo "to:"
    echo "  $dest"
    echo

    # Create archive relative to $HOME so it restores cleanly
    (
        cd "$HOME"
        tar -cJf "$dest" ".thunderbird"
    )

    echo
    echo "Backup complete."
    echo "File: $dest"
}

do_restore() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 restore /path/to/thunderbird-backup.tar.xz"
        exit 1
    fi

    local archive="$1"

    if [ ! -f "$archive" ]; then
        echo "Error: backup archive '$archive' not found."
        exit 1
    fi

    kill_thunderbird

    # Safety backup of existing profile, if present
    if [ -d "$THUNDERBIRD_DIR" ]; then
        local ts
        ts="$(date +'%Y%m%d-%H%M%S')"
        local backup_existing="$THUNDERBIRD_DIR.backup-before-restore-$ts"

        echo "Existing Thunderbird profile found."
        echo "Moving it to:"
        echo "  $backup_existing"
        mv "$THUNDERBIRD_DIR" "$backup_existing"
    else
        echo "No existing Thunderbird profile found; nothing to move."
    fi

    echo "Restoring from archive:"
    echo "  $archive"
    echo "into HOME directory:"
    echo "  $HOME"
    echo

    (
        cd "$HOME"
        tar -xJf "$archive"
    )

    echo
    echo "Restore complete."
    echo "Thunderbird profile restored to: $THUNDERBIRD_DIR"
    echo "You can now start Thunderbird."
}

usage() {
    cat <<EOF
Usage:
  $0 backup [optional-output-path.tar.xz]
  $0 restore /path/to/thunderbird-backup.tar.xz

Examples:
  $0 backup
      -> saves to $BACKUP_DIR/thunderbird-YYYYmmdd-HHMMSS.tar.xz

  $0 backup /mnt/storage/tb-profile.tar.xz
      -> saves to the specific path

  $0 restore /mnt/storage/tb-profile.tar.xz
      -> restores ~/.thunderbird from that archive
EOF
}

main() {
    local cmd="${1:-}"

    case "$cmd" in
        backup)
            shift
            do_backup "$@"
            ;;
        restore)
            shift
            do_restore "$@"
            ;;
        ""|-h|--help|help)
            usage
            ;;
        *)
            echo "Unknown command: $cmd"
            usage
            exit 1
            ;;
    esac
}

main "$@"

