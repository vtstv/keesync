#!/bin/bash
# Copyright (c) Murr
# GitHub: https://github.com/vtstv

LOG_FILE="${HOME}/.config/keepass-sync/sync.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

backup_local() {
    if [[ -f "$KEEPASS_LOCAL_PATH" ]]; then
        local backup="${KEEPASS_LOCAL_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$KEEPASS_LOCAL_PATH" "$backup"
        log_message "Created backup: $backup"
        
        # Rotate old backups
        rotate_backups
    fi
}

rotate_backups() {
    local backup_pattern="${KEEPASS_LOCAL_PATH}.backup.*"
    local backup_count=$(ls -1 ${backup_pattern} 2>/dev/null | wc -l)
    local max_backups="${MAX_BACKUPS:-2}"
    
    if [[ $backup_count -gt $max_backups ]]; then
        local to_delete=$((backup_count - max_backups))
        ls -1t ${backup_pattern} 2>/dev/null | tail -n $to_delete | while read old_backup; do
            rm -f "$old_backup"
            log_message "Removed old backup: $old_backup"
        done
    fi
}

sync_bidirectional() {
    rclone sync "$KEEPASS_LOCAL_PATH" "${RCLONE_REMOTE}:$(dirname "$KEEPASS_REMOTE_PATH")" \
        --include "$(basename "$KEEPASS_LOCAL_PATH")" \
        --update --verbose
    
    rclone sync "${RCLONE_REMOTE}:${KEEPASS_REMOTE_PATH}" "$KEEPASS_LOCAL_PATH" \
        --update --verbose
}

sync_upload() {
    rclone copy "$KEEPASS_LOCAL_PATH" "${RCLONE_REMOTE}:$(dirname "$KEEPASS_REMOTE_PATH")" \
        --update --verbose
}

sync_download() {
    rclone copy "${RCLONE_REMOTE}:${KEEPASS_REMOTE_PATH}" "$(dirname "$KEEPASS_LOCAL_PATH")" \
        --update --verbose
}

perform_sync() {
    check_rclone
    load_config
    
    if [[ -z "$KEEPASS_LOCAL_PATH" ]] || [[ -z "$RCLONE_REMOTE" ]]; then
        echo "✗ Configuration not found. Run setup first."
        exit 1
    fi
    
    mkdir -p "$(dirname "$LOG_FILE")"
    log_message "Starting sync operation"
    
    backup_local
    
    case "${SYNC_DIRECTION:-1}" in
        1)
            log_message "Syncing bidirectionally"
            sync_bidirectional
            ;;
        2)
            log_message "Uploading to remote"
            sync_upload
            ;;
        3)
            log_message "Downloading from remote"
            sync_download
            ;;
    esac
    
    log_message "Sync completed successfully"
    echo "✓ Sync completed successfully"
}
