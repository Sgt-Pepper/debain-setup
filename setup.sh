#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# 1. Automatically get the name of the main user (assuming the user with the highest UID is the main user)
MAIN_USER=$(getent passwd {1000..60000} | awk -F: '$3 == 1000 {print $1}')
echo "Main user detected: $MAIN_USER"

# 2. Add the user to the sudo group
usermod -aG sudo $MAIN_USER

# 3. Set apt sources to include main, contrib, non-free, and non-free-firmware
cat > /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian/ $(lsb_release -sc) main contrib non-free
deb-src http://deb.debian.org/debian/ $(lsb_release -sc) main contrib non-free

deb http://deb.debian.org/debian/ $(lsb_release -sc)-updates main contrib non-free
deb-src http://deb.debian.org/debian/ $(lsb_release -sc)-updates main contrib non-free

deb http://deb.debian.org/debian-security $(lsb_release -sc)-security main contrib non-free
deb-src http://deb.debian.org/debian-security $(lsb_release -sc)-security main contrib non-free

deb http://deb.debian.org/debian/ $(lsb_release -sc)-backports main contrib non-free
deb-src http://deb.debian.org/debian/ $(lsb_release -sc)-backports main contrib non-free
EOF

# 4. Set up additional repositories for VSCode and Chrome
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Update apt repositories
apt update

# 5. Install Chrome, VS Code, Git, Rust, Go, Python, build essentials, and neofetch
apt install -y google-chrome-stable code git rustc golang python3 build-essential neofetch

# 6. Remove LibreOffice and Evolution
apt remove -y --purge libreoffice* evolution

# Clean up
apt autoremove -y
