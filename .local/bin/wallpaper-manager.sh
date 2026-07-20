#!/usr/bin/env bash

STATE_FILE="$HOME/.config/wallpaper_state"
VIDEO_DIR="$HOME/.config/video-wallpapers"
STATIC_DIR="$HOME/.config/wallpapers"

mkdir -p "$VIDEO_DIR" "$STATIC_DIR" "$HOME/.cache"

# Default variables
MODE="static"
STATIC_PATH=""
VIDEO_PATH=""

# Load existing state if available
if [ -f "$STATE_FILE" ]; then
    source "$STATE_FILE"
fi

# Clean atomic state writer (prevents path/sed corruption)
save_state() {
    cat << STATE_EOF > "$STATE_FILE"
MODE="$MODE"
STATIC_PATH="$STATIC_PATH"
VIDEO_PATH="$VIDEO_PATH"
STATE_EOF
}

start_video() {
    # Stop 30-sec loops and static daemons
    pkill -f "wallpaper-switcher.sh" 2>/dev/null
    pkill -f "live-wallpaper-toggle.sh" 2>/dev/null
    killall -9 awww-daemon swww-daemon hyprpaper mpvpaper hypr-video-autopause.sh 2>/dev/null

    if [ -n "$VIDEO_PATH" ] && [ -f "$VIDEO_PATH" ]; then
        mpvpaper -o "no-audio --loop-playlist" '*' "$VIDEO_PATH" &
        ~/.local/bin/hypr-video-autopause.sh &
        notify-send -u low "Wallpaper System" "Video Mode Active:\n$(basename "$VIDEO_PATH")"
    else
        notify-send -u critical "Wallpaper Error" "No video selected! Press Super+Alt+V"
    fi
}

start_static() {
    # Stop video player
    killall -9 mpvpaper hypr-video-autopause.sh 2>/dev/null

    # Keep or launch awww-daemon safely
    if ! pgrep -x "awww-daemon" > /dev/null && ! pgrep -x "swww-daemon" > /dev/null; then
        awww-daemon &
        sleep 0.8
    fi

    if [ -n "$STATIC_PATH" ] && [ -f "$STATIC_PATH" ]; then
        # Set wallpaper via awww or swww
        if command -v awww &>/dev/null; then
            awww img "$STATIC_PATH" --transition-type wipe --transition-angle 30 --transition-step 90
        elif command -v swww &>/dev/null; then
            swww img "$STATIC_PATH" --transition-type wipe --transition-angle 30 --transition-step 90
        fi

        # Prevent Archcraft theme scripts from reverting to theme wallpaper
        cp -f "$STATIC_PATH" "$HOME/.cache/current_wallpaper" 2>/dev/null

        notify-send -u low "Wallpaper System" "Static Mode Active:\n$(basename "$STATIC_PATH")"
    else
        notify-send -u critical "Wallpaper Error" "No image selected! Press Super+Alt+S"
    fi
}

case "$1" in
    "init")
        if [ "$MODE" == "video" ]; then
            start_video
        else
            start_static
        fi
        ;;
    "toggle")
        if [ "$MODE" == "video" ]; then
            MODE="static"
            save_state
            start_static
        else
            MODE="video"
            save_state
            start_video
        fi
        ;;
    "set-video")
        if [ -n "$2" ] && [ -f "$2" ]; then
            VIDEO_PATH="$2"
            MODE="video"
            save_state
            start_video
        fi
        ;;
    "set-static")
        if [ -n "$2" ] && [ -f "$2" ]; then
            STATIC_PATH="$2"
            MODE="static"
            save_state
            start_static
        fi
        ;;
esac
