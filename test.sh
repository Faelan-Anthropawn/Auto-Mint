#!/usr/bin/env bash

set -e

sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

########################################
# Install Brave
########################################

echo "Installing Brave v1..."
curl -fsS https://dl.brave.com/install.sh | sh

########################################
# Brave Enterprise Policies
########################################

echo "Applying Brave enterprise policies..."

sudo mkdir -p /etc/brave-browser/policies/managed

sudo tee /etc/brave-browser/policies/managed/policies.json > /dev/null <<'EOF'
{
  "HomepageIsNewTabPage": true,
  "RestoreOnStartup": 1,

  "PasswordManagerEnabled": false,
  "AutofillAddressEnabled": false,
  "AutofillCreditCardEnabled": false,

  "EnableDoNotTrack": true,  # Enabling Do Not Track signal
  "EnableReferrers": false,

  "HardwareAccelerationModeEnabled": false,
  "BackgroundModeEnabled": false,
  "BackgroundNetworkingEnabled": false,

  # Aggressive blocking of third-party cookies, ads, and trackers
  "BlockThirdPartyCookies": true,  
  "CookieControlsMode": 2,  # Strict cookie blocking and data protection

  "MetricsReportingEnabled": false,
  "SigninAllowed": false,
  "SyncDisabled": true,

  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "BraveShieldsEnabled": true,
  "BraveShieldsDefault": 2,  # Shields enabled by default for enhanced privacy

  # WebRTC handling: disable non-proxied UDP IP leak
  "WebRtcIPHandlingPolicy": "disable_non_proxied_udp", 
  "WebRTCUDPPortRange": "0-0",  # Blocking WebRTC leaks

  # Enforcing Do Not Track
  "EnableDoNotTrack": true,

  # Full Data Deletion on Exit (including history, cookies, autofill, passwords, etc.)
  "ClearBrowsingDataOnExitList": [
    "browsing_history", 
    "download_history", 
    "cookies_and_other_site_data", 
    "leo_ai_data", 
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

  "ManagedBookmarks": [
    {
      "toplevel_name": "Managed"
    },
    {
      "name": "Drive",
      "url": "https://account.proton.me/drive"
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
          "url": "https://github.com/login"
        },
        {
          "name": "Cloudflare",
          "url": "https://dash.cloudflare.com/login"
        },
        {
          "name": "Replit",
          "url": "https://replit.com/login"
        }
      ]
    }
  ],

  "BlockFingerprinting": true,  # Blocking browser fingerprinting

  "ShowBookmarkBar": "always"  # Always show the bookmark bar
}
EOF

########################################
# Fix Policy Permissions
########################################

sudo chmod -R 755 /etc/brave-browser/policies

########################################
# Harden Brave Launch Flags
########################################

echo "Applying Brave hardened launch flags..."

sudo sed -i 's|Exec=brave-browser|Exec=brave-browser --disable-background-networking --disable-sync --disable-domain-reliability --disable-component-update --disable-features=InterestCohort,PrivacySandboxSettings4,AutofillServerCommunication --force-webrtc-ip-handling-policy=disable_non_proxied_udp|' /usr/share/applications/brave-browser.desktop

echo "Brave hardened setup complete."
echo " Complete"
echo ""
echo "Recommended: Reboot to apply GRUB changes."
