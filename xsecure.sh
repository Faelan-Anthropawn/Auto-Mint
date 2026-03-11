#!/bin/bash
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

echo "=============================="
echo "Configuring xss-lock"
echo "=============================="

gsettings set org.cinnamon.desktop.screensaver lock-enabled false

xset s 300 300
xset +dpms
xset dpms 300 300 300

xss-lock --transfer-sleep-lock -- xsecurelock &

mkdir -p ~/.config/autostart
cat > ~/.config/autostart/xss-lock.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=xss-lock
Exec=/usr/bin/xss-lock --transfer-sleep-lock -- xsecurelock
X-GNOME-Autostart-enabled=true
NoDisplay=false
EOF

echo "Creating systemd service for xss-lock..."
sudo tee /etc/systemd/system/xss-lock-suspend.service > /dev/null <<'EOF'
[Unit]
Description=Lock screen before suspend
Before=sleep.target

[Service]
Type=simple
ExecStart=/usr/bin/xss-lock --transfer-sleep-lock -- xsecurelock

[Install]
WantedBy=sleep.target
EOF

sudo systemctl enable xss-lock-suspend.service

echo "Setting idle timeout..."
gsettings set org.cinnamon.desktop.session idle-delay 600

echo ""
echo "=============================="
echo "xss-lock configuration complete"
echo "=============================="
