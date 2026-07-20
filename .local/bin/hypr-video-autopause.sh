#!/usr/bin/env bash

check_and_toggle_pause() {
    # Only act if mpvpaper is actually running
    if ! pgrep -x "mpvpaper" > /dev/null; then
        return
    fi

    # Get window count on the currently active workspace
    WINDOW_COUNT=$(hyprctl activeworkspace -j 2>/dev/null | jq '.windows // 0')

    if [ "$WINDOW_COUNT" -eq 0 ]; then
        # Empty workspace -> Resume video playback
        killall -CONT mpvpaper 2>/dev/null
    else
        # Windows are open -> Pause video playback to save 100% resources
        killall -STOP mpvpaper 2>/dev/null
    fi
}

# Run check immediately on start
check_and_toggle_pause

# Listen to Hyprland's real-time event socket
SOCAT_SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [ -S "$SOCAT_SOCKET" ]; then
    socat -u UNIX-CONNECT:"$SOCAT_SOCKET" - | while read -r line; do
        case "$line" in
            workspace*|focusedmon*|openwindow*|closewindow*|movewindow*)
                check_and_toggle_pause
                ;;
        esac
    done
fi
