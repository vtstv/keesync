# KeePassXC Google Drive Sync

Automated sync tool for KeePassXC databases with Google Drive using rclone.

## Features

- Interactive menu interface
- Browser-based Google Drive authentication
- Bidirectional, upload-only, or download-only sync modes
- Automatic local backups before sync
- Configurable cron scheduling
- Sync logging

## Requirements

- bash
- rclone ([installation guide](https://rclone.org/install/))

## Installation

Make the script executable and run it:
```bash
chmod +x sync-keepass.sh
./sync-keepass.sh
```

Use menu option 8 to install globally, then you can run from anywhere:
```bash
keepass-sync
```

## Usage

Launch interactive menu:
```bash
keepass-sync
```

Or use direct commands:
```bash
keepass-sync setup    # Configure rclone and sync settings
keepass-sync sync     # Perform sync operation
keepass-sync cron     # Manage cron job
```

## Interactive Menu

The menu provides:

1. Initial Setup - Configure rclone and sync paths
2. Sync Now - Perform immediate sync
3. Manage Cron Job - Schedule automatic syncs
4. View Sync Log - Check recent sync activity
5. Edit Configuration - Update sync settings
6. Test Connection - Verify Google Drive access
7. Install/Reinstall rclone - Install rclone if not present
8. Install Script Globally - Create global command symlink

## Configuration

Settings are stored in `~/.config/keepass-sync/config`:

- Local KeePassXC database path
- Remote Google Drive path
- Rclone remote name
- Sync direction (bidirectional/upload/download)

## License

Copyright (c) Murr  
https://github.com/vtstv
