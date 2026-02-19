#!/bin/bash
# Copyright (c) Murr
# GitHub: https://github.com/vtstv

CONFIG_FILE="${HOME}/.config/keepass-sync/config"

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
    
    # Set default for max backups if not configured
    MAX_BACKUPS="${MAX_BACKUPS:-2}"
}

save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << EOF
KEEPASS_LOCAL_PATH="$KEEPASS_LOCAL_PATH"
KEEPASS_REMOTE_PATH="$KEEPASS_REMOTE_PATH"
RCLONE_REMOTE="$RCLONE_REMOTE"
SYNC_DIRECTION="$SYNC_DIRECTION"
MAX_BACKUPS="${MAX_BACKUPS:-2}"
EOF
    chmod 600 "$CONFIG_FILE"
}

setup_config() {
    load_config
    
    echo "Configure sync paths and behavior"
    echo ""
    
    read -p "Local KeePassXC database path [${KEEPASS_LOCAL_PATH:-$HOME/keepass.kdbx}]: " input
    KEEPASS_LOCAL_PATH="${input:-${KEEPASS_LOCAL_PATH:-$HOME/keepass.kdbx}}"
    
    read -p "Remote path on Google Drive [${KEEPASS_REMOTE_PATH:-/keepass.kdbx}]: " input
    KEEPASS_REMOTE_PATH="${input:-${KEEPASS_REMOTE_PATH:-/keepass.kdbx}}"
    
    read -p "Rclone remote name [${RCLONE_REMOTE:-gdrive}]: " input
    RCLONE_REMOTE="${input:-${RCLONE_REMOTE:-gdrive}}"
    
    echo ""
    echo "Sync direction:"
    echo "  1) Bidirectional (sync both ways)"
    echo "  2) Upload only (local → remote)"
    echo "  3) Download only (remote → local)"
    read -p "Choose [${SYNC_DIRECTION:-1}]: " input
    SYNC_DIRECTION="${input:-${SYNC_DIRECTION:-1}}"
    
    echo ""
    read -p "Max number of local backups to keep [${MAX_BACKUPS:-2}]: " input
    MAX_BACKUPS="${input:-${MAX_BACKUPS:-2}}"
    
    save_config
    echo ""
    echo "✓ Configuration saved"
}
