#!/bin/bash

source ./config

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

progress_report() {
    log "SIGUSR1 received - current backup progress: $CURRENT_FILE / $TOTAL_FILES (estimated)"
}
trap progress_report SIGUSR1

rotate_full_backups() {
    log "Rotating full backups, keeping $RETENTION_COUNT most recent"
    ls -1 "$BACKUP_ROOT"/full_backup_*.tar.gz 2>/dev/null | head -n -$RETENTION_COUNT | while read old; do
        log "Removing old full backup: $old"
        rm -f "$old"
    done
}

last_full_backup=$(ls -1 "$BACKUP_ROOT"/full_backup_*.tar.gz 2>/dev/null | tail -n1)
last_full_timestamp=""
if [ -n "$last_full_backup" ]; then
    last_full_timestamp=$(basename "$last_full_backup" | sed 's/full_backup_//;s/.tar.gz//')
fi

do_full=0
current_weekday=$(date +%u)
if [ "$current_weekday" -eq 7 ] || [ -z "$last_full_timestamp" ]; then
    do_full=1
fi

if [ $do_full -eq 1 ]; then
    backup_date=$(date +%Y-%m-%d)
    backup_file="$BACKUP_ROOT/full_backup_$backup_date.tar.gz"
    log "Starting FULL backup to $backup_file"

    TOTAL_FILES=$(find "$SOURCE_DIR" -type f 2>/dev/null | wc -l)
    CURRENT_FILE=0
    tar -czf "$backup_file" -C "$SOURCE_DIR" . 2>>"$LOG_FILE"
    if [ $? -eq 0 ]; then
        log "Full backup completed successfully"
    else
        log "ERROR: Full backup failed"
        exit 1
    fi
    rotate_full_backups
else
    backup_file="$BACKUP_ROOT/inc_backup_$(date +%Y-%m-%d).tar.gz"
    log "Starting INCREMENTAL backup (since $last_full_timestamp) to $backup_file"
    find "$SOURCE_DIR" -type f -newer "$last_full_backup" 2>/dev/null > /tmp/changed_files_$$.txt
    TOTAL_FILES=$(wc -l < /tmp/changed_files_$$.txt)
    CURRENT_FILE=0
    tar -czf "$backup_file" -C "$SOURCE_DIR" -T /tmp/changed_files_$$.txt 2>>"$LOG_FILE"
    rm -f /tmp/changed_files_$$.txt
    if [ $? -eq 0 ]; then
        log "Incremental backup completed successfully"
    else
        log "ERROR: Incremental backup failed"
        exit 1
    fi
fi

log "Backup finished: $backup_file"
