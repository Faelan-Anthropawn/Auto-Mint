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

  "BlockThirdPartyCookies": true,  # Aggressive blocking of third-party cookies
  "CookieControlsMode": 1,  # Strict cookie blocking

  "MetricsReportingEnabled": false,
  "SigninAllowed": false,
  "SyncDisabled": true,

  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "BraveShieldsEnabled": true,
  "BraveShieldsDefault": 2,  # Shields enabled by default for enhanced privacy

  "HttpsUpgradesEnabled": true,
  "WebRtcIPHandlingPolicy": "disable_non_proxied_udp",  # WebRTC IP handling policy
  "WebRTCUDPPortRange": "0-0",  # Blocking WebRTC leaks

  "ClearBrowsingDataOnExitList": [
    "browsing_history",
    "download_history",
    "cookies_and_other_site_data",
    "cached_images_and_files",
    "site_settings",  # Deleting site settings on exit
    "passwords",  # Deleting passwords on exit
    "local_storage"  # Deleting local storage on exit
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

  "BlockFingerprinting": true,  # Block browser fingerprinting

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
