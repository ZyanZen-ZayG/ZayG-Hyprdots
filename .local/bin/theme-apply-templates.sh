#!/bin/bash

# Usage: theme-apply-templates.sh <theme-dir>
# Reads colors.toml from theme dir, processes templates, outputs generated configs

THEME_DIR="$1"
TEMPLATES_DIR="$HOME/.config/hypr/themes/templates"
COLORS_FILE="$THEME_DIR/colors.toml"

if [[ ! -f $COLORS_FILE ]]; then
  echo "No colors.toml found in $THEME_DIR, skipping template generation"
  exit 0
fi

# Convert hex color to decimal RGB (e.g., "#1e1e2e" -> "30,30,46")
hex_to_rgb() {
  local hex="${1#\#}"
  printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Build sed script from colors.toml
sed_script=$(mktemp)

while IFS='=' read -r key value; do
  key="${key//[\"\' ]/}"
  [[ $key && $key != \#* ]] || continue
  value="${value#*[\"\']}"
  value="${value%%[\"\']*}"

  printf 's|{{ %s }}|%s|g\n' "$key" "$value"
  printf 's|{{ %s_strip }}|%s|g\n' "$key" "${value#\#}"
  if [[ $value =~ ^# ]]; then
    rgb=$(hex_to_rgb "$value")
    echo "s|{{ ${key}_rgb }}|${rgb}|g"
  fi
done <"$COLORS_FILE" >"$sed_script"

# Generate configs from templates
mkdir -p "$THEME_DIR/generated"

for tpl in "$TEMPLATES_DIR"/*.tpl; do
  filename=$(basename "$tpl" .tpl)
  sed -f "$sed_script" "$tpl" >"$THEME_DIR/generated/$filename"
done

rm "$sed_script"
echo "Templates generated in $THEME_DIR/generated/"
