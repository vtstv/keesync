#!/bin/bash
# Copyright (c) Murr
# GitHub: https://github.com/vtstv

clear_screen() {
    clear
}

print_header() {
    echo "╔════════════════════════════════════════╗"
    echo "║   KeePassXC Google Drive Sync Tool    ║"
    echo "║   Copyright (c) Murr                  ║"
    echo "║   github.com/vtstv                    ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
}

press_enter() {
    echo ""
    read -p "Press Enter to continue..."
}

show_main_menu() {
    while true; do
        clear_screen
        print_header
        
        load_config
        
        echo "Current Configuration:"
        if [[ -f "$CONFIG_FILE" ]]; then
            echo "  Local:  ${KEEPASS_LOCAL_PATH:-Not set}"
            echo "  Remote: ${RCLONE_REMOTE:-Not set}:${KEEPASS_REMOTE_PATH:-Not set}"
            echo "  Mode:   $(get_sync_mode_name)"
        else
            echo "  ⚠ Not configured yet"
        fi
        echo ""
        
        local cron_status=$(crontab -l 2>/dev/null | grep "$CRON_MARKER" || echo "")
        if [[ -n "$cron_status" ]]; then
            echo "Cron: ✓ Enabled"
        else
            echo "Cron: ✗ Disabled"
        fi
        echo ""
        echo "────────────────────────────────────────"
        echo ""
        echo "1) Initial Setup (Configure rclone & paths)"
        echo "2) Sync Now"
        echo "3) Manage Cron Job"
        echo "4) View Sync Log"
        echo "5) Edit Configuration"
        echo "6) Test Connection"
        echo "7) Install/Reinstall rclone"
        echo "8) Install Script Globally"
        echo "0) Exit"
        echo ""
        read -p "Select option [0-8]: " choice
        
        case "$choice" in
            1) menu_initial_setup ;;
            2) menu_sync_now ;;
            3) menu_manage_cron ;;
            4) menu_view_log ;;
            5) menu_edit_config ;;
            6) menu_test_connection ;;
            7) menu_install_rclone ;;
            8) menu_install_script ;;
            0) exit 0 ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    done
}

get_sync_mode_name() {
    case "${SYNC_DIRECTION:-1}" in
        1) echo "Bidirectional" ;;
        2) echo "Upload only" ;;
        3) echo "Download only" ;;
        *) echo "Unknown" ;;
    esac
}

menu_initial_setup() {
    clear_screen
    print_header
    echo "═══ Initial Setup ═══"
    echo ""
    
    setup_rclone
    echo ""
    setup_config
    
    press_enter
}

menu_sync_now() {
    clear_screen
    print_header
    echo "═══ Sync Now ═══"
    echo ""
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "⚠ Configuration not found. Please run Initial Setup first."
        press_enter
        return
    fi
    
    perform_sync
    
    press_enter
}

menu_manage_cron() {
    while true; do
        clear_screen
        print_header
        echo "═══ Manage Cron Job ═══"
        echo ""
        
        local current=$(crontab -l 2>/dev/null | grep "$CRON_MARKER" || echo "")
        if [[ -n "$current" ]]; then
            echo "Current cron job:"
            echo "  $current"
            echo ""
            echo "1) Remove cron job"
            echo "2) Change schedule"
        else
            echo "No cron job configured"
            echo ""
            echo "1) Add cron job"
        fi
        echo "0) Back to main menu"
        echo ""
        read -p "Select option: " choice
        
        case "$choice" in
            1)
                if [[ -n "$current" ]]; then
                    remove_cron
                else
                    menu_add_cron
                fi
                press_enter
                ;;
            2)
                if [[ -n "$current" ]]; then
                    remove_cron
                    menu_add_cron
                    press_enter
                fi
                ;;
            0) return ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    done
}

menu_add_cron() {
    echo ""
    echo "Select schedule:"
    echo "  1) Every 30 minutes"
    echo "  2) Every hour"
    echo "  3) Every 6 hours"
    echo "  4) Every 12 hours"
    echo "  5) Daily at 2 AM"
    echo "  6) Custom"
    echo ""
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
}

menu_view_log() {
    clear_screen
    print_header
    echo "═══ Sync Log (last 30 lines) ═══"
    echo ""
    
    if [[ -f "$LOG_FILE" ]]; then
        tail -n 30 "$LOG_FILE"
    else
        echo "No log file found"
    fi
    
    press_enter
}

menu_edit_config() {
    clear_screen
    print_header
    echo "═══ Edit Configuration ═══"
    echo ""
    
    setup_config
    
    press_enter
}

menu_test_connection() {
    clear_screen
    print_header
    echo "═══ Test Connection ═══"
    echo ""
    
    load_config
    
    if [[ -z "$RCLONE_REMOTE" ]]; then
        echo "⚠ Configuration not found. Please run Initial Setup first."
        press_enter
        return
    fi
    
    echo "Testing connection to ${RCLONE_REMOTE}..."
    
    if rclone lsd "${RCLONE_REMOTE}:" &> /dev/null; then
        echo "✓ Connection successful!"
        echo ""
        echo "Remote directories:"
        rclone lsd "${RCLONE_REMOTE}:" | head -n 10
    else
        echo "✗ Connection failed"
        echo "Please check your rclone configuration"
    fi
    
    press_enter
}

menu_install_rclone() {
    clear_screen
    print_header
    echo "═══ Install rclone ═══"
    echo ""
    
    if command -v rclone &> /dev/null; then
        echo "Current rclone version:"
        rclone version | head -n 1
        echo ""
        read -p "Reinstall rclone? [y/N]: " reinstall
        [[ "$reinstall" != "y" ]] && return
    fi
    
    install_rclone
    
    press_enter
}

menu_install_script() {
    clear_screen
    print_header
    echo "═══ Install Script Globally ═══"
    echo ""
    
    local install_dir="${HOME}/.local/bin"
    local script_path="$(readlink -f "${SCRIPT_DIR}/sync-keepass.sh")"
    local link_path="${install_dir}/keepass-sync"
    
    if [[ -L "$link_path" ]]; then
        echo "Script already installed at: $link_path"
        read -p "Reinstall? [y/N]: " reinstall
        [[ "$reinstall" != "y" ]] && return
    fi
    
    mkdir -p "$install_dir"
    ln -sf "$script_path" "$link_path"
    
    echo "✓ Script installed to: $link_path"
    echo ""
    
    if [[ ":$PATH:" != *":${install_dir}:"* ]]; then
        echo "⚠ ${install_dir} is not in your PATH"
        echo ""
        echo "Add this to your ~/.bashrc or ~/.zshrc:"
        echo "  export PATH=\"\$PATH:${install_dir}\""
        echo ""
        echo "Then run: source ~/.bashrc (or ~/.zshrc)"
    else
        echo "You can now run 'keepass-sync' from anywhere"
    fi
    
    press_enter
}
