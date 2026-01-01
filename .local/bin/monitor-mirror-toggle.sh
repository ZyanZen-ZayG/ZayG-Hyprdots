#!/bin/bash

# Toggle between extended and mirror mode for HDMI monitor
# When mirroring: HDMI-A-1 mirrors eDP-1 (laptop screen)
# When extended: Both monitors work independently

# Check if HDMI is currently mirroring eDP-1
if hyprctl monitors | grep -A 5 "HDMI-A-1" | grep -q "mirror of eDP-1"; then
	# Switch to extended mode
	hyprctl keyword monitor "HDMI-A-1,preferred,auto,1"
	dunstify "Monitor Mode" "Extended display enabled" -u low -t 2000 -r 9997
else
	# Switch to mirror mode
	hyprctl keyword monitor "HDMI-A-1,preferred,auto,1,mirror,eDP-1"
	dunstify "Monitor Mode" "Mirror mode enabled" -u low -t 2000 -r 9997
fi
