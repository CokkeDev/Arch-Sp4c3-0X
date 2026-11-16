#!/usr/bin/env bash
# IP de la VPN (HTB / THM / OpenVPN en tun0)
ip=$(ip -4 -o addr show tun0 2>/dev/null | awk '{split($4,a,"/"); print a[1]}')

icon=$(printf '\xef\x84\xb2')
if [ -n "$ip" ]; then
    printf '%%{F#9bd59a}%s%%{F-} %s %%{F#8a93a6}vpn%%{F-}\n' "$icon" "$ip"
else
    printf '%%{F#8a93a6}%s desconectada%%{F-}\n' "$icon"
fi
