#!/bin/bash

set -e

_get_status_delay=${1:-0}
if [ "${_get_status_delay}" -gt 0 ]; then
  printf " >> [warp-system-status] waiting %s seconds before running system status.\n" "${_get_status_delay}"
  sleep "${_get_status_delay}"
fi

printf "\nsystem-stats\n\n"

# show the ipv4 addresses
ip -4 addr | grep -v valid_
printf "\n"

# show the ipv6 addresses
ip -6 addr | grep -v valid_
printf "\n"

# show the Cloudflare route tables
ip route show table all | grep -v ':' | grep Cloudflare
printf "\n"

# show connection information from an independent source
curl --silent "https://ipinfo.io/json" || true
printf "\n\n"
