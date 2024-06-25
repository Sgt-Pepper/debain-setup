#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Starting post-installation setup..."

# 1. Automatically get the name of the main user (assuming the user with the highest UID is the main user)
MAIN_USER=$(getent passwd {1000..60000} | awk -F: '$3 == 1000 {print $1}')
echo "Main user detected: $MAIN_USER"

# 2. Add the user to the sudo group
echo "Adding $MAIN_USER to sudo group..."
usermod -aG sudo $MAIN_USER

# 3. Set apt sources to include main, contrib, non-free, and non-free-firmware
echo "Setting up apt sources..."
cat > /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian bookworm           main contrib non-free non-free-firmware 
deb http://deb.debian.org/debian bookworm-updates   main contrib non-free non-free-firmware 
deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main non-free-firmware non-free contrib
EOF

# 4. Set up additional repositories for VSCode and Chrome
echo "Adding VSCode and Google Chrome repositories..."

# VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/vscode.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

# Google Chrome
wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Update apt repositories
echo "Updating apt repositories..."
apt update

# 5. Install Chrome, VS Code, Git, Rust, Go, Python, build essentials, and neofetch
echo "Installing software packages..."
apt install -y google-chrome-stable code git rustc golang python3 build-essential neofetch htop

# 6. Remove LibreOffice and Evolution
echo "Removing LibreOffice and Evolution..."
apt remove -y --purge libreoffice* evolution

# Clean up
echo "Cleaning up..."
apt autoremove -y

echo "Post-installation setup completed successfully."
