#!/bin/bash
# Toggle CPU between performance and powersave modes
# Run with sudo

current=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

if [ "$current" = "performance" ]; then
    echo "=== Switching to Powersave Mode ==="
    cpupower frequency-set -g powersave
    echo
    echo "CPU restored to powersave mode (battery saving)"
    echo "Note: CPU will now throttle down when idle"
    notify-send -u normal "CPU Mode: Powersave" "Switched to powersave mode"
else
    echo "=== Switching to Performance Mode ==="
    cpupower frequency-set -g performance
    echo
    echo "CPU set to performance mode!"
    notify-send -u normal "CPU Mode: Performance" "Switched to performance mode"
fi

echo
echo "=== Current CPU State ==="
cpupower frequency-info | grep -E "governor|MHz"
