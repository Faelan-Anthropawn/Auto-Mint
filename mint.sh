#!/usr/bin/env bash

set -e

# keep sudo alive
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
# Configure xsecurelock
########################################

echo "Configuring xsecurelock..."

if [ ! -f ~/.xinitrc ]; then
cat > ~/.xinitrc <<'EOF'
xss-lock --transfer-sleep-lock -- xsecurelock &
exec dbus-run-session cinnamon-session
EOF
fi

########################################
# Disable Cinnamon lockscreen
########################################

echo "Disabling Cinnamon lockscreen..."

gsettings set org.cinnamon.desktop.screensaver lock-enabled false

########################################
# Verbose boot
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
# Install Brave
########################################

echo "Installing Brave..."

curl -fsS https://dl.brave.com/install.sh | sh

########################################
# Brave hardened configuration
########################################

echo "Applying Brave enterprise policies..."

sudo mkdir -p /etc/brave/policies/managed

sudo tee /etc/brave/policies/managed/policies.json > /dev/null <<'EOF'
{
  "HomepageIsNewTabPage": true,
  "RestoreOnStartup": 1,
  "ShowBookmarksBar": true,
  "BookmarkBarEnabled": true,

  "PasswordManagerEnabled": false,
  "EnableDoNotTrack": true,
  "HardwareAccelerationModeEnabled": false,
  "BackgroundModeEnabled": false,

  "BlockThirdPartyCookies": true,

  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,

  "MetricsReportingEnabled": false,
  "SigninAllowed": false,

  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "DuckDuckGo",
  "DefaultSearchProviderSearchURL": "https://duckduckgo.com/?q={searchTerms}",

  "ClearBrowsingDataOnExitList": [
    "browsing_history",
    "download_history",
    "cookies_and_other_site_data",
    "cached_images_and_files"
  ],

  "HttpsUpgradesEnabled": true,
  "BraveShieldsDefault": 2,

  "WebRtcIPHandlingPolicy": "disable_non_proxied_udp",

  "MemorySaverModeEnabled": true,

  "ExtensionInstallSources": [
    "https://clients2.google.com/service/update2/crx"
  ],

  "ExtensionInstallForcelist": [
    "ghmbeldphafepmbegfdlkpapadhbakde;https://clients2.google.com/service/update2/crx"
  ],

  "ManagedBookmarks": [
    {
      "toplevel_name": "Managed"
    },
    {
      "name": "Drive",
      "url": "https://duckduckgo.com"
    },
    {
      "name": "Mail",
      "url": "https://mail.proton.me"
    },
    {
      "name": "Sparked",
      "url": "https://control.sparkedhost.us/server/ea179819"
    },
    {
      "name": "Website",
      "children": [
        {
          "name": "Github",
          "url": "https://drive.proton.me"
        },
        {
          "name": "Cloudflare",
          "url": "https://dash.cloudflare.com/login"
        },
        {
          "name": "Replit",
          "url": "https://calendar.proton.me"
        }
      ]
    }
  ]
}
EOF

########################################
# Install ProtonVPN
########################################

echo "Installing ProtonVPN..."

TMPDIR=$(mktemp -d)
cd "$TMPDIR"

wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb

sudo dpkg -i protonvpn-stable-release_1.0.8_all.deb
sudo apt update
sudo apt install -y proton-vpn-gnome-desktop

cd ~
rm -rf "$TMPDIR"

########################################
# ProtonVPN autostart
########################################

echo "Creating ProtonVPN autostart..."

mkdir -p ~/.local/bin

cat > ~/.local/bin/protonvpn-autostart <<'EOF'
#!/bin/bash

until gdbus call --session \
  --dest org.freedesktop.secrets \
  --object-path /org/freedesktop/secrets \
  --method org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1
do
  sleep 1
done

protonvpn-app
EOF

chmod +x ~/.local/bin/protonvpn-autostart

mkdir -p ~/.config/autostart

cat > ~/.config/autostart/protonvpn.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=$HOME/.local/bin/protonvpn-autostart
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=ProtonVPN
EOF

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
# Themes
########################################

echo "Installing themes..."

sudo apt install -y mint-y-icons

mkdir -p ~/.icons
cd /tmp

wget -q https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz
tar -xf Bibata-Modern-Classic.tar.xz

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

gsettings set org.cinnamon first-launch false
gsettings set com.linuxmint.updates hide-systray true

########################################
# Fonts
########################################

echo "Applying fonts..."

gsettings set org.cinnamon.desktop.interface font-name "Ubuntu Bold 10"
gsettings set org.cinnamon.desktop.interface document-font-name "Ubuntu Bold 10"
gsettings set org.cinnamon.desktop.interface monospace-font-name "Ubuntu Bold 10"
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "Ubuntu Medium 10"

########################################
# Touchpad
########################################

echo "Configuring touchpad..."

gsettings set org.cinnamon.desktop.peripherals.touchpad natural-scroll false
gsettings set org.cinnamon.desktop.peripherals.touchpad click-method 'fingers'
gsettings set org.cinnamon.desktop.peripherals.touchpad tap-to-click true
gsettings set org.cinnamon.desktop.peripherals.touchpad tap-button-map 'lrm'

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
