#!/bin/bash

# Shared helpers for hyprpaper management

write_hyprpaper_conf() {
  local wp_path="$1"
  local timeout="$2"
  local conf="$HOME/.config/hypr/hyprpaper.conf"
  if [[ -n "$timeout" ]]; then
    cat > "$conf" <<EOF
wallpaper {
    monitor =
    path = $wp_path
    fit_mode = cover
    timeout = $timeout
}

splash = false
ipc = true
EOF
  else
    cat > "$conf" <<EOF
wallpaper {
    monitor =
    path = $wp_path
    fit_mode = cover
}

splash = false
ipc = true
EOF
  fi
}
