#!/bin/bash

# Toggle virtual mirror using wl-mirror
# Auto-detects primary monitor

PRIMARY=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

if pgrep -x wl-mirror >/dev/null; then
  pkill wl-mirror
  notify-send "Virtual Mirror" "Stopped"
else
  wl-mirror "$PRIMARY" &
  notify-send "Virtual Mirror" "Mirroring $PRIMARY - Select this window in screen sharing apps"
fi
