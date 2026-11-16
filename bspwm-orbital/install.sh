#!/usr/bin/env bash
# Orbital — instala bspwm + polybar como sesión ADICIONAL (KDE Plasma queda intacto).
# Ejecutar como tu usuario (no root):  bash install.sh
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [ "$(id -u)" -eq 0 ]; then
    echo "Ejecútalo como tu usuario normal, no como root."; exit 1
fi

PKGS="bspwm sxhkd polybar picom kitty rofi feh xclip flameshot bat
      xorg-server xorg-xinit xorg-xsetroot xorg-xrandr ttf-jetbrains-mono-nerd python-pillow
      qt6-declarative xdotool"

echo "[1/5] Paquetes"
if [ -n "${SKIP_PKGS:-}" ]; then
    echo "    omitido (SKIP_PKGS); instálalos con: pacman -S --needed $PKGS"
else
    # shellcheck disable=SC2086
    sudo pacman -S --needed --noconfirm $PKGS
fi

echo "[2/5] Copiando configs (respaldo de lo existente en *.bak-$STAMP)"
for d in bspwm sxhkd polybar picom kitty rofi; do
    if [ -e "$CFG/$d" ]; then mv "$CFG/$d" "$CFG/$d.bak-$STAMP"; fi
    cp -r "$SRC/$d" "$CFG/$d"
done
mkdir -p "$CFG/orbital" "$CFG/archhacker"
cp "$SRC/shell/orbital.sh" "$CFG/orbital/orbital.sh"
rm -f "$CFG/orbital/orbital.zsh"
touch "$CFG/archhacker/target_ip"

# Fondo animado: la misma escena Orbiter (MIT) que usa el login
ORB="$HOME/.local/share/plasma/wallpapers/org.orbiter.wallpaper/contents/ui"
rm -rf "$CFG/orbital/background"
if [ -f "$ORB/AsciiScene.qml" ]; then
    mkdir -p "$CFG/orbital/background/orbiter"
    cp "$SRC/background/"{Background.qml,start.sh} "$CFG/orbital/background/"
    cp -r "$ORB/AsciiScene.qml" "$ORB/shaders" "$ORB/textures" "$CFG/orbital/background/orbiter/"
    chmod +x "$CFG/orbital/background/start.sh"
else
    echo "    sin fondo Orbiter: se usará la imagen estática"
fi

chmod +x "$CFG/bspwm/bspwmrc" "$CFG/polybar/launch.sh" "$CFG"/polybar/scripts/*.sh

echo "[3/5] Íconos Nerd Font en la polybar"
ini="$CFG/polybar/config.ini"
sed -i \
    -e "s/@ARCH@/$(printf '\xef\x8c\x83')/g" \
    -e "s/@CPU@/$(printf '\xef\x8b\x9b')/g" \
    -e "s/@MEM@/$(printf '\xf3\xb0\x8d\x9b')/g" \
    -e "s/@CLOCK@/$(printf '\xef\x80\x97')/g" \
    -e "s/@POWER@/$(printf '\xef\x80\x91')/g" \
    "$ini"

echo "[4/5] Fondo de pantalla (el mismo de KDE, si es una imagen)"
plasma="$CFG/plasma-org.kde.plasma.desktop-appletsrc"
wp=""
if [ -f "$plasma" ]; then
    wp="$(grep -m1 '^Image=' "$plasma" | sed -e 's/^Image=//' -e 's|^file://||' || true)"
fi
if [ -n "$wp" ] && [ -f "$wp" ]; then
    cp "$wp" "$CFG/bspwm/wallpaper"
    echo "    usando $wp"
elif python3 -c 'import PIL' 2>/dev/null; then
    echo "    tu fondo es el plugin animado de Orbiter: genero una versión ASCII estática"
    python3 "$SRC/wallpaper/make_wallpaper.py" "$CFG/bspwm/wallpaper" 1920 1080
else
    echo "    no encontré una imagen; quedará fondo negro."
    echo "    para generar el fondo ASCII: sudo pacman -S python-pillow y vuelve a correr install.sh"
    echo "    o pon uno propio: cp <imagen> ~/.config/bspwm/wallpaper"
fi

echo "[5/5] Funciones de shell (settarget, extractPorts, whichsystem…)"
line='[ -f ~/.config/orbital/orbital.sh ] && source ~/.config/orbital/orbital.sh'
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    sed -i '/orbital\/orbital\.zsh/d' "$rc"
    grep -qxF "$line" "$rc" || echo "$line" >> "$rc"
done

cat <<'EOF'

Listo. Para entrar:
  1. Cierra sesión de KDE.
  2. En SDDM elige la sesión "bspwm" (abajo a la izquierda) e inicia.
  3. super+Enter abre kitty · super+d abre rofi · super+shift+q sale.

Para volver a KDE: cierra sesión y elige "Plasma (Wayland)".
Si tienes autologin en Plasma, SDDM no te mostrará el selector: desactívalo
en Configuración del sistema > Pantalla de inicio de sesión, o usa
"Cerrar sesión" desde KDE y elige bspwm.
EOF
