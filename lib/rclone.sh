#!/bin/bash
# Copyright (c) Murr
# GitHub: https://github.com/vtstv

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

install_rclone() {
    local distro=$(detect_distro)
    
    echo "Installing rclone for $distro..."
    echo ""
    
    case "$distro" in
        arch|manjaro|endeavouros|garuda|cachyos|artix)
            if command -v yay &> /dev/null; then
                yay -S --noconfirm rclone
            elif command -v paru &> /dev/null; then
                paru -S --noconfirm rclone
            else
                sudo pacman -S --noconfirm rclone
            fi
            ;;
        ubuntu|debian|linuxmint|pop|elementary)
            sudo apt update
            sudo apt install -y rclone
            ;;
        fedora|nobara)
            sudo dnf install -y rclone
            ;;
        opensuse*|suse)
            sudo zypper install -y rclone
            ;;
        *)
            echo "Unsupported distribution: $distro"
            echo "Attempting generic Arch-based installation..."
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm rclone
            else
                echo "Please install rclone manually from: https://rclone.org/install/"
                return 1
            fi
            ;;
    esac
    
    if command -v rclone &> /dev/null; then
        echo "✓ rclone installed successfully"
        return 0
    else
        echo "✗ Installation failed"
        return 1
    fi
}

check_rclone() {
    if ! command -v rclone &> /dev/null; then
        echo "⚠ rclone is not installed"
        echo ""
        read -p "Install rclone now? [Y/n]: " install_choice
        
        if [[ "$install_choice" =~ ^[Nn]$ ]]; then
            echo "Please install rclone manually from: https://rclone.org/install/"
            exit 1
        fi
        
        if ! install_rclone; then
            exit 1
        fi
    fi
}

setup_rclone() {
    check_rclone
    
    load_config
    local remote="${RCLONE_REMOTE:-gdrive}"
    
    if rclone listremotes | grep -q "^${remote}:$"; then
        echo "✓ Remote '${remote}' already configured"
        read -p "Reconfigure? [y/N]: " reconfigure
        if [[ "$reconfigure" != "y" ]]; then
            return 0
        else
            rclone config delete "$remote" 2>/dev/null || true
        fi
    fi
    
    echo "Setting up rclone for Google Drive"
    echo ""
    echo "This will open an interactive setup wizard."
    echo "When prompted:"
    echo "  1. Choose 'n' for new remote"
    echo "  2. Name it: $remote"
    echo "  3. Select 'drive' for Google Drive"
    echo "  4. Press Enter to skip client_id/secret"
    echo "  5. Choose scope 1 (full access)"
    echo "  6. Press Enter for remaining options"
    echo "  7. Choose 'y' for auto config (opens browser)"
    echo "  8. Authenticate in browser"
    echo "  9. Choose 'n' for team drive"
    echo "  10. Choose 'y' to confirm"
    echo "  11. Choose 'q' to quit config"
    echo ""
    read -p "Ready? Press Enter to start..."
    
    rclone config
    
    echo ""
    echo "Testing connection..."
    if rclone lsd "${remote}:" &> /dev/null; then
        echo "✓ Successfully connected to Google Drive!"
    else
        echo "✗ Failed to connect"
        echo "Run setup again if needed"
        return 1
    fi
}
