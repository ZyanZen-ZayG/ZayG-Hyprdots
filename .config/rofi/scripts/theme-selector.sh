#!/bin/bash

# Rofi script mode for theme selection

THEMES_DIR="$HOME/.config/hypr/themes"

if [[ -z "$1" ]]; then
  ls "$THEMES_DIR" | grep -v templates
else
  "$HOME/.local/bin/theme-switcher.sh" "$1" &>/dev/null &
  disown
fi
