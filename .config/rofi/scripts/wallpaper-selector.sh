#!/bin/bash

# Rofi script mode for wallpaper selection within current theme

CACHE_DIR="$HOME/.cache"
CURRENT=$(cat "$CACHE_DIR/current_wallpaper_path" 2>/dev/null || true)
THEME_DIR=$(dirname "$(dirname "$CURRENT")" 2>/dev/null)
BG_DIR="$THEME_DIR/backgrounds"

if [[ -z "$1" ]]; then
  if [[ -d "$BG_DIR" ]]; then
    find "$BG_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) -exec basename {} \; | sort
  fi
else
  coproc ( "$HOME/.local/bin/wallpaper-switcher.sh" apply "$BG_DIR/$1" &>/dev/null )
fi
