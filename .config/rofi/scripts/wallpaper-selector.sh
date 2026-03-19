#!/bin/bash

# Rofi script mode for wallpaper selection within current theme

CACHE_DIR="$HOME/.cache"
THEMES_DIR="$HOME/.config/hypr/themes"

# Determine backgrounds directory: from cache or current theme
BG_DIR=""
if [[ -f "$CACHE_DIR/current_wallpaper_path" ]]; then
  CURRENT=$(cat "$CACHE_DIR/current_wallpaper_path")
  THEME_DIR=$(dirname "$(dirname "$CURRENT")" 2>/dev/null)
  [[ -d "$THEME_DIR/backgrounds" ]] && BG_DIR="$THEME_DIR/backgrounds"
fi

# Fallback: find first theme with backgrounds
if [[ -z "$BG_DIR" ]]; then
  for theme_dir in "$THEMES_DIR"/*/; do
    if [[ -d "$theme_dir/backgrounds" ]]; then
      BG_DIR="$theme_dir/backgrounds"
      break
    fi
  done
fi

if [[ -z "$1" ]]; then
  if [[ -d "$BG_DIR" ]]; then
    find "$BG_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) -exec basename {} \; | sort
  fi
else
  "$HOME/.local/bin/wallpaper-switcher.sh" apply "$BG_DIR/$1" &>/dev/null &
  disown
fi
