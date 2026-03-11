#!/usr/bin/env bash

set -e

sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

########################################
# Install Brave
########################################

echo "Installing Brave..."
curl -fsS https://dl.brave.com/install.sh | sh

########################################
# Brave Enterprise Policies
########################################

echo "Applying Brave enterprise policies..."

sudo mkdir -p /etc/brave-browser/policies/managed

sudo tee /etc/brave-browser/policies/managed/policies.json > /dev/null << 'EOF'
{
  "HomepageIsNewTabPage": true,
  "RestoreOnStartup": 1,

  "PasswordManagerEnabled": false,
  "AutofillAddressEnabled": false,
  "AutofillCreditCardEnabled": false,

  "EnableDoNotTrack": true,
  "EnableReferrers": false,

  "HardwareAccelerationModeEnabled": false,
  "BackgroundModeEnabled": false,
  "BackgroundNetworkingEnabled": false,

  "BlockThirdPartyCookies": true,
  "CookieControlsMode": 2,

  "MetricsReportingEnabled": false,
  "SigninAllowed": false,
  "SyncDisabled": true,

  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "BraveShieldsEnabled": true,
  "BraveShieldsDefault": 2,

  "HttpsUpgradesEnabled": true,

  "WebRtcIPHandlingPolicy": "disable_non_proxied_udp",
  "WebRTCUDPPortRange": "0-0",

  "ClearBrowsingDataOnExitList": [
    "browsing_history",
    "download_history",
    "cookies_and_other_site_data",
    "cached_images_and_files",
    "passwords",
    "autofill_data",
    "site_settings",
    "shields_settings",
    "hosted_app_data"
  ],

  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "DuckDuckGo",
  "DefaultSearchProviderSearchURL": "https://duckduckgo.com/?q={searchTerms}",

  "NetworkPredictionOptions": 2,
  "AlternateErrorPagesEnabled": false,

  "SafeBrowsingEnabled": false,
  "SafeBrowsingExtendedReportingEnabled": false,
  "SearchSuggestEnabled": false,

  "ExtensionInstallSources": [
    "https://clients2.google.com/service/update2/crx"
  ],

  "ExtensionInstallForcelist": [
    "ghmbeldphafepmbegfdlkpapadhbakde;https://clients2.google.com/service/update2/crx"
  ],

  "BlockFingerprinting": true,
  "ShowBookmarkBar": "always"
}
EOF

########################################
# Fix Policy Permissions
########################################

sudo chmod -R 755 /etc/brave-browser/policies

########################################
# backup Preferences install
########################################

echo "Stopping Brave if it’s running..."
pkill brave-browser 2>/dev/null || true

echo "Fetching custom Preferences file..."
PREF_URL="https://raw.githubusercontent.com/Faelan-Anthropawn/Auto-Mint/main/Preferences"
BRAVE_PREF_DIR="$HOME/.config/BraveSoftware/Brave-Browser"

# Ensure the config directory exists
mkdir -p "$BRAVE_PREF_DIR"

# Download and overwrite Brave Preferences
curl -fsSL "$PREF_URL" -o "$BRAVE_PREF_DIR/Preferences"

echo "Preferences successfully applied."

########################################
# Harden Brave Launch Flags
########################################

echo "Applying Brave hardened launch flags..."

sudo sed -i 's|Exec=brave-browser|Exec=brave-browser --disable-background-networking --disable-sync --disable-domain-reliability --disable-component-update --disable-features=InterestCohort,PrivacySandboxSettings4,AutofillServerCommunication --force-webrtc-ip-handling-policy=disable_non_proxied_udp|' /usr/share/applications/brave-browser.desktop

echo "Brave hardened setup complete."
echo "Brave hardened setup complete."
echo " Complete"
echo ""
echo "Recommended: Reboot to apply GRUB changes."
