#!/bin/bash

# Function to install Nmap
install_nmap() {
    echo "Detected OS: $OS"

    case $OS in
        ubuntu|debian|kali|pop|linuxmint)
            sudo apt update
            read -p "Do you want to install updates for the system before installing Nmap? (y/n): " update_choice
            if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                sudo apt upgrade -y
            fi
            sudo apt install -y nmap
            ;;
        centos|rhel|rocky|alma)
            sudo yum makecache
            read -p "Do you want to install updates for the system before installing Nmap? (y/n): " update_choice
            if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                sudo yum update -y
            fi
            sudo yum install -y epel-release nmap
            ;;
        fedora)
            sudo dnf check-update
            read -p "Do you want to install updates for the system before installing Nmap? (y/n): " update_choice
            if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                sudo dnf upgrade -y
            fi
            sudo dnf install -y nmap
            ;;
        arch|manjaro)
            sudo pacman -Sy
            read -p "Do you want to install updates for the system before installing Nmap? (y/n): " update_choice
            if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                sudo pacman -Syu --noconfirm
            fi
            sudo pacman -S --noconfirm nmap
            ;;
        macos)
            brew update
            read -p "Do you want to install updates for the system before installing Nmap? (y/n): " update_choice
            if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                brew upgrade
            fi
            brew install nmap
            ;;
        windows)
            if command -v choco &>/dev/null; then
                read -p "Do you want to update Chocolatey before installing Nmap? (y/n): " update_choice
                if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                    choco upgrade all -y
                fi
                choco install -y nmap
            elif command -v winget &>/dev/null; then
                read -p "Do you want to update Winget before installing Nmap? (y/n): " update_choice
                if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                    winget upgrade --all
                fi
                winget install -e --id Insecure.Nmap
            else
                echo "Neither Chocolatey nor Winget found. Install one of them to proceed."
                exit 1
            fi
            ;;
        *)
            echo "OS not supported for automatic installation."
            exit 1
            ;;
    esac

    echo "✅ Nmap installation completed!"
}

# Detect OS
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OS=$ID
elif [[ "$(uname)" == "Darwin" ]]; then
    OS="macos"
elif [[ "$(uname -o 2>/dev/null)" == "Msys" || "$(uname -o 2>/dev/null)" == "Cygwin" ]]; then
    OS="windows"
else
    echo "Unsupported OS detected!"
    exit 1
fi

# Ask for confirmation to install Nmap
read -p "Do you want to install Nmap? (y/n): " install_choice
if [[ "$install_choice" =~ ^[Yy]$ ]]; then

    # Ask for custom installation path (optional)
    read -p "Do you want to specify a custom installation path? (y/n): " path_choice
    if [[ "$path_choice" =~ ^[Yy]$ ]]; then
        read -p "Enter the full path for installation: " install_path
        export PATH="$install_path:$PATH"
        echo "Using custom installation path: $install_path"
    fi

    install_nmap
else
    echo "Installation aborted."
fi

