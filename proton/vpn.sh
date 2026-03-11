#!/bin/bash
########################################
# Install ProtonVPN and add autostart
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

echo "Downloading and overwriting ProtonVPN configuration files..."

mkdir -p ~/.config/ProtonVPN

wget -q https://raw.githubusercontent.com/Faelan-Anthropawn/Auto-Mint/main/proton/app-config.json -O ~/.config/ProtonVPN/app-config.json
wget -q https://raw.githubusercontent.com/Faelan-Anthropawn/Auto-Mint/main/proton/settings.json -O ~/.config/ProtonVPN/settings.json

echo "ProtonVPN configuration files have been successfully overwritten."
