# Personal Backup Solution with Rotation

## Overview

This project implements a personal backup solution for Linux using Bash scripting and standard system administration tools. The system creates compressed backups, supports rotation of old backups, writes detailed logs, handles process signals, and can be scheduled automatically through `systemd`.

## Project Goals

The project implements the following functionality:

* weekly full backups
* daily incremental backups
* compression using `tar` and `gzip`
* retention policy for full backups
* progress reporting with `SIGUSR1`
* logging of all backup operations with timestamps
* automatic scheduled execution through `systemd`
* documented restore procedure

## Features

* Full backup creation
* Incremental backup creation
* Compressed `.tar.gz` archives
* Retention of recent full backups
* Time-stamped log file
* `SIGUSR1` signal handling
* Restore script for rebuilding the latest backed up state
* `systemd` service and timer configuration
* Documentation for testing and restoration

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
```

## Requirements

The following tools are required:

* Linux
* Bash
* `tar`
* `gzip`
* `find`
* `systemd`

## Configuration

Project settings are stored in the `config` file.

Example configuration:

```bash
SOURCE_DIR="$HOME"
BACKUP_ROOT="$SCRIPT_DIR/backups"
LOG_FILE="$SCRIPT_DIR/logs/backup.log"
RETENTION_COUNT=4
```

### Configuration Parameters

* `SOURCE_DIR` — directory to back up
* `BACKUP_ROOT` — directory where backup archives are stored
* `LOG_FILE` — path to the log file
* `RETENTION_COUNT` — number of full backups to keep

## Quick Start

### 1. Give execute permissions

```bash
chmod +x backup.sh restore.sh
```

### 2. Edit configuration

Open the `config` file and set the required paths:

```bash
nano config
```

Example:

```bash
SOURCE_DIR="$HOME"
BACKUP_ROOT="$SCRIPT_DIR/backups"
LOG_FILE="$SCRIPT_DIR/logs/backup.log"
RETENTION_COUNT=4
```

### 3. Run backup manually

```bash
./backup.sh
```

### 4. Run restore manually

```bash
./restore.sh ~/restore_test
```

### 5. Configure automatic execution with systemd

```bash
sudo cp systemd/backup.service /etc/systemd/system/
sudo cp systemd/backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer
```

### 6. Check timer status

```bash
systemctl status backup.timer
systemctl list-timers --all | grep backup
```

## Scripts

### `backup.sh`

The main backup script:

* loads configuration
* creates required directories if they do not exist
* performs a full or incremental backup
* compresses data into `.tar.gz` archives
* writes log entries with timestamps
* handles `SIGUSR1`
* applies retention policy for full backups

### `restore.sh`

The restore script:

* finds the latest full backup
* extracts it into a target directory
* applies all newer incremental backups
* reconstructs the latest backed up state of the source directory

## Manual Usage

### Run backup manually

```bash
./backup.sh
```

### Run restore manually

```bash
./restore.sh ~/restore_test
```

## Backup Logic

The intended backup behavior is:

* create a full backup once per week
* create incremental backups on other days
* keep only the latest configured number of full backups
* write all backup events to the log file

Full backups archive the entire source directory.

Incremental backups archive only the files that changed after the last recorded backup timestamp.

## Example Workflow

### 1. Create test files

```bash
mkdir -p ~/backup_test_dir/subdir
echo "first file" > ~/backup_test_dir/a.txt
echo "second file" > ~/backup_test_dir/b.txt
echo "nested file" > ~/backup_test_dir/subdir/c.txt
```

### 2. Run full backup

```bash
./backup.sh
```

### 3. Modify files and create incremental backup

```bash
echo "updated line" >> ~/backup_test_dir/a.txt
echo "brand new file" > ~/backup_test_dir/new.txt
./backup.sh
```

### 4. Restore the latest state

```bash
./restore.sh ~/restore_test
```

## Example Backup Files

Example contents of the `backups/` directory after testing:

```text
full_backup_2026-04-19_20-28-11.tar.gz
inc_backup_2026-04-19_20-28-45.tar.gz
last_backup.timestamp
```

## Logging

All backup operations are written to the configured log file with timestamps.

Example log events include:

* backup start
* backup type
* backup completion
* signal handling events
* retention checks

A sample log file is available in:

```text
docs/examples/sample-backup-history.txt
```

## Signal Handling

The backup script handles `SIGUSR1` and writes a progress-related message into the log file. This allows the running backup process to report its current state without terminating the process.

Example test:

```bash
./backup.sh &
sleep 2
kill -USR1 $!
wait
```

## Rotation Policy

The project implements rotation of full backups.

Retention rule:

* keep the most recent 4 full backups
* remove older full backup archives automatically

This prevents unlimited growth of stored backup data.

## systemd Integration

The project includes:

* `systemd/backup.service`
* `systemd/backup.timer`

These files allow the backup script to run automatically according to a schedule.

### Example setup

```bash
sudo cp systemd/backup.service /etc/systemd/system/
sudo cp systemd/backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer
```

### Check timer status

```bash
systemctl status backup.timer
systemctl list-timers --all | grep backup
```

## Testing

The project was tested for:

* full backup creation
* incremental backup creation
* archive content verification
* restore procedure
* signal handling with `SIGUSR1`
* retention logic
* `systemd` timer configuration

Detailed testing information is available in:

```text
docs/testing.md
```

## Restoration

Detailed restoration instructions are available in:

```text
docs/restoration.md
```

## Screenshots

The `screenshots/` directory contains screenshots demonstrating:

* backup file list
* log output
* incremental archive content
* restore output
* signal handling test
* timer status

## Notes

* Real backup archives are not stored in the Git repository.
* Working log files are not stored in the Git repository.
* The repository includes only code, configuration, documentation, and example outputs.
* Empty directories such as `backups/` and `logs/` are preserved using `.gitkeep`.

## Conclusion

This project demonstrates a practical personal backup solution implemented with Bash and Linux administration tools. It combines automation, compression, rotation, logging, signal handling, restore functionality, and scheduler integration.
