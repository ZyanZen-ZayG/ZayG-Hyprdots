#!/bin/bash

# Configuration
THEMES_DIR="$HOME/.config/hypr/themes"
CACHE_DIR="$HOME/.cache"
mkdir -p "$CACHE_DIR"

# Select theme using Rofi
THEME=$(ls "$THEMES_DIR" | rofi -dmenu -p "Select Theme:")

# Exit if no theme selected
if [ -z "$THEME" ]; then
    exit 0
fi

THEME_PATH="$THEMES_DIR/$THEME"

# 1. Update Symlinks
# Hyprland colors
ln -sf "$THEME_PATH/hypr/colors.conf" "$HOME/.config/hypr/theme-active.conf"

# Waybar colors
ln -sf "$THEME_PATH/waybar/colors.css" "$HOME/.config/waybar/theme-active.css"

# Rofi colors
ln -sf "$THEME_PATH/rofi/colors.rasi" "$HOME/.config/rofi/shared/colors/theme-active.rasi"

# Wallpaper and Lockscreen
ln -sf "$THEME_PATH/wallpaper.jpg" "$CACHE_DIR/current_wallpaper"
ln -sf "$THEME_PATH/lockscreen.png" "$CACHE_DIR/current_lockscreen.png"

# 2. Update System Settings (GTK, Icons, Cursors)
if [ -f "$THEME_PATH/gtk-theme" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "$(cat "$THEME_PATH/gtk-theme")"
fi
if [ -f "$THEME_PATH/icon-theme" ]; then
    gsettings set org.gnome.desktop.interface icon-theme "$(cat "$THEME_PATH/icon-theme")"
fi
if [ -f "$THEME_PATH/cursor-theme" ]; then
    gsettings set org.gnome.desktop.interface cursor-theme "$(cat "$THEME_PATH/cursor-theme")"
fi

# 3. Reload Services
# Reload Hyprland
hyprctl reload

# Update Wallpaper via hyprpaper (if running)
if pgrep -x hyprpaper > /dev/null; then
    hyprctl hyprpaper unload all
    hyprctl hyprpaper preload "$CACHE_DIR/current_wallpaper"
    hyprctl hyprpaper wallpaper "monitor, $CACHE_DIR/current_wallpaper"
fi

# Reload Waybar
if pgrep -x waybar > /dev/null; then
    pkill waybar
    sleep 0.1
    waybar &
fi

# Reload Dunst
if pgrep -x dunst > /dev/null; then
    pkill dunst
    dunst &
fi

notify-send "Theme Manager" "Theme '$THEME' applied successfully!" -i "$THEME_PATH/wallpaper.jpg"
