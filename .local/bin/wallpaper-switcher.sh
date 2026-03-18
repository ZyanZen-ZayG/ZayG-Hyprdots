#!/bin/bash

# Switch wallpaper within the current theme
# Usage: wallpaper-switcher.sh [next|pick]
#   next - cycle to next wallpaper
#   pick - choose via rofi (default)

CACHE_DIR="$HOME/.cache"
CURRENT=$(readlink -f "$CACHE_DIR/current_wallpaper" 2>/dev/null)
THEME_DIR=$(dirname "$(dirname "$CURRENT")" 2>/dev/null)
BG_DIR="$THEME_DIR/backgrounds"

if [[ ! -d $BG_DIR ]]; then
  notify-send "Wallpaper" "No backgrounds folder found for current theme"
  exit 1
fi

# Get all wallpapers sorted
mapfile -t WALLPAPERS < <(find "$BG_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | sort)

if (( ${#WALLPAPERS[@]} == 0 )); then
  notify-send "Wallpaper" "No wallpapers found"
  exit 1
fi

if (( ${#WALLPAPERS[@]} == 1 )); then
  notify-send "Wallpaper" "Only one wallpaper in this theme"
  exit 0
fi

MODE="${1:-pick}"

if [[ $MODE == "next" ]]; then
  # Find current index and cycle to next
  NEXT=0
  for i in "${!WALLPAPERS[@]}"; do
    if [[ "${WALLPAPERS[$i]}" == "$CURRENT" ]]; then
      NEXT=$(( (i + 1) % ${#WALLPAPERS[@]} ))
      break
    fi
  done
  SELECTED="${WALLPAPERS[$NEXT]}"
elif [[ $MODE == "pick" ]]; then
  # Show rofi picker with filenames
  NAMES=()
  for wp in "${WALLPAPERS[@]}"; do
    NAMES+=("$(basename "$wp")")
  done
  CHOICE=$(printf '%s\n' "${NAMES[@]}" | rofi -dmenu -p "Wallpaper")
  [[ -z $CHOICE ]] && exit 0
  SELECTED="$BG_DIR/$CHOICE"
fi

if [[ ! -f $SELECTED ]]; then
  notify-send "Wallpaper" "File not found: $SELECTED"
  exit 1
fi

# Apply wallpaper
ln -sf "$SELECTED" "$CACHE_DIR/current_wallpaper"
ln -sf "$SELECTED" "$CACHE_DIR/current_lockscreen.png"

# Reload hyprpaper
if pgrep -x hyprpaper > /dev/null; then
  hyprctl hyprpaper unload all
  hyprctl hyprpaper preload "$CACHE_DIR/current_wallpaper"
  MONITOR=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].name')
  [[ -n "$MONITOR" ]] && hyprctl hyprpaper wallpaper "$MONITOR,$CACHE_DIR/current_wallpaper"
fi

notify-send "Wallpaper" "$(basename "$SELECTED")" -i "$SELECTED"
