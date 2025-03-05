#!/usr/bin/env bash

# Detect OS type
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unsupported OS"
    exit 1
fi

# Function to confirm before updating the OS
confirm_os_update() {
    read -p "Do you want to update the system packages before installation? (y/N): " update_choice
    case "$update_choice" in 
        y|Y ) return 0 ;;  # Proceed with update
        * ) echo "Skipping system update."; return 1 ;;
    esac
}

# Function to check if Terraform is already installed
check_terraform() {
    if command -v terraform &>/dev/null; then
        echo "Terraform is already installed: $(terraform --version)"
        echo "Terraform is located at: $(command -v terraform)"
        read -p "Do you want to update Terraform? (y/N): " choice
        case "$choice" in 
            y|Y ) return 0 ;;  # Proceed with update
            * ) echo "Skipping Terraform installation."; exit 0 ;;
        esac
    fi
}

# Function to install Terraform on Debian/Ubuntu
install_terraform_debian() {
    echo "Installing Terraform on Debian/Ubuntu..."
    confirm_os_update && sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt-get install -y terraform
}

# Function to install Terraform on CentOS/RHEL
install_terraform_rhel() {
    echo "Installing Terraform on CentOS/RHEL..."
    confirm_os_update && sudo yum update -y
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum install -y terraform
}

# Function to install Terraform on Fedora
install_terraform_fedora() {
    echo "Installing Terraform on Fedora..."
    confirm_os_update && sudo dnf update -y
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf install -y terraform
}

# Function to install Terraform on Arch Linux
install_terraform_arch() {
    echo "Installing Terraform on Arch Linux..."
    confirm_os_update && sudo pacman -Syu --noconfirm
    sudo pacman -Sy --noconfirm terraform
}

# Function to verify Terraform installation and find its location
verify_installation() {
    if command -v terraform &>/dev/null; then
        echo "✅ Terraform installation successful: $(terraform --version)"
        echo "Terraform binary location: $(command -v terraform)"
        echo "Your PATH environment variable: $PATH"
    else
        echo "❌ Terraform installation failed."
        exit 1
    fi
}

# Check if Terraform is already installed
check_terraform

# Install Terraform based on detected OS
case "$OS" in
    ubuntu|debian)
        install_terraform_debian
        ;;
    centos|rhel)
        install_terraform_rhel
        ;;
    fedora)
        install_terraform_fedora
        ;;
    arch)
        install_terraform_arch
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Verify installation and display path
verify_installation

