# Personal Backup Solution with Rotation

## Overview

This project implements a personal backup solution for Linux using Bash scripting and standard system administration tools. The system creates compressed backups, supports rotation of old backups, writes detailed logs, handles process signals, and can be scheduled automatically through `systemd`.

This project was created as a proof-of-concept for a system and network administration assignment.

## Project Goals

The project implements the following functionality:

- weekly full backups
- daily incremental backups
- compression using `tar` and `gzip`
- retention policy for full backups
- progress reporting with `SIGUSR1`
- logging of all backup operations with timestamps
- automatic scheduled execution through `systemd`
- documented restore procedure

## Features

- Full backup creation
- Incremental backup creation
- Compressed `.tar.gz` archives
- Retention of recent full backups
- Time-stamped log file
- `SIGUSR1` signal handling
- Restore script for rebuilding the latest backed up state
- `systemd` service and timer configuration
- Documentation for testing and restoration

## Project Structure

```text
personal-backup-solution/
├── backup.sh
├── restore.sh
├── config
├── README.md
├── .gitignore
├── systemd/
│   ├── backup.service
│   └── backup.timer
├── docs/
│   ├── restoration.md
│   ├── testing.md
│   └── examples/
│       └── sample-backup-history.txt
├── screenshots/
├── backups/
│   └── .gitkeep
└── logs/
    └── .gitkeep
