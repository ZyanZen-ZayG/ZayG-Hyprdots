for ws = 1, 10 do
  local key = tostring(ws % 10) -- 10 maps to "0" to match the .conf bindings
  hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = tostring(ws) }),       { description = "Workspace " .. ws })
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(ws) }), { description = "Move to Workspace " .. ws })
end

-- Scratchpad
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move to Scratchpad" })

-- Scroll through workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace" })
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Previous Workspace" })
