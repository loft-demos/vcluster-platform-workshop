#!/usr/bin/env bash
set -euo pipefail

if [ -f /tmp/loft-portforward.log ]; then
  tail -n +1 -f /tmp/loft-portforward.log
else
  echo "Waiting for /tmp/loft-portforward.log..."
  while [ ! -f /tmp/loft-portforward.log ]; do sleep 1; done
  tail -n +1 -f /tmp/loft-portforward.log
fi
