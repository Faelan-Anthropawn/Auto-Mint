#!/usr/bin/env bash

set -e

sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

echo "=============================="
echo "Mint Workstation Bootstrap"
echo "=============================="

########################################
# Update system
########################################
echo "Updating packages..."
sudo apt update
sudo apt upgrade -y

# install common video dependencies

echo "Installing dependencies: ffmpeg, xdotool, and x11-utils..."

sudo apt update
sudo apt install -y \
ffmpeg \
xdotool \
x11-utils

########################################
# Install base packages
########################################
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

########################################
# Verbose boot logging
########################################
echo "Configuring verbose boot..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=7"/' /etc/default/grub
sudo update-grub

########################################
# Remove Plymouth splash
########################################
echo "Removing splash screen..."
sudo apt remove -y plymouth-theme* || true
sudo update-initramfs -u

########################################
# Remove Firefox + Thunderbird
########################################
echo "Removing Firefox and Thunderbird..."
sudo apt purge -y firefox thunderbird || true
sudo apt autoremove -y




########################################
# Install Java (Temurin)
########################################
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

########################################
# Themes and cursor
########################################
echo "Installing themes..."
sudo apt install -y mint-y-icons

mkdir -p ~/.icons
cd /tmp

wget -q https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz
tar -xf Bibata-Modern-Classic.tar.xz

# remove old cursor folder if exists
rm -rf ~/.icons/Bibata-Modern-Classic
mv Bibata-Modern-Classic ~/.icons/

########################################
# Cinnamon appearance
########################################
echo "Applying Cinnamon settings..."
gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark-Orange"
gsettings set org.cinnamon.desktop.wm.preferences theme "Mint-Y-Dark-Orange"
gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y-Yaru"
gsettings set org.cinnamon.theme name "Cinnamon"
gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Modern-Classic"

gsettings set com.linuxmint.updates hide-systray true

########################################
# Fonts
########################################
echo "Applying fonts..."
gsettings set org.cinnamon.desktop.interface font-name "Ubuntu Bold 10"
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "Ubuntu Medium 10"

########################################
# Touchpad
########################################
echo "Configuring touchpad..."
gsettings set org.cinnamon.desktop.peripherals.touchpad natural-scroll false
gsettings set org.cinnamon.desktop.peripherals.touchpad click-method 'fingers'

########################################
# Screen timeout
########################################
echo "Setting idle timeout..."
gsettings set org.cinnamon.desktop.session idle-delay 600

########################################
# Finished
########################################
echo ""
echo "=============================="
echo "Bootstrap Complete"
echo "=============================="
echo ""
echo "Recommended: Reboot to apply GRUB changes."
