#!/bin/bash

# Show all Hyprland keybindings in rofi with fuzzy search

hyprctl -j binds |
  jq -r '.[] | {modmask, key, description, dispatcher, arg} | "\(.modmask),\(.key),\(.description),\(.dispatcher),\(.arg)"' |
  sed -r \
    -e 's/null//g' \
    -e 's/^0,/,/' \
    -e 's/^1,/SHIFT + /' \
    -e 's/^4,/CTRL + /' \
    -e 's/^8,/ALT + /' \
    -e 's/^64,/SUPER + /' \
    -e 's/^65,/SUPER SHIFT + /' \
    -e 's/^68,/SUPER CTRL + /' \
    -e 's/^72,/SUPER ALT + /' \
    -e 's/^73,/SUPER SHIFT ALT + /' \
    -e 's/^76,/SUPER CTRL ALT + /' |
  awk -F, '{
    key = $1 $2
    gsub(/^[ \t]*\+?[ \t]*/, "", key)
    gsub(/[ \t]+$/, "", key)

    action = $3
    if (action == "") {
      for (i = 4; i <= NF; i++) action = action $i (i < NF ? "," : "")
      sub(/,$/, "", action)
      gsub(/(^|,)[[:space:]]*exec[[:space:]]*,?/, "", action)
      gsub(/^[ \t]+|[ \t]+$/, "", action)
    }

    if (action != "") printf "%-30s  %s\n", key, action
  }' |
  sort -u |
  rofi -dmenu -p "Keybindings" -i
