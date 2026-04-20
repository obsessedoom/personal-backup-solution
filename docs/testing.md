# Testing

## Purpose

This document describes the tests performed for the personal backup solution. The goal of testing was to verify that the system works correctly and satisfies the project requirements.

## Test Environment

The project was tested in a Linux environment using Bash scripts and standard system administration tools.

Tools used during testing:

- Bash
- tar
- gzip
- find
- systemd
- signal handling with `SIGUSR1`

The source directory used during development and testing was:

```bash
$HOME/backup_test_dir
