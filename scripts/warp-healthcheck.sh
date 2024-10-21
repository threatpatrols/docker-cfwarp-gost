#!/bin/bash

if [ -n "${WARP_ORGANIZATION}" ] || [ -n "${CLOUDFLAREWARP_ORGANIZATION}" ]; then
  ping -c2 -q -n "${WARP_HEALTHCHECK_PING}" || exit 1
else
  curl -fsS "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || exit 1
fi

exit 0
