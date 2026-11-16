#!/usr/bin/env bash
# Instala dependencias de Orbiter y aplica el fondo animado + splash.
set -uo pipefail

echo "### 1. Dependencias de compilacion/tema"
pacman -S --needed --noconfirm \
  python-pillow qt6-shadertools qt6-tools qt6-declarative \
  plymouth ttf-ibm-plex fastfetch pacman-contrib power-profiles-daemon \
  bluez-qt milou 2>&1 | tail -6

echo "### 2. Ejecutar 'orbiter install' como hacker en la sesion Wayland"
bash /root/asuser.sh bash -c 'cd $HOME/orbital && ./orbiter install' 2>&1 | tail -50
echo "### ORBITER_INSTALL_FIN rc=$?"
