#!/bin/bash
name=$(muslimtify next name 2>/dev/null)
time=$(muslimtify next time 2>/dev/null)
remaining=$(muslimtify next remaining 2>/dev/null)

if [[ -n "$name" && -n "$time" && -n "$remaining" ]]; then
    tooltip=$(NO_COLOR=1 muslimtify 2>/dev/null | sed 's/"/\\"/g')
    tooltip=$(echo "$tooltip" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')
    printf '{"text": "󱠧  %s %s | %s", "tooltip": "%s"}\n' \
        "$name" "$time" "$remaining" "$tooltip"
else
    printf '{"text": "󱠧 --:--", "tooltip": "Prayer times unavailable"}\n'
fi
