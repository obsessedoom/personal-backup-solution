#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config"

mkdir -p "$BACKUP_ROOT"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

SNAPSHOT_FILE="$BACKUP_ROOT/last_backup.timestamp"
TMP_FILE="/tmp/changed_files_$$.txt"
backup_file=""

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

progress_report() {
    log "SIGUSR1 received - backup process is running. Current archive: $backup_file"
}

trap progress_report SIGUSR1

rotate_full_backups() {
    log "Checking full backup retention policy (keep last $RETENTION_COUNT)"
    mapfile -t full_backups < <(ls -1t "$BACKUP_ROOT"/full_backup_*.tar.gz 2>/dev/null || true)

    if [ "${#full_backups[@]}" -gt "$RETENTION_COUNT" ]; then
        for ((i=RETENTION_COUNT; i<${#full_backups[@]}; i++)); do
            log "Removing old full backup: ${full_backups[$i]}"
            rm -f "${full_backups[$i]}"
        done
    fi
}

last_full_backup="$(ls -1t "$BACKUP_ROOT"/full_backup_*.tar.gz 2>/dev/null | head -n1 || true)"

do_full=0
current_weekday="$(date +%u)"

if [ "$current_weekday" -eq 7 ] || [ -z "$last_full_backup" ]; then
    do_full=1
fi

if [ "$do_full" -eq 1 ]; then
    backup_date="$(date +%Y-%m-%d_%H-%M-%S)"
    backup_file="$BACKUP_ROOT/full_backup_$backup_date.tar.gz"
    log "Starting FULL backup to $backup_file"

    tar -czf "$backup_file" -C "$SOURCE_DIR" . 2>>"$LOG_FILE"
    log "Full backup completed successfully"

    touch "$SNAPSHOT_FILE"
    rotate_full_backups
else
    backup_date="$(date +%Y-%m-%d_%H-%M-%S)"
    backup_file="$BACKUP_ROOT/inc_backup_$backup_date.tar.gz"
    log "Starting INCREMENTAL backup to $backup_file"

    cd "$SOURCE_DIR"
    if [ -f "$SNAPSHOT_FILE" ]; then
        find . -type f -newer "$SNAPSHOT_FILE" > "$TMP_FILE"
    else
        find . -type f > "$TMP_FILE"
    fi

    if [ -s "$TMP_FILE" ]; then
        tar -czf "$backup_file" -T "$TMP_FILE" 2>>"$LOG_FILE"
        log "Incremental backup completed successfully"
    else
        log "No changed files found for incremental backup"
        rm -f "$TMP_FILE"
        exit 0
    fi

    rm -f "$TMP_FILE"
    touch "$SNAPSHOT_FILE"
fi

log "Backup finished: $backup_file"
