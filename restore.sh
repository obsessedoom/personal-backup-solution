#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config"

RESTORE_TARGET="${1:-$HOME/restore_test}"
mkdir -p "$RESTORE_TARGET"

LAST_FULL="$(ls -1t "$BACKUP_ROOT"/full_backup_*.tar.gz | head -n1)"
echo "Extracting full backup: $LAST_FULL"
tar -xzf "$LAST_FULL" -C "$RESTORE_TARGET"

FULL_DATE="$(basename "$LAST_FULL" | sed 's/full_backup_//;s/.tar.gz//')"

for inc in $(ls -1 "$BACKUP_ROOT"/inc_backup_*.tar.gz 2>/dev/null | sort); do
    INC_DATE="$(basename "$inc" | sed 's/inc_backup_//;s/.tar.gz//')"
    if [[ "$INC_DATE" > "$FULL_DATE" ]]; then
        echo "Applying incremental backup: $inc"
        tar -xzf "$inc" -C "$RESTORE_TARGET"
    fi
done

echo "Restore completed to $RESTORE_TARGET"
