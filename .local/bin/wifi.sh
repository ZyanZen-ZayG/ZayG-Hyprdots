#!/bin/bash

# Auto-detect WiFi interface
IFACE=$(ls /sys/class/net/*/wireless 2>/dev/null | head -1 | cut -d'/' -f5)

if [[ -z $IFACE ]]; then
  echo "No WiFi interface found"
  exit 1
fi

SSID=$1

if [[ -z $SSID ]]; then
  iwctl station "$IFACE" get-networks
  exit
fi

iwctl station "$IFACE" connect "$SSID"
