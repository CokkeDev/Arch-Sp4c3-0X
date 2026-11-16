#!/usr/bin/env bash
# Objetivo actual. Mismo archivo que usa el widget "IP víctima" de KDE,
# así settarget sirve en las dos sesiones.
f="$HOME/.config/archhacker/target_ip"
ip=$( [ -s "$f" ] && tr -d '[:space:]' < "$f" )

icon=$(printf '\xf3\xb0\x93\xbe')
if [ -n "$ip" ]; then
    printf '%%{F#ff4d5e}%s %s%%{F-} %%{F#8a93a6}target%%{F-}\n' "$icon" "$ip"
else
    printf '%%{F#8a93a6}%s sin objetivo%%{F-}\n' "$icon"
fi
