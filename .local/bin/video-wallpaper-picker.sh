#!/usr/bin/env bash

VIDEO_DIR="$HOME/.config/video-wallpapers"
THUMB_DIR="$HOME/.cache/video_wallpaper_thumbs"

mkdir -p "$VIDEO_DIR" "$THUMB_DIR"

# Generate image thumbnails for any new videos
for video in "$VIDEO_DIR"/*.{mp4,mkv,webm}; do
    [ -f "$video" ] || continue
    filename=$(basename "$video")
    thumb="$THUMB_DIR/${filename}.png"
    
    if [ ! -f "$thumb" ]; then
        ffmpeg -y -ss 00:00:02 -i "$video" -vframes 1 -vf "scale=320:-1" "$thumb" &>/dev/null
    fi
done

# Build Rofi list
ROFI_ENTRIES=""
for video in "$VIDEO_DIR"/*.{mp4,mkv,webm}; do
    [ -f "$video" ] || continue
    filename=$(basename "$video")
    thumb="$THUMB_DIR/${filename}.png"
    ROFI_ENTRIES="${ROFI_ENTRIES}${filename}\x00icon\x1f${thumb}\n"
done

if [ -z "$ROFI_ENTRIES" ]; then
    notify-send -u normal "Video Picker" "Put video files (.mp4) inside ~/Videos/Wallpapers/ first!"
    exit 0
fi

# Display in Rofi Grid
SELECTION=$(echo -e -n "$ROFI_ENTRIES" | rofi -dmenu -i -p "Video Wallpapers" -theme-str 'listview { lines: 3; columns: 3; } element-icon { size: 120px; }')

if [ -n "$SELECTION" ]; then
    bash ~/.local/bin/wallpaper-manager.sh set-video "$VIDEO_DIR/$SELECTION"
fi
