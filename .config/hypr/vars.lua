-- Programs (locals; reused inside bindings/ via require'ing this file if needed)
local M = {}
M.terminal = "ghostty"
M.fileManager = "nautilus"
M.menu = os.getenv("HOME") .. "/.config/rofi/launcher/launcher.sh"
M.powermenu = os.getenv("HOME") .. "/.config/rofi/powermenu/powermenu.sh"
M.browser = "zen-browser" --enable-features=UseOzonePlatform --ozone-platform=wayland"
M.notes = "obsidian"
M.colorPicker = "hyprpicker"
M.waydroid = "waydroid show-full-ui"

-- Env vars (XCOMPOSE file used by GTK input methods)
hl.env("XCOMPOSEFILE", os.getenv("HOME") .. "/.XCompose")

-- xwayland forced-zero-scaling and ecosystem flags
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
  ecosystem = {
    no_update_news = true,
  },
})

return M
