#!/bin/bash

# Toggle virtual mirror using wl-mirror
# Creates a virtual Wayland output that screen sharing apps can capture
# The virtual output mirrors eDP-1 (laptop screen)

if pgrep -x wl-mirror >/dev/null; then
	# Stop virtual mirror
	pkill wl-mirror
	dunstify "Virtual Mirror" "Stopped" -u low -t 2000 -r 9996
else
	# Start virtual mirror of laptop screen
	wl-mirror eDP-1 &
	dunstify "Virtual Mirror" "Mirroring eDP-1 - Select this window in screen sharing apps" -u low -t 3000 -r 9996
fi
