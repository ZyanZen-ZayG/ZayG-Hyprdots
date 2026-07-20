#!/usr/bin/env bash

STATIC_DIR="$HOME/.config/wallpapers"
THUMB_DIR="$HOME/.cache/static_wallpaper_thumbs"

mkdir -p "$STATIC_DIR" "$THUMB_DIR"

ROFI_ENTRIES=""
for img in "$STATIC_DIR"/*.{jpg,jpeg,png,webp,JPG,PNG}; do
    [ -f "$img" ] || continue
    filename=$(basename "$img")
    thumb="$THUMB_DIR/${filename}.png"
    
    # Generate static preview thumbnail
    if [ ! -f "$thumb" ]; then
        ffmpeg -y -i "$img" -vf "scale=320:-1" "$thumb" &>/dev/null
    fi
    
    ROFI_ENTRIES="${ROFI_ENTRIES}${filename}\x00icon\x1f${thumb}\n"
done

if [ -z "$ROFI_ENTRIES" ]; then
    notify-send -u normal "Static Picker" "Add wallpapers into ~/.config/wallpapers/ first!"
    exit 0
fi

SELECTION=$(echo -e -n "$ROFI_ENTRIES" | rofi -dmenu -i -p "Static Wallpapers" -theme-str 'listview { lines: 3; columns: 3; } element-icon { size: 120px; }')

if [ -n "$SELECTION" ]; then
    bash ~/.local/bin/wallpaper-manager.sh set-static "$STATIC_DIR/$SELECTION"
fi
