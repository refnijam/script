#universal_health_check.sh

#!/bin/bash

echo "=== Universal Linux Server Health Check ==="

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VERSION=$VERSION_ID
else
    echo "Cannot detect OS."
    exit 1
fi

echo -e "\nDetected OS: $PRETTY_NAME"

# Install necessary tools depending on distro
install_tools() {
    case "$OS_NAME" in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y dnsutils net-tools stress
            ;;
        centos|rhel|amzn)
            sudo yum install -y bind-utils net-tools stress
            ;;
        suse|opensuse)
            sudo zypper install -y bind-utils net-tools stress
            ;;
        *)
            echo "Unsupported or unknown distribution: $OS_NAME"
            ;;
    esac
}

install_tools

# Uptime
echo -e "\n--- Uptime ---"
uptime

# Hostname & IP
echo -e "\n--- Hostname and IP ---"
hostname
hostname -I 2>/dev/null || ip addr | grep inet

# Memory
echo -e "\n--- Memory Usage ---"
free -h || cat /proc/meminfo

# CPU Load
echo -e "\n--- CPU Load ---"
top -b -n 1 | head -n 10

# Disk Usage
echo -e "\n--- Disk Usage ---"
df -h

# Open Ports
echo -e "\n--- Listening Ports ---"
ss -tuln || netstat -tuln

# Ping Test
echo -e "\n--- Network Test (Ping Google) ---"
ping -c 4 google.com

# DNS Test
echo -e "\n--- DNS Resolution ---"
nslookup google.com || dig google.com || echo "DNS test failed (install dig or nslookup?)"

# Optional stress test
read -p $'\nDo you want to run a CPU/Memory stress test? (y/n): ' stress_choice
if [[ "$stress_choice" == "y" ]]; then
    echo "Running light stress test for 30 seconds..."
    stress --cpu 2 --vm 1 --vm-bytes 128M --timeout 30s
else
    echo "Skipped stress test."
fi

echo -e "\n=== Health Check Complete ==="
