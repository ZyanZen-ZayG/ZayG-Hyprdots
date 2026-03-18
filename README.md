# hyprsimple

Minimal Hyprland dotfiles for Arch Linux. Clean, functional, no bloat.

> NOTE: This dotfile have builtin [muslimtify](https://github.com/rizukirr/muslimtify). A prayer time notification daemon for Linux on waybar

![Screenshot 1](assets/image1.png)
![Screenshot 2](assets/image2.png)

## Features

- **17 themes** with one-key switching, all apps update at once (waybar, rofi, ghostty, hyprlock, dunst, btop)
- **Per-theme wallpapers** with picker and cycle support
- **Per-theme backgrounds** for app launcher and power menu
- **Hardware auto-detection** at install (NVIDIA, Vulkan, Intel iGPU, WiFi, battery)
- **Wayland-native** session via uwsm, no X11 dependencies
- **Modular Hyprland config** split into focused files
- **GTK/QT theming** with auto light/dark mode per theme
- **Smart battery** with auto brightness and power profiles
- **Screen recording** with mic, system audio, or silent modes
- **Screenshot** for monitor, window, region, or clipboard
- **Clipboard history** via cliphist + rofi
- **Nightlight toggle** for warm screen temperature
- **Audio output switching** with one key
- **Prayer times** on waybar via muslimtify
- **Firewall** (UFW) configured out of the box

## Install

```bash
git clone https://github.com/rizukirr/hyprsimple.git
cd hyprsimple
./install.sh
```

## Keybindings

Press **`SUPER + /`** for interactive viewer with fuzzy search.

### Applications

| Key | Action |
|-----|--------|
| `SUPER + T` | Open terminal (Ghostty) |
| `SUPER + B` | Open browser (Firefox) |
| `SUPER + A` | App launcher (Rofi) |
| `SUPER + F` | File manager (Nautilus) |
| `SUPER + O` | Notes (Obsidian) |
| `SUPER + S` | Android Studio |
| `SUPER + E` | Emoji picker |
| `SUPER + V` | Clipboard history |
| `SUPER + M` | Color picker |

### Window Management

| Key | Action |
|-----|--------|
| `SUPER + Q` | Kill active window |
| `SUPER + W` | Toggle floating |
| `SUPER + SHIFT + J` | Toggle split (dwindle) |
| `SUPER + H / J / K / L` | Move focus left / down / up / right |
| `SUPER + SHIFT + Arrow` | Resize window |
| `SUPER + LMB drag` | Move window |
| `SUPER + RMB drag` | Resize window |

### Workspaces

| Key | Action |
|-----|--------|
| `SUPER + [1-9, 0]` | Switch to workspace 1-10 |
| `SUPER + SHIFT + [1-9, 0]` | Move window to workspace 1-10 |
| `SUPER + SHIFT + S` | Move window to scratchpad |
| `SUPER + Scroll` | Cycle through workspaces |

### Theming & Wallpaper

| Key | Action |
|-----|--------|
| `SUPER + SHIFT + T` | Switch theme |
| `SUPER + SHIFT + W` | Pick wallpaper from current theme |
| `SUPER + ALT + W` | Cycle to next wallpaper |

### Screenshot

| Key | Action |
|-----|--------|
| `Print` | Screenshot current monitor |
| `SUPER + Print` | Screenshot active window |
| `SUPER + ALT + Print` | Screenshot selected region |
| `SUPER + CTRL + Print` | Screenshot region to clipboard |

### Screen Recording

| Key | Action |
|-----|--------|
| `SUPER + R` | Record region with mic audio |
| `SUPER + SHIFT + R` | Record fullscreen with mic audio |
| `SUPER + ALT + R` | Record region with system audio |
| `SUPER + SHIFT + ALT + R` | Record fullscreen with system audio |
| `SUPER + CTRL + R` | Record region without audio |
| `SUPER + CTRL + SHIFT + R` | Record fullscreen without audio |

### Media & Brightness

| Key | Action |
|-----|--------|
| `Volume Up / Down` | Adjust volume |
| `Mute` | Toggle mute |
| `Mic Mute` | Toggle microphone mute |
| `Play / Pause` | Media play/pause |
| `Next / Prev` | Media next/previous track |
| `Brightness Up / Down` | Adjust screen brightness |
| `Kbd Brightness Up / Down` | Adjust keyboard backlight |

### System

| Key | Action |
|-----|--------|
| `SUPER + ESC` | Power menu |
| `SUPER + SHIFT + L` | Lock screen |
| `SUPER + X` | Exit Hyprland |
| `CTRL + ESC` | Toggle waybar |
| `SUPER + N` | Toggle nightlight |
| `SUPER + D` | Dismiss notifications |
| `SUPER + SHIFT + I` | Toggle idle lock |
| `SUPER + F10` | Switch audio output |
| `SUPER + SHIFT + M` | Toggle monitor mirroring |
| `SUPER + CTRL + V` | Toggle virtual mirror |
| `SUPER + /` | Show all keybindings |

## License

MIT
