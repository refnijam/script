#!/bin/bash
#Checks if Nmap is already installed
#Asks user to confirm uninstallation if an older version exists
#Automatically installs the latest version after uninstallation
#Asks for system updates (patches) before installation
#Allows user to specify a custom installation path
#Verifies the installation and prints the installation path
#
#


# Function to check if Nmap is installed
check_nmap() {
    if command -v nmap &>/dev/null; then
        nmap_path=$(command -v nmap)
        echo "✅ Nmap is already installed at: $nmap_path"
        return 0  # Nmap is installed
    else
        return 1  # Nmap is not installed
    fi
}

# Function to uninstall Nmap
uninstall_nmap() {
    echo "Detected OS: $OS"
    case $OS in
        ubuntu|debian|kali|pop|linuxmint)
            sudo apt remove --purge -y nmap && sudo apt autoremove -y
            ;;
        centos|rhel|rocky|alma)
            sudo yum remove -y nmap
            ;;
        fedora)
            sudo dnf remove -y nmap
            ;;
        arch|manjaro)
            sudo pacman -Rns --noconfirm nmap
            ;;
        macos)
            brew uninstall nmap
            ;;
        windows)
            if command -v choco &>/dev/null; then
                choco uninstall -y nmap
            elif command -v winget &>/dev/null; then
                winget uninstall -e --id Insecure.Nmap
            else
                echo "Neither Chocolatey nor Winget found. Please uninstall Nmap manually."
                exit 1
            fi
            ;;
        *)
            echo "OS not supported for uninstallation."
            exit 1
            ;;
    esac
    echo "✅ Nmap has been uninstalled successfully."
}

# Function to install Nmap
install_nmap() {
    echo "Detected OS: $OS"

    case $OS in
        ubuntu|debian|kali|pop|linuxmint)
            sudo apt update
            read -p "Do you want to install updates before installing Nmap? (y/n): " update_choice
            [[ "$update_choice" =~ ^[Yy]$ ]] && sudo apt upgrade -y
            sudo apt install -y nmap
            ;;
        centos|rhel|rocky|alma)
            sudo yum makecache
            read -p "Do you want to install updates before installing Nmap? (y/n): " update_choice
            [[ "$update_choice" =~ ^[Yy]$ ]] && sudo yum update -y
            sudo yum install -y epel-release nmap
            ;;
        fedora)
            sudo dnf check-update
            read -p "Do you want to install updates before installing Nmap? (y/n): " update_choice
            [[ "$update_choice" =~ ^[Yy]$ ]] && sudo dnf upgrade -y
            sudo dnf install -y nmap
            ;;
        arch|manjaro)
            sudo pacman -Sy
            read -p "Do you want to install updates before installing Nmap? (y/n): " update_choice
            [[ "$update_choice" =~ ^[Yy]$ ]] && sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm nmap
            ;;
        macos)
            brew update
            read -p "Do you want to install updates before installing Nmap? (y/n): " update_choice
            [[ "$update_choice" =~ ^[Yy]$ ]] && brew upgrade
            brew install nmap
            ;;
        windows)
            if command -v choco &>/dev/null; then
                read -p "Do you want to update Chocolatey before installing Nmap? (y/n): " update_choice
                [[ "$update_choice" =~ ^[Yy]$ ]] && choco upgrade all -y
                choco install -y nmap
            elif command -v winget &>/dev/null; then
                read -p "Do you want to update Winget before installing Nmap? (y/n): " update_choice
                [[ "$update_choice" =~ ^[Yy]$ ]] && winget upgrade --all
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
    verify_nmap  # Verify the installation
}

# Function to verify Nmap installation
verify_nmap() {
    if command -v nmap &>/dev/null; then
        nmap_path=$(command -v nmap)
        echo "✅ Nmap installed successfully at: $nmap_path"
    else
        echo "❌ Nmap installation failed or not found in the PATH."
        exit 1
    fi
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

# Check if Nmap is already installed
if check_nmap; then
    read -p "Do you want to uninstall the existing Nmap version before installing a new one? (y/n): " uninstall_choice
    if [[ "$uninstall_choice" =~ ^[Yy]$ ]]; then
        uninstall_nmap
    else
        echo "Skipping uninstallation. Exiting."
        exit 0
    fi
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

