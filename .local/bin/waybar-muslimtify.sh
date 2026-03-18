#!/bin/bash
name=$(muslimtify next name 2>/dev/null)
time=$(muslimtify next time 2>/dev/null)
remaining=$(muslimtify next remaining 2>/dev/null)

if [[ -n "$name" && -n "$time" && -n "$remaining" ]]; then
    # Build beautiful tooltip from prayer times
    tooltip="🕌  <b>Prayer Times</b>\n━━━━━━━━━━━━━━━━━━━━━"

    while IFS='=' read -r prayer ptime; do
        [[ -z "$prayer" ]] && continue
        icon=""
        case "$prayer" in
            Fajr)    icon="🌅" ;;
            Dhuhr)   icon="☀️" ;;
            Asr)     icon="🌤️" ;;
            Maghrib) icon="🌇" ;;
            Isha)    icon="🌙" ;;
        esac

        if [[ "$prayer" == "$name" ]]; then
            tooltip+="\n${icon}  <b>${prayer}</b>\t<b>${ptime}</b>  ◀"
        else
            tooltip+="\n${icon}  ${prayer}\t${ptime}"
        fi
    done < <(muslimtify show --no-header 2>/dev/null)

    tooltip+="\n━━━━━━━━━━━━━━━━━━━━━"
    tooltip+="\n⏳  Next: <b>${name}</b> in <b>${remaining}</b>"

    printf '{"text": "󱠧  %s %s | %s", "tooltip": "%s"}\n' \
        "$name" "$time" "$remaining" "$tooltip"
else
    printf '{"text": "󱠧 --:--", "tooltip": "Prayer times unavailable"}\n'
fi
