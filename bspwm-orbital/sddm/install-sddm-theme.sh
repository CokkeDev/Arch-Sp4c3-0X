#!/usr/bin/env bash
# Orbital — instala el tema de login para SDDM. Ejecutar como root:
#   sudo bash install-sddm-theme.sh [usuario]
# Reutiliza la escena ASCII del fondo Orbiter (MIT) que ya tiene el usuario.
# No toca el autologin.
set -euo pipefail

USER_NAME="${1:-${SUDO_USER:-hacker}}"
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST=/usr/share/sddm/themes/orbital
ORB="$(getent passwd "$USER_NAME" | cut -d: -f6)/.local/share/plasma/wallpapers/org.orbiter.wallpaper/contents/ui"

[ "$(id -u)" -eq 0 ] || { echo "Ejecútalo con sudo."; exit 1; }
[ -f "$ORB/AsciiScene.qml" ] || { echo "No encuentro el fondo Orbiter en $ORB"; exit 1; }

rm -rf "$DEST"
mkdir -p "$DEST/orbiter"
cp "$SRC/orbital/"{Main.qml,metadata.desktop,theme.conf} "$DEST/"
cp -r "$ORB/AsciiScene.qml" "$ORB/shaders" "$ORB/textures" "$DEST/orbiter/"
chmod -R a+rX "$DEST"

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf <<'EOF'
[Theme]
Current=orbital
EOF

echo "Tema Orbital instalado en $DEST y activado."
echo "Pruébalo sin cerrar sesión con:"
echo "  sddm-greeter-qt6 --test-mode --theme $DEST"
