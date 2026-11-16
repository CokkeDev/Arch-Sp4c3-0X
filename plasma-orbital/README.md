# Plasma Orbital

Estilo de KDE Plasma que combina las píldoras de bspwm con la terminal verde del login.

- **Colores** `OrbitalTerminal`: fondo oscuro #0b0e17 y acentos verdes #39ff6e (generados desde OrbiterBlack por `make_colors.py`).
- **Estilo de Plasma** `orbital`: copia de Orbiter con paneles en píldora redondeada y borde verde (`make_theme.py`).
- **Paneles** (`layout.js`): arriba [Arch + escritorios 1-6] · [calaveras] · [recursos · bandeja · reloj · salir]; abajo dock centrado. Quita el widget "IP víctima".
- **Fuente** JetBrainsMono Nerd Font en todo; **Konsole** con perfil `Orbital` (verde del login).

## Aplicar (dentro de la sesión Plasma, como tu usuario)

    bash apply.sh

Hace respaldo en `~/.config/orbital-plasma-backup-<fecha>/`.

## Volver atrás

    bash restore.sh ~/.config/orbital-plasma-backup-<fecha>
