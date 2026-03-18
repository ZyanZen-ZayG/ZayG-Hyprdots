#!/bin/bash

THEMES_DIR="$HOME/.config/hypr/themes"
CACHE_DIR="$HOME/.cache"
mkdir -p "$CACHE_DIR"

# Select theme using Rofi (exclude templates directory)
THEME=$(ls "$THEMES_DIR" | grep -v templates | rofi -dmenu -p "Select Theme:")
[[ -z "$THEME" ]] && exit 0

THEME_PATH="$THEMES_DIR/$THEME"

# 1. Generate configs from templates (if colors.toml exists)
if [[ -f "$THEME_PATH/colors.toml" ]]; then
  "$HOME/.local/bin/theme-apply-templates.sh" "$THEME_PATH"
fi

GEN="$THEME_PATH/generated"

# 2. Update Hyprland colors
if [[ -f "$GEN/hyprland-colors.conf" ]]; then
  ln -sf "$GEN/hyprland-colors.conf" "$HOME/.config/hypr/theme-active.conf"
elif [[ -f "$THEME_PATH/hypr/colors.conf" ]]; then
  ln -sf "$THEME_PATH/hypr/colors.conf" "$HOME/.config/hypr/theme-active.conf"
fi

# 3. Update Waybar colors
if [[ -f "$GEN/waybar-colors.css" ]]; then
  ln -sf "$GEN/waybar-colors.css" "$HOME/.config/waybar/theme-active.css"
elif [[ -f "$THEME_PATH/waybar/colors.css" ]]; then
  ln -sf "$THEME_PATH/waybar/colors.css" "$HOME/.config/waybar/theme-active.css"
fi

# 4. Update Rofi colors
if [[ -f "$GEN/rofi-colors.rasi" ]]; then
  ln -sf "$GEN/rofi-colors.rasi" "$HOME/.config/rofi/shared/colors/theme-active.rasi"
elif [[ -f "$THEME_PATH/rofi/colors.rasi" ]]; then
  ln -sf "$THEME_PATH/rofi/colors.rasi" "$HOME/.config/rofi/shared/colors/theme-active.rasi"
fi

# 5. Update Ghostty colors (replace color lines, keep settings)
if [[ -f "$GEN/ghostty.conf" ]]; then
  GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
  if [[ -f "$GHOSTTY_CONFIG" ]]; then
    # Remove old color/palette/theme lines, keep non-color settings
    grep -vE '^(background|foreground|cursor-color|cursor-text|selection-background|selection-foreground|palette|theme) =' "$GHOSTTY_CONFIG" > "$GHOSTTY_CONFIG.tmp"
    # Append new colors
    cat "$GEN/ghostty.conf" >> "$GHOSTTY_CONFIG.tmp"
    mv "$GHOSTTY_CONFIG.tmp" "$GHOSTTY_CONFIG"
  fi
fi

# 6. Update Hyprlock theme colors
if [[ -f "$GEN/hyprlock.conf" ]]; then
  cp "$GEN/hyprlock.conf" "$HOME/.config/hypr/theme-hyprlock.conf"
fi

# 7. Update Dunst colors
if [[ -f "$GEN/dunst-colors" ]]; then
  DUNST_CONFIG="$HOME/.config/dunst/dunstrc"
  if [[ -f "$DUNST_CONFIG" ]]; then
    # Extract colors from generated file
    LOW_BG=$(sed -n '/urgency_low/,/urgency_normal/{/background/s/.*"\(.*\)".*/\1/p}' "$GEN/dunst-colors")
    LOW_FG=$(sed -n '/urgency_low/,/urgency_normal/{/foreground/s/.*"\(.*\)".*/\1/p}' "$GEN/dunst-colors")
    LOW_FC=$(sed -n '/urgency_low/,/urgency_normal/{/frame_color/s/.*"\(.*\)".*/\1/p}' "$GEN/dunst-colors")
    NORM_FC=$(sed -n '/urgency_normal/,/urgency_critical/{/frame_color/s/.*"\(.*\)".*/\1/p}' "$GEN/dunst-colors")
    CRIT_FC=$(sed -n '/urgency_critical/,${/frame_color/s/.*"\(.*\)".*/\1/p}' "$GEN/dunst-colors")

    # Replace in dunstrc (all urgency levels share bg/fg, differ by frame_color)
    sed -i "s/frame_color = \"#[a-fA-F0-9]*\"/frame_color = \"$LOW_FC\"/1" "$DUNST_CONFIG"
    sed -i "/\[urgency_normal\]/,/\[/{s/frame_color = \".*\"/frame_color = \"$NORM_FC\"/}" "$DUNST_CONFIG"
    sed -i "/\[urgency_critical\]/,/\[/{s/frame_color = \".*\"/frame_color = \"$CRIT_FC\"/}" "$DUNST_CONFIG"
    sed -i "s/background = \"#[a-fA-F0-9]*\"/background = \"$LOW_BG\"/g" "$DUNST_CONFIG"
    sed -i "s/foreground = \"#[a-fA-F0-9]*\"/foreground = \"$LOW_FG\"/g" "$DUNST_CONFIG"
  fi
fi

# 8. Update btop theme
if [[ -f "$GEN/btop.theme" ]]; then
  mkdir -p "$HOME/.config/btop/themes"
  cp "$GEN/btop.theme" "$HOME/.config/btop/themes/current.theme"
fi

# 9. Wallpaper
WALLPAPER=""
if [[ -d "$THEME_PATH/backgrounds" ]]; then
  WALLPAPER=$(find "$THEME_PATH/backgrounds" -type f \( -name "*.png" -o -name "*.jpg" \) | head -1)
elif [[ -f "$THEME_PATH/wallpaper.jpg" ]]; then
  WALLPAPER="$THEME_PATH/wallpaper.jpg"
fi
[[ -n "$WALLPAPER" ]] && ln -sf "$WALLPAPER" "$CACHE_DIR/current_wallpaper"

# Lockscreen
if [[ -f "$THEME_PATH/lockscreen.png" ]]; then
  ln -sf "$THEME_PATH/lockscreen.png" "$CACHE_DIR/current_lockscreen.png"
elif [[ -n "$WALLPAPER" ]]; then
  ln -sf "$WALLPAPER" "$CACHE_DIR/current_lockscreen.png"
fi

# 10. GTK/QT light/dark mode + Icon/Cursor settings
if [[ -f "$THEME_PATH/light.mode" ]]; then
  GTK_THEME_NAME="Adwaita"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
else
  GTK_THEME_NAME="Adwaita-dark"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
fi

# Override GTK theme if theme specifies one
[[ -f "$THEME_PATH/gtk-theme" ]] && GTK_THEME_NAME="$(cat "$THEME_PATH/gtk-theme")"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME"

# Update gtk-3.0 and gtk-4.0 settings.ini (some apps read these instead of gsettings)
for gtk_dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
  mkdir -p "$gtk_dir"
  if [[ -f "$gtk_dir/settings.ini" ]]; then
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME_NAME/" "$gtk_dir/settings.ini"
  fi
done

# Icon theme (icons.theme = omarchy style, icon-theme = hyprsimple style)
if [[ -f "$THEME_PATH/icons.theme" ]]; then
  gsettings set org.gnome.desktop.interface icon-theme "$(cat "$THEME_PATH/icons.theme")"
elif [[ -f "$THEME_PATH/icon-theme" ]]; then
  gsettings set org.gnome.desktop.interface icon-theme "$(cat "$THEME_PATH/icon-theme")"
fi

if [[ -f "$THEME_PATH/cursor-theme" ]]; then
  CURSOR="$(cat "$THEME_PATH/cursor-theme")"
  gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
  hyprctl setcursor "$CURSOR" 24
fi

# 11. Reload Services
hyprctl reload

if pgrep -x hyprpaper > /dev/null; then
  hyprctl hyprpaper unload all
  hyprctl hyprpaper preload "$CACHE_DIR/current_wallpaper"
  MONITOR=$(hyprctl monitors -j 2>/dev/null | grep -o '"name": "[^"]*"' | head -1 | cut -d'"' -f4)
  [[ -n "$MONITOR" ]] && hyprctl hyprpaper wallpaper "$MONITOR,$CACHE_DIR/current_wallpaper"
fi

if pgrep -x waybar > /dev/null; then
  pkill waybar; sleep 0.1; uwsm app -- waybar &
fi

if pgrep -x dunst > /dev/null; then
  pkill dunst; uwsm app -- dunst &
fi

notify-send "Theme Manager" "Theme '$THEME' applied!" -i "$CACHE_DIR/current_wallpaper"
