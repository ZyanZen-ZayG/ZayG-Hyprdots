#!/bin/bash

# Usage: wifi-powersave.sh <on|off>

for iface in /sys/class/net/*/wireless; do
  iface="$(basename "$(dirname "$iface")")"
  sudo iw dev "$iface" set power_save "$1" 2>/dev/null
done

notify-send "WiFi" "Power save: $1"
