#!/usr/bin/env bash
# Ejecuta un comando dentro de la sesion grafica Wayland del usuario (por defecto "hacker").
# Uso: AH_USER=<usuario> asuser.sh <comando> [args...]
set -u
U="${AH_USER:-hacker}"
PID=$(pgrep -u "$U" -x plasmashell | head -1)
if [ -z "$PID" ]; then echo "ERROR: plasmashell no esta corriendo"; exit 1; fi
ENVF=/proc/$PID/environ
get(){ tr '\0' '\n' < "$ENVF" | grep -m1 "^$1=" | cut -d= -f2-; }
RT="$(get XDG_RUNTIME_DIR)"
WD="$(get WAYLAND_DISPLAY)"
DB="$(get DBUS_SESSION_BUS_ADDRESS)"
DP="$(get DISPLAY)"
DD="$(get XDG_DATA_DIRS)"
exec sudo -u "$U" env \
  XDG_RUNTIME_DIR="$RT" \
  WAYLAND_DISPLAY="$WD" \
  DBUS_SESSION_BUS_ADDRESS="$DB" \
  DISPLAY="$DP" \
  XDG_DATA_DIRS="$DD" \
  QT_QPA_PLATFORM=wayland \
  "$@"
