# KeePassXC Google Drive Sync

Automated sync tool for KeePassXC databases with Google Drive using rclone.

## Features

- 🔐 Secure Google Drive authentication via browser
- 🔄 Bidirectional, upload-only, or download-only sync modes
- ⏰ Configurable cron scheduling
- 💾 Automatic local backups before sync
- 📊 Interactive menu interface
- 📝 Sync logging

## Requirements

- Linux system with bash
- rclone (auto-installed if missing on supported distros)
- KeePassXC database file

## Installation

```bash
git clone https://github.com/vtstv/keesync.git
cd keesync
./install.sh
```

Add to your PATH if needed:
```bash
export PATH="$PATH:$HOME/.local/bin"
```

## Quick Start

1. Run the interactive menu:
```bash
keepass-sync
```

2. Select "Initial Setup" to:
   - Authenticate with Google Drive (browser opens automatically)
   - Configure local and remote paths
   - Choose sync direction

3. Sync manually or setup a cron job

## Usage

### Interactive Menu (Recommended)
```bash
keepass-sync
```

### Command Line
```bash
keepass-sync setup    # Initial configuration
keepass-sync sync     # Manual sync
keepass-sync cron     # Manage cron jobs
```

## Configuration

Settings are stored in `~/.config/keepass-sync/config`

Default values:
- Local path: `~/keepass.kdbx`
- Remote path: `/keepass.kdbx`
- Remote name: `gdrive`
- Sync mode: Bidirectional

## Sync Modes

1. **Bidirectional**: Keeps both local and remote in sync
2. **Upload only**: Local → Google Drive
3. **Download only**: Google Drive → Local

## Cron Schedules

- Every 30 minutes
- Every hour
- Every 6 hours
- Daily at 2 AM
- Custom schedule

## Security

- Automatic backups before each sync
- Secure rclone OAuth2 authentication
- Config file permissions: 600
- No passwords stored in scripts

## License

Copyright (c) Murr  
GitHub: https://github.com/vtstv

## Contributing

Issues and pull requests welcome!
