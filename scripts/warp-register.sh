#!/bin/bash

set -e

# peek at cloudflare-warp/reg.json
if [ -f "/var/lib/cloudflare-warp/reg.json" ]; then
  printf " >> [warp-register] cloudflare-warp/reg.json 64 bytes > %s\n" "$(head -c64 /var/lib/cloudflare-warp/reg.json)"
fi

# create an appropriate cloudflare-warp/mdm.xml if the data for it exists
if [ -n "${WARP_ORGANIZATION}" ]; then
  if [ -z "${WARP_CLIENT_ID}" ]; then echo " >> [warp-register] WARP_CLIENT_ID not set"; exit 1; fi
  if [ -z "${WARP_CLIENT_SECRET}" ]; then echo " >> [warp-register] WARP_CLIENT_SECRET not set"; exit 1; fi
  if [ -z "${WARP_CONNECTOR_TOKEN}" ]; then echo " >> [warp-register] WARP_CONNECTOR_TOKEN not set"; exit 1; fi

# https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/mdm-deployment/parameters/
cat >/var/lib/cloudflare-warp/mdm.xml <<EOF
<dict>
  <key>organization</key>
  <string>${WARP_ORGANIZATION}</string>
  <key>auth_client_id</key>
  <string>${WARP_CLIENT_ID}</string>
  <key>auth_client_secret</key>
  <string>${WARP_CLIENT_SECRET}</string>
  <key>warp_connector_token</key>
  <string>${WARP_CONNECTOR_TOKEN}</string>
</dict>
EOF
fi

if [ -f "/var/lib/cloudflare-warp/mdm.xml" ]; then
  printf " >> [warp-register] cloudflare-warp/mdm.xml file present > %s\n" "$(ls -al /var/lib/cloudflare-warp/mdm.xml)"
fi

if [ "$(warp-cli registration show 2>&1 | grep -c -i 'error')" -gt 0 ]; then
  echo " >> [warp-register] registering Warp client"
  sudo rm -f /var/lib/cloudflare-warp/reg.json
  warp-cli registration new

  # if license key is provided, set it
  if [ -n "$WARP_LICENSE_KEY" ]; then
      echo " >> [warp-register] adding Warp license to registration"
      warp-cli set-license "$WARP_LICENSE_KEY"
  fi

  sleep "${WARP_START_DELAY}"
fi

# Show the warp registration detail
echo " >> [warp-connect] show the Warp registration details."
warp-cli registration show || true
