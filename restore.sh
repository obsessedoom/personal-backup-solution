#!/bin/bash
RESTORE_TARGET="$HOME/restore_test"
mkdir -p "$RESTORE_TARGET"
LAST_FULL=$(ls -1 "$BACKUP_ROOT"/full_backup_*.tar.gz | tail -n1)
echo "Extracting $LAST_FULL"
tar -xzf "$LAST_FULL" -C "$RESTORE_TARGET"
FULL_DATE=$(basename "$LAST_FULL" | sed 's/full_backup_//;s/.tar.gz//')
for inc in "$BACKUP_ROOT"/inc_backup_*.tar.gz; do
    INC_DATE=$(basename "$inc" | sed 's/inc_backup_//;s/.tar.gz//')
    if [[ "$INC_DATE" > "$FULL_DATE" ]]; then
        echo "Applying incremental $inc"
        tar -xzf "$inc" -C "$RESTORE_TARGET"
    fi
done
echo "Restore completed to $RESTORE_TARGET"
