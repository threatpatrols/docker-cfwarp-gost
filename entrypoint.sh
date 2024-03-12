#!/bin/bash

# exit when any command fails
set -e

# create a tun device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# start the daemon
warp-svc | grep -v DEBUG | grep -v FileNotFound &
warp-cli --version

# sleep to wait for the daemon to start, default 2 seconds
sleep "${WARP_START_DELAY:-3}"

# if /var/lib/cloudflare-warp/reg.json not exists, register the warp client
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
    echo -n "Registering new Warp client: "
    warp-cli registration new

    # if a license key is provided, register the license
    if [ -n "$WARP_LICENSE_KEY" ]; then
        echo -n "Registering Warp license: "
        warp-cli set-license "$WARP_LICENSE_KEY"
    fi

    # set warp mode
    echo -n "Setting Warp DNS families mode off: "
    warp-cli dns families off

else
    echo "Warp client already registered, skip registration"
fi

# connect to the warp server
echo -n "Connecting Warp client: "
warp-cli connect

if [[ -n ${GOST_FORWARD} ]]; then
  gost -L ":1080" -F "${GOST_FORWARD}"
else
  gost -L ":1080"
fi
