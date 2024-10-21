#!/bin/bash

# exit when any command fails
set -e

source /scripts/config-vars.sh

if [ -n "${DEBUG}" ]; then
  set -x
fi

/scripts/warp-system-status.sh "${WARP_SYSTEM_STATUS_DELAY}" &  # display system status after a delay
/scripts/warp-connect.sh
/scripts/gost-start.sh

while true; do

  if [ $(pgrep --exact --count warp-svc) -lt 1 ]; then
    echo " >> [entrypoint] warp-svc process not running, exiting now."
    exit 1
  fi

  if [ $(pgrep --exact --count gost) -lt 1 ]; then
    echo " >> [entrypoint] gost process not running, exiting now."
    exit 1
  fi

  sleep 10
done
