local home = os.getenv("HOME")

-- Volume controls
hl.bind("SUPER + Up",    hl.dsp.exec_cmd("sh -c 'wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ && " .. home .. "/.local/bin/volume-notify.sh'"), { description = "Volume Up" })
hl.bind("SUPER + Down",  hl.dsp.exec_cmd("sh -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && " .. home .. "/.local/bin/volume-notify.sh'"), { description = "Volume Down" })
hl.bind("SUPER + M",       hl.dsp.exec_cmd("sh -c 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && " .. home .. "/.local/bin/volume-notify.sh muted'"), { description = "Toggle Mute" })
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { description = "Toggle Mic Mute" })

-- Media player controls
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play/Pause" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play/Pause" })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { description = "Next Track" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { description = "Previous Track" })

-- Screen brightness
-- ZZ: SUPER + Arrow keys for brightness/volume
hl.bind("SUPER + Right", hl.dsp.exec_cmd("sh -c 'brightnessctl s +5% && " .. home .. "/.local/bin/brightness-notify.sh'"), { description = "Brightness Up" })
hl.bind("SUPER + Left",  hl.dsp.exec_cmd("sh -c 'brightnessctl s 5%- && " .. home .. "/.local/bin/brightness-notify.sh'"), { description = "Brightness Down" })

-- Keyboard backlight
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd(home .. "/.local/bin/keyboard-brightness.sh up"),   { description = "Keyboard Backlight Up" })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(home .. "/.local/bin/keyboard-brightness.sh down"), { description = "Keyboard Backlight Down" })
