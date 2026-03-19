#!/bin/bash

# Toggle live wallpaper (hyprpaper directory cycling)
# When ON: hyprpaper cycles through theme backgrounds every 30s
# When OFF: hyprpaper shows a single static wallpaper

CACHE_DIR="$HOME/.cache"
FLAG="$CACHE_DIR/live_wallpaper_enabled"

source "$HOME/.local/bin/hypr-helpers.sh"

# Derive backgrounds dir from current wallpaper path
CURRENT_PATH=$(cat "$CACHE_DIR/current_wallpaper_path" 2>/dev/null)
THEME_DIR=$(dirname "$(dirname "$CURRENT_PATH")" 2>/dev/null)
BG_DIR="$THEME_DIR/backgrounds"

if [[ ! -d "$BG_DIR" ]]; then
  notify-send "Live Wallpaper" "No backgrounds folder found for current theme"
  exit 1
fi

if [[ -f "$FLAG" ]]; then
  # Currently ON → turn OFF
  # Try to get current wallpaper from hyprpaper IPC
  ACTIVE=$(hyprctl hyprpaper listactive 2>/dev/null | head -1)
  # Parse: output format is "monitor = /path/to/wallpaper"
  RESOLVED=$(echo "$ACTIVE" | sed 's/.*= *//')

  # Validate resolved path exists and is inside the theme backgrounds dir
  if [[ ! -f "$RESOLVED" || "$RESOLVED" != "$BG_DIR"/* ]]; then
    # Fallback to cached path
    RESOLVED="$CURRENT_PATH"
  fi

  if [[ -f "$RESOLVED" ]]; then
    rm -f "$CACHE_DIR/current_wallpaper"
    cp "$RESOLVED" "$CACHE_DIR/current_wallpaper"
    echo "$RESOLVED" > "$CACHE_DIR/current_wallpaper_path"
  fi

  write_hyprpaper_conf "$HOME/.cache/current_wallpaper"
  rm -f "$FLAG"
  systemctl --user restart hyprpaper.service
  notify-send "Live Wallpaper" "Disabled" -i "$CACHE_DIR/current_wallpaper"
else
  # Currently OFF → turn ON
  write_hyprpaper_conf "$BG_DIR" 30
  touch "$FLAG"
  systemctl --user restart hyprpaper.service
  notify-send "Live Wallpaper" "Enabled (30s cycle)" -i "$CACHE_DIR/current_wallpaper"
fi
