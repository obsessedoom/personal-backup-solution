# Restoration Procedure

## Purpose

This document explains how to restore files from the backup system. The restore process uses the latest full backup and then applies all incremental backups created after that full backup.

## Restore Logic

The restoration process works in the following order:

1. The script searches for the latest full backup archive in the backup directory.
2. It extracts that full backup into the restore target directory.
3. It finds all incremental backup archives created after the latest full backup.
4. It applies those incremental backups in chronological order.
5. The restore target directory is rebuilt to the latest backed up state.

## Requirements

Before running the restore process, make sure that:

- backup archives exist in the configured backup directory
- the `restore.sh` script has execute permission
- the `config` file contains the correct backup directory path
- the system has `tar` installed
- the target restore directory is writable

## Files Used During Restore

The restore process uses the following files:

- `restore.sh`
- `config`
- `backups/full_backup_*.tar.gz`
- `backups/inc_backup_*.tar.gz`

## Restore Command

To restore files into a target directory, run:

```bash
./restore.sh ~/restore_test
