#!/usr/bin/env bash
# Menú de apagado. "Cerrar sesión" vuelve a SDDM, donde puedes elegir Plasma.
choice=$(printf 'Bloquear pantalla\nCerrar sesión\nReiniciar\nApagar' \
  | rofi -dmenu -i -p 'sesión' -theme ~/.config/rofi/orbital.rasi)

case "$choice" in
    'Bloquear pantalla') loginctl lock-session ;;
    'Cerrar sesión')     bspc quit ;;
    'Reiniciar')         systemctl reboot ;;
    'Apagar')            systemctl poweroff ;;
esac
