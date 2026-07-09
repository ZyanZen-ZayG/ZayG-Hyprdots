#!/bin/bash

# Next prayer: `muslimtify show --next --headless` emits two key=value lines,
# e.g.  asr=15:22  /  remaining=03:08  (prayer name is lowercase)
name=""
time=""
remaining=""
while IFS='=' read -r key val; do
    [[ -z "$key" ]] && continue
    if [[ "$key" == "remaining" ]]; then
        remaining="$val"
    else
        name="$key"
        time="$val"
    fi
done < <(muslimtify show --next --headless 2>/dev/null)

if [[ -n "$name" && -n "$time" && -n "$remaining" ]]; then
    display_name="${name^}"   # Capitalize first letter for display

    # Build beautiful tooltip from prayer times
    tooltip="󰧧  <b>Prayer Times</b>\n━━━━━━━━━━━━━━━━━━━━━"

    while IFS='=' read -r prayer ptime; do
        [[ -z "$prayer" ]] && continue
        icon=""
        case "$prayer" in
            fajr)    icon="󰖜" ;;
            dhuhr)   icon="󰖙" ;;
            asr)     icon="󰖚" ;;
            maghrib) icon="󰖛" ;;
            isha)    icon="󰖔" ;;
        esac

        pretty="${prayer^}"
        padded=$(printf '%-9s' "$pretty")   # pad name so times align in a column

        if [[ "$prayer" == "$name" ]]; then
            tooltip+="\n${icon}  <b>${padded}${ptime}</b>  󰁍"
        else
            tooltip+="\n${icon}  ${padded}${ptime}"
        fi
    done < <(muslimtify show --headless 2>/dev/null)

    tooltip+="\n━━━━━━━━━━━━━━━━━━━━━"
    tooltip+="\n󰔟  Next: <b>${display_name}</b> in <b>${remaining}</b>"

    printf '{"text": "󱠧  %s %s | 󰔟 %s", "tooltip": "%s"}\n' \
        "$display_name" "$time" "$remaining" "$tooltip"
else
    printf '{"text": "󱠧 --:--", "tooltip": "Prayer times unavailable"}\n'
fi
