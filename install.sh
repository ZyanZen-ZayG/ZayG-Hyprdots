#!/bin/bash

set -eEo pipefail

DOTFILES_DIR="$(pwd)"

echo "======================================"
echo "  Hyprsimple Installation Script"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
  echo -e "${RED}This script is designed for Arch Linux only!${NC}"
  exit 1
fi

# Check for AUR helper
if command -v yay &>/dev/null; then
  AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
  AUR_HELPER="paru"
else
  echo -e "${YELLOW}No AUR helper found. Installing yay...${NC}"
  sudo pacman -Syu
  sudo pacman -S --needed git base-devel
  if [[ ! -d "/tmp/yay" ]]; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
  fi

  cd /tmp/yay
  makepkg -si --noconfirm
  cd "$DOTFILES_DIR"
  AUR_HELPER="yay"
fi

echo -e "${GREEN}Using AUR helper: $AUR_HELPER${NC}"
echo ""

# ======================================
#  Hardware Detection Functions
# ======================================

detect_and_install_nvidia() {
  echo -e "${YELLOW}Detecting NVIDIA GPU...${NC}"
  NVIDIA="$(lspci | grep -i 'nvidia' || true)"

  if [[ -z $NVIDIA ]]; then
    echo -e "${GREEN}No NVIDIA GPU detected, skipping${NC}"
    return 0
  fi

  echo -e "${GREEN}NVIDIA GPU detected: $NVIDIA${NC}"

  KERNEL_HEADERS="$(pacman -Qqs '^linux(-zen|-lts|-hardened)?$' | head -1)-headers"

  # Turing+ (GTX 16xx, RTX 20xx-50xx, RTX Pro, Quadro RTX, datacenter)
  if echo "$NVIDIA" | grep -qE "GTX 16[0-9]{2}|RTX [2-5][0-9]{3}|RTX PRO [0-9]{4}|Quadro RTX|RTX A[0-9]{4}|A[1-9][0-9]{2}|H[1-9][0-9]{2}|T4|L[0-9]+"; then
    NVIDIA_PACKAGES=("$KERNEL_HEADERS" nvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver)
    GPU_ARCH="turing_plus"
  # Maxwell/Pascal/Volta (GTX 9xx/10xx, Quadro P/M, MX, Titan X/Xp/V)
  elif echo "$NVIDIA" | grep -qE "GTX (9[0-9]{2}|10[0-9]{2})|GT 10[0-9]{2}|Quadro [PM][0-9]{3,4}|Quadro GV100|MX *[0-9]+|Titan (X|Xp|V)|Tesla V100"; then
    NVIDIA_PACKAGES=("$KERNEL_HEADERS" nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils)
    GPU_ARCH="maxwell_pascal_volta"
  else
    echo -e "${YELLOW}No compatible NVIDIA driver found. See: https://wiki.archlinux.org/title/NVIDIA${NC}"
    return 0
  fi

  echo -e "${YELLOW}Installing NVIDIA packages: ${NVIDIA_PACKAGES[*]}${NC}"
  sudo pacman -S --needed --noconfirm "${NVIDIA_PACKAGES[@]}" || true

  # Modprobe for early KMS
  sudo tee /etc/modprobe.d/nvidia.conf <<EOF >/dev/null
options nvidia_drm modeset=1
EOF

  # Mkinitcpio early loading
  sudo tee /etc/mkinitcpio.conf.d/nvidia.conf <<EOF >/dev/null
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
EOF

  # Append NVIDIA env vars to uwsm/env
  if [[ $GPU_ARCH = "turing_plus" ]]; then
    cat >>"$HOME/.config/uwsm/env" <<'EOF'

# NVIDIA (Turing+ with GSP firmware) - auto-detected by installer
export NVD_BACKEND=direct
export LIBVA_DRIVER_NAME=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
EOF
  elif [[ $GPU_ARCH = "maxwell_pascal_volta" ]]; then
    cat >>"$HOME/.config/uwsm/env" <<'EOF'

# NVIDIA (Maxwell/Pascal/Volta) - auto-detected by installer
export NVD_BACKEND=egl
export __GLX_VENDOR_LIBRARY_NAME=nvidia
EOF
  fi

  # Rebuild initramfs
  sudo mkinitcpio -P

  echo -e "${GREEN}NVIDIA setup complete (arch: $GPU_ARCH)${NC}"
}

detect_and_install_vulkan() {
  echo -e "${YELLOW}Detecting Vulkan-compatible GPUs...${NC}"

  declare -A VULKAN_DRIVERS=(
    [Intel]=vulkan-intel
    [AMD]=vulkan-radeon
    [Apple]=vulkan-asahi
  )

  VULKAN_PACKAGES=()
  for vendor in "${!VULKAN_DRIVERS[@]}"; do
    if lspci | grep -iE "(VGA|Display).*$vendor" > /dev/null 2>&1; then
      echo -e "${GREEN}Detected $vendor GPU, adding ${VULKAN_DRIVERS[$vendor]}${NC}"
      VULKAN_PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
    fi
  done

  if (( ${#VULKAN_PACKAGES[@]} > 0 )); then
    sudo pacman -S --needed --noconfirm "${VULKAN_PACKAGES[@]}" || true
    echo -e "${GREEN}Vulkan drivers installed${NC}"
  else
    echo -e "${YELLOW}No Vulkan-compatible GPU detected${NC}"
  fi
}

detect_and_setup_igpu() {
  echo -e "${YELLOW}Detecting Intel iGPU...${NC}"

  INTEL_IGPU_PCI=$(lspci -D | grep -i "VGA.*Intel" | head -1 | cut -d' ' -f1 || true)

  if [[ -z $INTEL_IGPU_PCI ]]; then
    echo -e "${YELLOW}No Intel iGPU detected, skipping udev rule${NC}"
    return 0
  fi

  echo -e "${GREEN}Intel iGPU detected at: $INTEL_IGPU_PCI${NC}"

  # Auto-create udev rule with detected PCI address
  sudo tee /etc/udev/rules.d/99-intel-igpu.rules <<EOF >/dev/null
KERNEL=="card[0-9]*", KERNELS=="$INTEL_IGPU_PCI", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", ATTR{dev}=="226:*", SYMLINK+="dri/intel-igpu"
EOF

  # Create env-hyprland with AQ_DRM_DEVICES (commented out, user opts in)
  cat >"$HOME/.config/uwsm/env-hyprland" <<'EOF'
# Uncomment to force Hyprland to use Intel iGPU only (hybrid GPU laptops)
# export AQ_DRM_DEVICES="/dev/dri/intel-igpu"
EOF

  echo -e "${GREEN}Intel iGPU udev rule created (PCI: $INTEL_IGPU_PCI)${NC}"
  echo -e "${YELLOW}To force iGPU: uncomment AQ_DRM_DEVICES in ~/.config/uwsm/env-hyprland${NC}"
}

# Install official packages
echo -e "${YELLOW}Installing official packages...${NC}"
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
  sudo pacman -Syu
  sudo pacman -S --needed $(grep -v '^#' "$DOTFILES_DIR/packages.txt" | grep -v '^$') || true
else
  echo -e "${RED}packages.txt not found!${NC}"
  exit 1
fi

# Install AUR packages
echo -e "${YELLOW}Installing AUR packages...${NC}"
if [ -f "$DOTFILES_DIR/aur-packages.txt" ]; then
  $AUR_HELPER -Syu || true
  $AUR_HELPER -S --needed $(grep -v '^#' "$DOTFILES_DIR/aur-packages.txt" | grep -v '^$') || true
else
  echo -e "${YELLOW}aur-packages.txt not found, skipping AUR packages${NC}"
fi

# ======================================
#  Hardware Auto-Detection
# ======================================
echo ""
echo -e "${YELLOW}Running hardware detection...${NC}"

detect_and_install_nvidia || true
detect_and_install_vulkan || true
detect_and_setup_igpu || true

echo -e "${GREEN}Hardware detection complete${NC}"
echo ""

# ======================================
#  Service & Hardware Setup
# ======================================

setup_bluetooth() {
  echo -e "${YELLOW}Setting up Bluetooth...${NC}"
  if command -v bluetoothctl &>/dev/null; then
    sudo systemctl enable bluetooth.service
    echo -e "${GREEN}Bluetooth enabled${NC}"
  fi
}

setup_network() {
  echo -e "${YELLOW}Setting up Network...${NC}"
  # Prevent boot hanging on network
  sudo systemctl disable systemd-networkd-wait-online.service 2>/dev/null
  # Symlink systemd-resolved
  sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  echo -e "${GREEN}Network configured${NC}"
}

setup_printer() {
  echo -e "${YELLOW}Setting up Printer support...${NC}"
  if pacman -Qi cups &>/dev/null; then
    sudo systemctl enable cups.service
    echo -e "${GREEN}Printer support enabled${NC}"
  fi
}

setup_firewall() {
  echo -e "${YELLOW}Setting up Firewall...${NC}"
  if command -v ufw &>/dev/null; then
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    # Allow LocalSend (LAN file sharing)
    sudo ufw allow 53317/tcp
    sudo ufw allow 53317/udp
    sudo ufw --force enable
    echo -e "${GREEN}Firewall enabled (deny incoming, allow outgoing, LocalSend allowed)${NC}"
  else
    echo -e "${YELLOW}ufw not installed, skipping firewall${NC}"
  fi
}

setup_battery() {
  echo -e "${YELLOW}Detecting battery...${NC}"
  if ls /sys/class/power_supply/BAT* &>/dev/null; then
    echo -e "${GREEN}Battery detected, setting balanced power profile${NC}"
    command -v powerprofilesctl &>/dev/null && powerprofilesctl set balanced
  else
    echo -e "${GREEN}No battery (desktop), setting performance profile${NC}"
    command -v powerprofilesctl &>/dev/null && powerprofilesctl set performance
  fi
}

echo -e "${YELLOW}Setting up services...${NC}"
setup_bluetooth || true
setup_network || true
setup_printer || true
setup_firewall || true
setup_battery || true
echo -e "${GREEN}Service setup complete${NC}"
echo ""

# Copy configuration files
echo ""
echo -e "${YELLOW}Copying configuration files...${NC}"

# Backup function (handles symlinks, dirs, and files)
backup_if_exists() {
  if [ -L "$1" ]; then
    # Remove symlinks (from dev-install.sh)
    rm -f "$1"
  elif [ -e "$1" ]; then
    echo -e "${YELLOW}Backing up existing $1 to $1.backup${NC}"
    rm -rf "$1.backup"
    mv "$1" "$1.backup"
  fi
}

# Copy .config directories and files
for item in "$DOTFILES_DIR/.config"/*; do
  basename_item=$(basename "$item")

  target="$HOME/.config/$basename_item"
  backup_if_exists "$target"

  if [ -d "$item" ]; then
    cp -r "$item" "$target"
    echo -e "${GREEN}Copied:${NC} $basename_item"
  elif [ -f "$item" ]; then
    cp "$item" "$target"
    echo -e "${GREEN}Copied:${NC} $basename_item"
  fi
done

# Copy scripts
echo ""
echo -e "${YELLOW}Installing scripts to ~/.local/bin...${NC}"
mkdir -p "$HOME/.local/bin"

for script in "$DOTFILES_DIR/.local/bin"/*.sh; do
  if [ -f "$script" ]; then
    target="$HOME/.local/bin/$(basename "$script")"
    backup_if_exists "$target"
    cp "$script" "$target"
    chmod +x "$target"
    echo -e "${GREEN}Copied:${NC} $(basename "$script")"
  fi
done

# Copy .local/share assets
if [ -d "$DOTFILES_DIR/.local/share" ]; then
  echo ""
  echo -e "${YELLOW}Copying .local/share assets...${NC}"
  mkdir -p "$HOME/.local/share"
  for item in "$DOTFILES_DIR/.local/share"/*; do
    if [ -e "$item" ]; then
      basename_item=$(basename "$item")
      target="$HOME/.local/share/$basename_item"
      backup_if_exists "$target"
      cp -r "$item" "$target"
      echo -e "${GREEN}Copied:${NC} .local/share/$basename_item"
    fi
  done
fi

# Enable and start services
echo ""
echo -e "${YELLOW}Enabling system services...${NC}"
systemctl --user enable --now pipewire pipewire-pulse wireplumber || true

# Enable battery monitor timer (if systemd files exist)
if [ -f "$HOME/.config/systemd/user/battery-monitor.timer" ]; then
  echo -e "${YELLOW}Enabling battery monitor timer...${NC}"
  systemctl --user daemon-reload
  systemctl --user enable --now battery-monitor.timer
  echo -e "${GREEN}Battery monitor enabled${NC}"
fi

# Initialize Theme Manager (Default: Catppuccin)
echo ""
echo -e "${YELLOW}Initializing Theme Manager (Default: Catppuccin)...${NC}"
THEME_DIR="$HOME/.config/hypr/themes/catppuccin"
CACHE_DIR="$HOME/.cache"
mkdir -p "$CACHE_DIR"
mkdir -p "$HOME/.config/btop/themes"
mkdir -p "$HOME/.config/rofi/shared/colors"

# Generate configs from templates
bash "$HOME/.local/bin/theme-apply-templates.sh" "$THEME_DIR" || true
GEN="$THEME_DIR/generated"

# Create symlinks to generated configs
ln -sf "$GEN/hyprland-colors.conf" "$HOME/.config/hypr/theme-active.conf"
ln -sf "$GEN/waybar-colors.css" "$HOME/.config/waybar/theme-active.css"
ln -sf "$GEN/rofi-colors.rasi" "$HOME/.config/rofi/shared/colors/theme-active.rasi"
cp "$GEN/hyprlock.conf" "$HOME/.config/hypr/theme-hyprlock.conf"
cp "$GEN/btop.theme" "$HOME/.config/btop/themes/current.theme"

# Apply ghostty colors
if [[ -f "$GEN/ghostty.conf" && -f "$HOME/.config/ghostty/config" ]]; then
  grep -vE '^(background|foreground|cursor-color|cursor-text|selection-background|selection-foreground|palette|theme) =' "$HOME/.config/ghostty/config" > "$HOME/.config/ghostty/config.tmp"
  cat "$GEN/ghostty.conf" >> "$HOME/.config/ghostty/config.tmp"
  mv "$HOME/.config/ghostty/config.tmp" "$HOME/.config/ghostty/config"
fi

# Wallpaper and lockscreen
if [[ -d "$THEME_DIR/backgrounds" ]]; then
  WALLPAPER=$(find "$THEME_DIR/backgrounds" -type f \( -name "*.png" -o -name "*.jpg" \) | head -1)
  [[ -n "$WALLPAPER" ]] && ln -sf "$WALLPAPER" "$CACHE_DIR/current_wallpaper"
elif [[ -f "$THEME_DIR/wallpaper.jpg" ]]; then
  ln -sf "$THEME_DIR/wallpaper.jpg" "$CACHE_DIR/current_wallpaper"
fi
if [[ -f "$THEME_DIR/lockscreen.png" ]]; then
  ln -sf "$THEME_DIR/lockscreen.png" "$CACHE_DIR/current_lockscreen.png"
elif [[ -n "$WALLPAPER" ]]; then
  ln -sf "$WALLPAPER" "$CACHE_DIR/current_lockscreen.png"
fi

# Launcher background (fallback to wallpaper)
LAUNCHER_BG=$(find "$THEME_DIR" -maxdepth 1 -type f -name "launcher.*" 2>/dev/null | head -1)
if [[ -n "$LAUNCHER_BG" ]]; then
  cp "$LAUNCHER_BG" "$CACHE_DIR/current_launcher_bg"
elif [[ -n "$WALLPAPER" ]]; then
  cp "$WALLPAPER" "$CACHE_DIR/current_launcher_bg"
fi

# Set initial GTK/Icon/Cursor settings
[[ -f "$THEME_DIR/gtk-theme" ]] && gsettings set org.gnome.desktop.interface gtk-theme "$(cat "$THEME_DIR/gtk-theme")"
[[ -f "$THEME_DIR/icon-theme" ]] && gsettings set org.gnome.desktop.interface icon-theme "$(cat "$THEME_DIR/icon-theme")"
[[ -f "$THEME_DIR/icons.theme" ]] && gsettings set org.gnome.desktop.interface icon-theme "$(cat "$THEME_DIR/icons.theme")"

# Set cursor theme in uwsm/env and gsettings
if [[ -f "$THEME_DIR/cursor-theme" ]]; then
  CURSOR="$(cat "$THEME_DIR/cursor-theme")"
  gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
  # Append cursor env to uwsm/env
  echo "export XCURSOR_THEME=$CURSOR" >> "$HOME/.config/uwsm/env"
fi
echo -e "${GREEN}Theme initialized${NC}"

mkdir -p ~/Videos
mkdir -p ~/Pictures

echo "source ~/.local/bin/bashrc.sh" >> ~/.bashrc

source ~/.bashrc || true
hyprctl reload || true
if pgrep -x waybar > /dev/null; then
  pkill waybar
  sleep 1
fi
nohup waybar > /dev/null 2>&1 &
disown
echo -e "${YELLOW}Starting waybar...${NC}"
sleep 3

systemctl --user enable --now hyprpaper.service || true
systemctl --user enable --now hyprpolkitagent.service || true
muslimtify daemon install || true
muslimtify daemon status || true

echo ""
echo -e "${GREEN}======================================"
echo "  Installation Complete!"
echo "======================================${NC}"
echo ""
echo "Configuration files have been copied to your home directory."
echo "To update configs, edit files in ~/.config/ directly."
echo ""
echo "Next steps:"
echo "1. Log out and log back in to Hyprland"
echo "2. Customize ~/.config/hypr/monitors.conf for your setup"
echo "3. Done"
echo ""

read -p "Logout to take effect? (y/n) " logout
if [ "$logout" == "y" ]; then
    echo "Logging out..."
    hyprctl dispatch exit
else
    echo "Exiting..."
    exit
fi
