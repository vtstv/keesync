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
        if [[ "$reconfigure" =~ ^[Yy]$ ]]; then
            rclone config delete "$remote" 2>/dev/null || true
        else
            return 0
        fi
    fi
    
    echo "Setting up Google Drive authentication"
    echo ""
    echo "Follow these steps in the wizard:"
    echo "  1. New remote: n"
    echo "  2. Name: $remote"
    echo "  3. Storage type: drive"
    echo "  4. Client ID: [press Enter]"
    echo "  5. Client secret: [press Enter]"
    echo "  6. Scope: 1"
    echo "  7. Root folder: [press Enter]"
    echo "  8. Service account: [press Enter]"
    echo "  9. Advanced config: n"
    echo "  10. Auto config: y [browser opens]"
    echo "  11. Team drive: n"
    echo "  12. Confirm: y"
    echo "  13. Quit: q"
    echo ""
    read -p "Press Enter to start..."
    
    rclone config
    
    echo ""
    echo "Testing connection..."
    if rclone lsd "${remote}:" &> /dev/null; then
        echo "✓ Successfully connected to Google Drive!"
    else
        echo "✗ Failed to connect"
        echo "You can try again or reconnect with: rclone config reconnect ${remote}:"
        return 1
    fi
}
