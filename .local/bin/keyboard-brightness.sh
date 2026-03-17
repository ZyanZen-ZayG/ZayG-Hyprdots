#!/bin/bash

# Usage: keyboard-brightness.sh <up|down|cycle>
# Controls keyboard backlight via brightnessctl

DEVICE="kbd_backlight"
STEP="33%"

case "$1" in
  up)
    brightnessctl -d "$DEVICE" set "${STEP}+" -q
    ;;
  down)
    brightnessctl -d "$DEVICE" set "${STEP}-" -q
    ;;
  cycle)
    CURRENT=$(brightnessctl -d "$DEVICE" get 2>/dev/null || echo 0)
    MAX=$(brightnessctl -d "$DEVICE" max 2>/dev/null || echo 0)
    if [[ $CURRENT -ge $MAX ]]; then
      brightnessctl -d "$DEVICE" set 0 -q
    else
      brightnessctl -d "$DEVICE" set "${STEP}+" -q
    fi
    ;;
esac
