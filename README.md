# hyprsimple

Minimal Hyprland dotfiles for Arch Linux. Clean, functional, no bloat.

> [!IMPORTANT]
> **Requires Hyprland ≥ 0.55.0.** The config has been migrated from `.conf` to Lua (`hyprland.lua` + per-concern modules under `~/.config/hypr/`) to match Hyprland's new Lua-based configuration. Older Hyprland releases that do not ship the `hl` global will fail to load this config. Tested against Hyprland `0.55.0` (commit `af923e3`); if your `hyprctl version` is lower, upgrade Hyprland first or stay on an earlier tag of this repo.

> NOTE: This dotfile have builtin [muslimtify](https://github.com/rizukirr/muslimtify). A prayer time notification daemon for Linux on waybar.
>
> Run `muslimtify-remove` to uninstall it (package, daemon, waybar module, and CSS). Run `muslimtify-add` to re-enable it later. Both commands are idempotent and back up your waybar config to `.bak` before editing.

![Home Screen](assets/image1.png)

| Power Menu | Terminal|
|----------------------------------|--------------------------------|
| ![Power Menu](assets/image5.png) | ![Terminal](assets/image2.png) |

| Menu Launcher | Theme Switcher |
|-------------------------------------|-------------------------------------|
| ![Menu Launcher](assets/image3.png) | ![Theme Switcher](assets/image4.png) |

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

> [!WARNING]
> These dotfiles have only been tested on a fresh Arch Linux install where Hyprland was selected
> as the desktop during installation. Coming from another desktop environment or compositor
> (KDE, GNOME, etc.) is untested and may require manual cleanup.

If you run into a problem installing hyprsimple, please [open an issue](https://github.com/rizukirr/hyprsimple/issues) — thank you!

## Network

To see the available network interfaces, run `wifi`. To connect to a network, run `wifi <network name>` for example `wifi "MY NETWORK"`

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

## FAQ

### Boot hangs with `[FAILED] Failed to start Load Kernel Modules`, then freezes after login (NVIDIA hybrid laptops)

On NVIDIA Optimus laptops (Intel/AMD iGPU + NVIDIA dGPU) running a bleeding-edge
kernel — e.g. `linux-cachyos` 7.0.x with `nvidia-open` — the NVIDIA driver's GSP
firmware init can intermittently deadlock while the **initramfs** brings the dGPU
up at boot. Symptoms:

- `[FAILED] Failed to start Load Kernel Modules` early in boot, followed by a long
  wait (a stuck `udev` / "Rule-based Manager for Device Events and Files" job).
- The login screen eventually appears, but the session freezes right after logging in.

The hang is in the kernel module load **inside the initramfs**, so userspace config
(`/etc/modprobe.d`, `/etc/modules-load.d`) does **not** help unless the initramfs is
rebuilt. The minimal fix is a kernel command-line parameter that stops the dGPU from
loading at boot — it still loads on demand via `prime-run`, and the iGPU keeps driving
the desktop (so Hyprland/Wayland is unaffected).

**Fix (systemd-boot):** add `modprobe.blacklist` for the NVIDIA modules to the affected
kernel entry's `options` line in `/boot/loader/entries/<your-entry>.conf`:

```
options ... rw ... modprobe.blacklist=nvidia_drm,nvidia_modeset,nvidia_uvm,nvidia
```

Reboot into that entry. Verify:

```bash
lsmod | grep nvidia                          # empty at boot = good
prime-run glxinfo | grep "OpenGL renderer"   # still loads the dGPU on demand
```

> [!NOTE]
> Scope the change to the bleeding-edge entry only; leave your LTS entry untouched as a
> fallback. The community `nomodeset` workaround also boots, but disables **all** KMS
> (including the iGPU) and breaks Wayland — `modprobe.blacklist=nvidia*` avoids that by
> blacklisting only NVIDIA. For GRUB, add the same `modprobe.blacklist=...` to
> `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`, then run `grub-mkconfig -o /boot/grub/grub.cfg`.
>
> On CachyOS the systemd-boot entries are **generated by `sdboot-manage`**, so a direct edit
> to `/boot/loader/entries/*.conf` is overwritten on the next `sudo sdboot-manage gen` (e.g. a
> kernel update). To make it persist, add the parameter to `LINUX_OPTIONS` in
> `/etc/sdboot-manage.conf` and run `sudo sdboot-manage gen` — note this applies to **all**
> entries, so the dGPU loads on demand on the LTS kernel too (harmless, just no longer at boot).
>
> This is an upstream driver/kernel bug; once a fixed `linux-cachyos` / `nvidia-open`
> update lands you can remove the parameter.
>
> Reference: [CachyOS forum — "Failed to start Load Kernel Modules and Rule-based Manager"](https://discuss.cachyos.org/t/failed-to-start-load-kernel-modules-and-rule-based-manager/27583)

### Stuck on a blank screen with a spinning loading circle after picking the OS in systemd-boot

This is the Plymouth boot splash hanging — it shows the spinner on a blank screen and never
hands off to the login manager. Removing Plymouth fixes it (boot then shows plain text messages
instead of the splash). On CachyOS the systemd-boot entries are generated by `sdboot-manage`,
so the `splash`/`quiet` flags live in `/etc/sdboot-manage.conf` and `/etc/kernel/cmdline` rather
than the entry files directly.

1. Uninstall Plymouth and its CachyOS theme/animation packages:
   ```bash
   sudo pacman -Rns plymouth cachyos-plymouth-theme cachyos-plymouth-bootanimation
   ```
2. Remove `splash` and `quiet` from `/etc/sdboot-manage.conf` (the `LINUX_OPTIONS=` line), then
   regenerate the boot entries:
   ```bash
   sudo sdboot-manage gen
   ```
3. Remove `plymouth` from the `HOOKS=(...)` line in `/etc/mkinitcpio.conf`, then rebuild the
   initramfs:
   ```bash
   sudo mkinitcpio -P
   ```
4. Remove `splash` and `quiet` from `/etc/kernel/cmdline` as well.

Verify after reboot — boot should show plain systemd text with no spinner:

```bash
pacman -Q plymouth                # 'not found'
grep HOOKS /etc/mkinitcpio.conf   # no 'plymouth'
```

> [!NOTE]
> Reference: [CachyOS forum — "Disable or remove Plymouth boot splash"](https://discuss.cachyos.org/t/tutorial-disable-or-remove-plymouth-boot-splash/10922)

## License

MIT
