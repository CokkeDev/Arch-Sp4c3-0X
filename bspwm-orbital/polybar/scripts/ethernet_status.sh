#!/usr/bin/env bash
# IP de la interfaz LAN (ignora VPN, docker y bridges)
ip=$(ip -4 -o addr show scope global 2>/dev/null \
     | awk '$2 !~ /^(tun|wg|docker|br-|virbr|veth)/ {split($4,a,"/"); print a[1]; exit}')

icon=$(printf '\xf3\xb0\x88\x80')
if [ -n "$ip" ]; then
    printf '%%{F#6fd3e8}%s%%{F-} %s\n' "$icon" "$ip"
else
    printf '%%{F#8a93a6}%s sin red%%{F-}\n' "$icon"
fi
