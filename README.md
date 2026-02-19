# KeePassXC Google Drive Sync

Automated sync tool for KeePassXC databases with Google Drive using rclone.

## Installation

```bash
git clone https://github.com/vtstv/keesync.git
cd keesync
./install.sh
```

## Usage

Run interactive menu:
```bash
keepass-sync
```

Or use commands directly:
```bash
keepass-sync setup    # Configure rclone and paths
keepass-sync sync     # Sync now
keepass-sync cron     # Manage cron jobs
```

## Features

- Browser-based Google Drive authentication
- Bidirectional, upload-only, or download-only sync
- Automatic backups before sync
- Configurable cron scheduling
- Interactive menu interface

## License

Copyright (c) Murr  
GitHub: https://github.com/vtstv
