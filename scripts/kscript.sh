#!/usr/bin/env bash
# kscript.sh <archivo.js> : ejecuta el JS de Plasma en la sesion grafica del usuario (ver asuser.sh)
set -u
JS="$(cat "$1")"
exec bash /root/asuser.sh qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$JS"
