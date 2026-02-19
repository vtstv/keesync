#!/bin/bash
# Copyright (c) Murr
# GitHub: https://github.com/vtstv

CRON_MARKER="# keepass-sync"

check_cron() {
    if ! command -v crontab &> /dev/null; then
        echo "⚠ crontab is not available"
        echo ""
        echo "Installing cronie..."
        
        local distro=$(detect_distro)
        case "$distro" in
            arch|manjaro|endeavouros|garuda|cachyos|artix)
                sudo pacman -S --noconfirm cronie
                sudo systemctl enable --now cronie
                ;;
            ubuntu|debian|linuxmint|pop|elementary)
                sudo apt update
                sudo apt install -y cron
                sudo systemctl enable --now cron
                ;;
            fedora|nobara)
                sudo dnf install -y cronie
                sudo systemctl enable --now crond
                ;;
            *)
                echo "Please install cron/cronie manually"
                return 1
                ;;
        esac
        
        if command -v crontab &> /dev/null; then
            echo "✓ cron installed successfully"
        else
            echo "✗ Installation failed"
            return 1
        fi
    fi
}

get_cron_entry() {
    local schedule="$1"
    local script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/sync-keepass.sh"
    echo "${schedule} ${script_path} sync >> ${LOG_FILE} 2>&1 ${CRON_MARKER}"
}

add_cron() {
    check_cron || return 1
    
    local schedule="$1"
    local entry="$(get_cron_entry "$schedule")"
    
    echo "Adding cron entry: $entry"
    
    # Get existing crontab, remove old entries, add new one
    local temp_cron=$(mktemp)
    crontab -l 2>/dev/null | grep -v "$CRON_MARKER" > "$temp_cron" || true
    echo "$entry" >> "$temp_cron"
    crontab "$temp_cron"
    rm -f "$temp_cron"
    
    echo "✓ Cron job added: $schedule"
    echo ""
    echo "Verifying..."
    crontab -l | grep "$CRON_MARKER"
}

remove_cron() {
    check_cron || return 1
    
    local temp_cron=$(mktemp)
    crontab -l 2>/dev/null | grep -v "$CRON_MARKER" > "$temp_cron" || true
    crontab "$temp_cron"
    rm -f "$temp_cron"
    
    echo "✓ Cron job removed"
}

show_cron() {
    if ! command -v crontab &> /dev/null; then
        echo "⚠ crontab not available"
        return
    fi
    
    local current=$(crontab -l 2>/dev/null | grep "$CRON_MARKER")
    if [[ -n "$current" ]]; then
        echo "Current cron job:"
        echo "$current"
    else
        echo "No cron job configured"
    fi
}

manage_cron() {
    case "$1" in
        add)
            echo "Select schedule:"
            echo "  1) Every 30 minutes"
            echo "  2) Every hour"
            echo "  3) Every 6 hours"
            echo "  4) Every 12 hours"
            echo "  5) Daily at 2 AM"
            echo "  6) Custom"
            read -p "Choose [1-6]: " choice
            
            case "$choice" in
                1) add_cron "*/30 * * * *" ;;
                2) add_cron "0 * * * *" ;;
                3) add_cron "0 */6 * * *" ;;
                4) add_cron "0 */12 * * *" ;;
                5) add_cron "0 2 * * *" ;;
                6)
                    read -p "Enter cron schedule (e.g., '*/15 * * * *'): " custom
                    add_cron "$custom"
                    ;;
                *) echo "Invalid choice" ;;
            esac
            ;;
        remove)
            remove_cron
            ;;
        show|*)
            show_cron
            ;;
    esac
}
