#!/bin/bash

# This script is used to connect to a WiFi network

SSID=$1

if [ -z "$SSID" ]; then
  iwctl station wlan0 get-networks
  exit
fi

iwctl station wlan0 connect "$SSID"
