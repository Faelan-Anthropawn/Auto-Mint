#!/bin/bash
########################################
# boot logging
########################################
echo "Configuring verbose boot..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=7"/' /etc/default/grub
sudo update-grub

echo "Removing splash screen..."
sudo apt remove -y plymouth-theme* || true
sudo update-initramfs -u

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
