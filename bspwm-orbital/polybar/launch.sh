#!/usr/bin/env bash
# Orbital — lanza una barra por cada píldora

killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.2; done

CFG="$HOME/.config/polybar/config.ini"
for bar in logo ethernet vpn workspaces target system clock power; do
    polybar -q "$bar" -c "$CFG" &
done
