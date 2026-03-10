#!/usr/bin/env bash

set -Eeuo pipefail

LOGFILE="$HOME/bootstrap.log"

exec > >(tee -a "$LOGFILE") 2>&1

trap 'echo "❌ Error on line $LINENO"; exit 1' ERR

echo "=============================="
echo "Mint Workstation Bootstrap"
echo "Log: $LOGFILE"
echo "=============================="

########################################
# Helpers
########################################

ensure_dir() {
    mkdir -p "$1"
}

install_if_missing() {
    if ! dpkg -s "$1" >/dev/null 2>&1; then
        sudo apt install -y "$1"
    else
        echo "$1 already installed"
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

########################################
# Sudo
########################################

sudo -v

while true; do
    sudo -n true
    sleep 60
done 2>/dev/null &

########################################
# Update system
########################################

echo "Updating system..."

sudo apt update
sudo apt upgrade -y

########################################
# Base packages
########################################

echo "Installing base packages..."

BASE_PACKAGES=(
curl
wget
git
xsecurelock
xss-lock
nodejs
apt-transport-https
gpg
)

for pkg in "${BASE_PACKAGES[@]}"; do
    install_if_missing "$pkg"
done

########################################
# xsecurelock config
########################################

echo "Configuring xsecurelock..."

if [[ ! -f "$HOME/.xinitrc" ]]; then
cat > "$HOME/.xinitrc" <<'EOF'
xss-lock --transfer-sleep-lock -- xsecurelock &
exec dbus-run-session cinnamon-session
EOF
fi

########################################
# Disable Cinnamon lockscreen
########################################

echo "Disabling Cinnamon lockscreen..."

gsettings set org.cinnamon.desktop.screensaver lock-enabled false || true

########################################
# Verbose boot
########################################

echo "Configuring verbose boot..."

if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub; then
sudo sed -i \
's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=7"/' \
/etc/default/grub
else
echo 'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=7"' \
| sudo tee -a /etc/default/grub
fi

sudo update-grub

########################################
# Remove Plymouth splash
########################################

echo "Removing splash screen..."

sudo apt remove -y plymouth-theme* || true
sudo update-initramfs -u

########################################
# Install Brave
########################################

echo "Installing Brave..."

if ! command_exists brave-browser; then

sudo mkdir -p /etc/apt/keyrings

curl -fsS https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
| sudo tee /etc/apt/keyrings/brave-browser.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/brave-browser.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
| sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update
sudo apt install -y brave-browser

else
echo "Brave already installed"
fi

########################################
# Brave enterprise policies
########################################

echo "Configuring Brave policies..."

sudo mkdir -p /etc/brave/policies/managed

sudo tee /etc/brave/policies/managed/policies.json >/dev/null <<'EOF'
{
  "HomepageIsNewTabPage": true,
  "RestoreOnStartup": 1,
  "ShowBookmarksBar": true,
  "PasswordManagerEnabled": false,
  "EnableDoNotTrack": true,
  "HardwareAccelerationModeEnabled": false,
  "BlockThirdPartyCookies": true,
  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "MetricsReportingEnabled": false,
  "SigninAllowed": false,
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "DuckDuckGo",
  "DefaultSearchProviderSearchURL": "https://duckduckgo.com/?q={searchTerms}",
  "HttpsUpgradesEnabled": true,
  "BraveShieldsDefault": 2
}
EOF

########################################
# Install ProtonVPN
########################################

echo "Installing ProtonVPN..."

if ! command_exists protonvpn-app; then

TMPDIR=$(mktemp -d)
pushd "$TMPDIR" >/dev/null

wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb

sudo dpkg -i protonvpn-stable-release_1.0.8_all.deb
sudo apt update
sudo apt install -y proton-vpn-gnome-desktop

popd >/dev/null
rm -rf "$TMPDIR"

fi

########################################
# ProtonVPN autostart
########################################

echo "Configuring ProtonVPN autostart..."

ensure_dir "$HOME/.local/bin"
ensure_dir "$HOME/.config/autostart"

cat > "$HOME/.local/bin/protonvpn-autostart" <<'EOF'
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

chmod +x "$HOME/.local/bin/protonvpn-autostart"

cat > "$HOME/.config/autostart/protonvpn.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=$HOME/.local/bin/protonvpn-autostart
X-GNOME-Autostart-enabled=true
Name=ProtonVPN
EOF

########################################
# Java (Temurin)
########################################

echo "Installing Java..."

sudo apt purge -y '*java*' '*jdk*' '*jre*' || true
sudo apt autoremove -y

sudo mkdir -p /etc/apt/keyrings

wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
| gpg --dearmor \
| sudo tee /etc/apt/keyrings/adoptium.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
| sudo tee /etc/apt/sources.list.d/adoptium.list

sudo apt update
sudo apt install -y temurin-25-jdk

########################################
# Themes
########################################

echo "Installing themes..."

install_if_missing mint-y-icons

ensure_dir "$HOME/.icons"

TMPDIR=$(mktemp -d)
pushd "$TMPDIR" >/dev/null

wget -q https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz

tar -xf Bibata-Modern-Classic.tar.xz
mv Bibata-Modern-Classic "$HOME/.icons/"

popd >/dev/null
rm -rf "$TMPDIR"

########################################
# Remove Firefox / Thunderbird
########################################

echo "Removing Firefox and Thunderbird..."

sudo apt purge -y firefox thunderbird || true
sudo apt autoremove -y

xdg-settings set default-web-browser brave-browser.desktop || true

########################################
# Cinnamon UI settings
########################################

echo "Applying Cinnamon settings..."

gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark-Orange" || true
gsettings set org.cinnamon.desktop.wm.preferences theme "Mint-Y-Dark-Orange" || true
gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y-Yaru" || true
gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Modern-Classic" || true

########################################
# Idle timeout
########################################

gsettings set org.cinnamon.desktop.session idle-delay 600 || true

########################################
# Finished
########################################

echo ""
echo "=============================="
echo "Bootstrap Complete"
echo "=============================="
echo ""
echo "Log saved to:"
echo "$LOGFILE"
echo ""
echo "Recommended: reboot to apply GRUB changes."
