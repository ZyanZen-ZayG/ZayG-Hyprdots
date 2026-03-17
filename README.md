# hyprsimple

Minimal Hyprland dotfiles for Arch Linux. Clean, functional, no bloat.

## Preview

![Screenshot 1](assets/image1.png)
![Screenshot 2](assets/image2.png)

## Stack

| Component | Choice |
|-----------|--------|
| WM | Hyprland |
| Bar | Waybar |
| Launcher | Rofi |
| Terminal | Ghostty |
| Shell | Bash + Starship |
| Notifications | Dunst |
| Editor | Neovim |
| Browser | Firefox |

## Features

- **17 themes** with one-command switching (`SUPER + SHIFT + T`)
- **Hardware auto-detection** — NVIDIA, Vulkan, Intel iGPU configured at install
- **Modular configs** — Hyprland split into focused files
- **Wayland-native** — no X11 dependencies
- **Smart battery** — auto brightness + power profiles
- **Firewall** — UFW configured out of the box

## Install

```bash
git clone https://github.com/rizukirr/hyprsimple.git
cd hyprsimple
./install.sh
```

Then log out and select Hyprland.

## Keybindings

Press **`SUPER + /`** for interactive viewer.

| Key | Action |
|-----|--------|
| `SUPER + T` | Terminal |
| `SUPER + B` | Browser |
| `SUPER + A` | App Launcher |
| `SUPER + F` | File Manager |
| `SUPER + Q` | Kill window |
| `SUPER + H/J/K/L` | Move focus (Vim) |
| `SUPER + [1-9]` | Switch workspace |
| `SUPER + SHIFT + T` | Switch theme |
| `SUPER + V` | Clipboard history |
| `SUPER + R` | Screen record |
| `Print` | Screenshot |

## Themes

17 built-in themes. Switch with `SUPER + SHIFT + T` or run `theme-switcher.sh`.

catppuccin, catppuccin-latte, rosepine, tokyo-night, nord, gruvbox, everforest, kanagawa, hackerman, ethereal, matte-black, miasma, osaka-jade, ristretto, vantablack, flexoki-light, white

## License

MIT
