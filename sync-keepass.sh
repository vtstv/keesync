#!/bin/bash
# Copyright (c) Murr
# GitHub: https://github.com/vtstv

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/rclone.sh"
source "${SCRIPT_DIR}/lib/sync.sh"
source "${SCRIPT_DIR}/lib/cron.sh"
source "${SCRIPT_DIR}/lib/menu.sh"

show_usage() {
    cat << EOF
Usage: $(basename "$0") [COMMAND]

Commands:
    menu        Show interactive menu (default)
    setup       Configure rclone and sync settings
    sync        Perform sync operation
    cron        Manage cron job
    help        Show this help message

EOF
    exit 0
}

main() {
    case "${1:-menu}" in
        menu)
            show_main_menu
            ;;
        setup)
            setup_rclone
            setup_config
            ;;
        sync)
            perform_sync
            ;;
        cron)
            manage_cron "${2:-}"
            ;;
        help)
            show_usage
            ;;
        *)
            show_main_menu
            ;;
    esac
}

main "$@"
