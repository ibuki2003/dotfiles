#!/usr/bin/env bash

set -euo pipefail

if
  CONTENT=$(grimshot save area - \
    | zbarimg - -1 --raw 2>/dev/null \
    | tee >(wl-copy -t text/plain))
then
  notify-send "QR Code" "Copied content to clipboard:\n$CONTENT"
else
  notify-send "QR Code" "Failed to read QR code"
fi

