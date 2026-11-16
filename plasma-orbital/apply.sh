#!/usr/bin/env bash
# Orbital para Plasma — ejecutar como el usuario, DENTRO de la sesión Plasma:
#   bash apply.sh
# Cambia colores, estilo de Plasma, fuentes, Konsole y paneles. Respaldo en
# ~/.config/orbital-plasma-backup-<fecha>/ (restaurar: restore.sh <carpeta>).
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config"; DATA="$HOME/.local/share"
STAMP="$(date +%Y%m%d-%H%M%S)"
BK="$CFG/orbital-plasma-backup-$STAMP"
ORB_SCHEME="$DATA/color-schemes/OrbiterBlack.colors"
ORB_THEME="$DATA/plasma/desktoptheme/orbiter"

echo "[1/6] Respaldo en $BK"
mkdir -p "$BK"
for f in plasma-org.kde.plasma.desktop-appletsrc plasmashellrc kdeglobals plasmarc konsolerc kwinrc; do
    [ -f "$CFG/$f" ] && cp "$CFG/$f" "$BK/"
done

echo "[2/6] Esquema de colores Orbital Terminal"
python3 "$SRC/make_colors.py" "$ORB_SCHEME" "$DATA/color-schemes/OrbitalTerminal.colors"
plasma-apply-colorscheme OrbitalTerminal

echo "[3/6] Estilo de Plasma Orbital (píldoras)"
python3 "$SRC/make_theme.py" "$ORB_THEME" "$DATA/plasma/desktoptheme/orbital"
plasma-apply-desktoptheme orbital

echo "[4/6] Fuentes JetBrainsMono"
F="JetBrainsMono Nerd Font"
kwriteconfig6 --file kdeglobals --group General --key font "$F,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwriteconfig6 --file kdeglobals --group General --key fixed "$F,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "$F,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwriteconfig6 --file kdeglobals --group General --key toolBarFont "$F,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwriteconfig6 --file kdeglobals --group General --key menuFont "$F,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwriteconfig6 --file kdeglobals --group WM --key activeFont "$F,10,-1,5,700,0,0,0,0,0,0,0,0,0,0,1"

echo "[5/6] Konsole verde"
mkdir -p "$DATA/konsole"
cp "$SRC/konsole/OrbitalTerminal.colorscheme" "$SRC/konsole/Orbital.profile" "$DATA/konsole/"
kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile Orbital.profile

echo "    ícono de Arch verde y 6 escritorios (como bspwm)"
mkdir -p "$DATA/icons/hicolor/scalable/apps"
sed 's/#1793d1/#39ff6e/' /usr/share/pixmaps/archlinux-logo.svg > "$DATA/icons/hicolor/scalable/apps/orbital-arch.svg"
VDM="org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager"
n=$(qdbus6 org.kde.KWin /VirtualDesktopManager org.freedesktop.DBus.Properties.Get org.kde.KWin.VirtualDesktopManager count)
while [ "$n" -lt 6 ]; do
    # shellcheck disable=SC2086
    qdbus6 $VDM.createDesktop "$n" "$((n + 1))" >/dev/null; n=$((n + 1))
done

echo "[6/6] Paneles tipo píldora"
ids=$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$SRC/layout.js")" | tail -1)
echo "    paneles: $ids"
sleep 3   # que plasmashell guarde los paneles nuevos
systemctl --user stop plasma-plasmashell.service
for id in $ids; do
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $id" --key floating 1
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $id" --key panelLengthMode 1
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $id" --key panelOpacity 1
    kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group Containments --group "$id" --key floating 1
done
systemctl --user start plasma-plasmashell.service
echo "Listo. Respaldo: $BK"
