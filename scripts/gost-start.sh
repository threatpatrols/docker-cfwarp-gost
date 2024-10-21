#!/bin/bash

set -e

# GOST
# =============================================================================

if [ -n "${GOST_FORWARD}" ]; then
  gost -L ":1080" -F "${GOST_FORWARD}" &
else
  gost -L ":1080" &
fi
