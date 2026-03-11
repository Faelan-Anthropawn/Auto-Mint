#!/usr/bin/env bash
set -e

sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

echo "=============================="
echo "Auto Mint Setup"
echo "=============================="

########################################
# Update system and install dependencies
########################################
echo "Updating packages..."
sudo apt update
sudo apt upgrade -y

echo "Installing dependencies: ffmpeg, xdotool, and x11-utils..."

sudo apt update
sudo apt install -y \
ffmpeg \
xdotool \
x11-utils

echo "Installing Java..."
sudo apt remove --purge -y '*java*' '*jdk*' '*jre*' || true
sudo apt autoremove -y

wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
| gpg --dearmor \
| sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null

echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^UBUNTU_CODENAME/{print$2}' /etc/os-release) main" \
| sudo tee /etc/apt/sources.list.d/adoptium.list

sudo apt update
sudo apt install -y temurin-25-jdk

echo "Installing base tools..."
sudo apt install -y \
curl \
wget \
git \
xsecurelock \
xss-lock \
nodejs \
apt-transport-https \
gpg

echo "Removing Firefox and Thunderbird..."
sudo apt purge -y firefox thunderbird || true
sudo apt autoremove -y

########################################
# Call other scripts
########################################

curl -fsSL https://raw.githubusercontent.com/Faelan-Anthropawn/Auto-Mint/refs/heads/main/xsecure.sh | bash

curl -fsSL https://raw.githubusercontent.com/Faelan-Anthropawn/Auto-Mint/refs/heads/main/cinn.sh | bash

curl -fsSL https://github.com/Faelan-Anthropawn/Auto-Mint/raw/refs/heads/main/spices/spices.sh | bash

curl -fsSL https://github.com/Faelan-Anthropawn/Auto-Mint/raw/refs/heads/main/proton/vpn.sh | bash

curl -fsSL https://github.com/Faelan-Anthropawn/Auto-Mint/raw/refs/heads/main/brave/brave.sh | bash


echo ""
echo "=============================="
echo "Auto Mint Setup Complete"
echo "=============================="
echo ""
echo "Recommended: Reboot to apply GRUB changes."
