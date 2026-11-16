# Orbital: bspwm + polybar

Entorno de pentesting al estilo S4vitar, adaptado al fondo ASCII de la Tierra.
Diseño: https://claude.ai/artifact/EACVk7iA4wJZnFBHtK6u1H

Se instala como **otra sesión** en SDDM. KDE Plasma no se toca: eliges una u
otra al iniciar sesión.

## Instalar

En la VM, como el usuario `hacker`:

```bash
cd bspwm-orbital && bash install.sh
```

Hace un respaldo de cualquier config que ya exista (`~/.config/<app>.bak-FECHA`).

## Qué hay

| Carpeta | Va a | Qué hace |
|---|---|---|
| `bspwm/bspwmrc` | `~/.config/bspwm/` | gaps 12, borde 2, azul `#5b7cfa` activo, 6 escritorios |
| `sxhkd/sxhkdrc` | `~/.config/sxhkd/` | atajos (abajo) |
| `polybar/` | `~/.config/polybar/` | 8 píldoras flotantes y sus scripts |
| `picom/picom.conf` | `~/.config/picom/` | esquinas de 10 px, sombras, blur detrás de kitty |
| `kitty/kitty.conf` | `~/.config/kitty/` | opacidad 0.82, paleta Orbital |
| `rofi/orbital.rasi` | `~/.config/rofi/` | lanzador y menú de apagado |
| `shell/orbital.sh` | `~/.config/orbital/` | `settarget`, `cleartarget`, `mkt`, `extractPorts`, `whichsystem`, prompt |

## Barra

`[arch] [eth 192.168.x.x] [vpn 10.10.14.x]   ● ○ ○ · · ·   [mira 10.10.11.42] [cpu ram ↓] [reloj 11:33] [apagar]`

- **Objetivo**: `settarget 10.10.11.42` / `cleartarget`. Usa el mismo archivo que
  el widget «IP víctima» de KDE (`~/.config/archhacker/target_ip`), así que
  sirve en las dos sesiones. Clic en la píldora para copiar la IP.
- **VPN**: muestra la IP de `tun0`; si no hay VPN, «desconectada».
- **Escritorios**: ● activo · ○ con ventanas · `·` vacío.

## Atajos

| Tecla | Acción |
|---|---|
| super + Enter | kitty |
| super + d | rofi |
| super + shift + f / b | firefox / burpsuite |
| super + w | cerrar ventana |
| super + flechas | mover foco |
| super + shift + flechas | intercambiar ventanas |
| super + 1‑6 / shift + 1‑6 | ir a escritorio / mandar ventana |
| super + alt + flechas | redimensionar |
| super + ctrl + alt + flechas | preseleccionar dónde se abre la próxima |
| super + t / s / f | mosaico / flotante / pantalla completa |
| super + m | monocle |
| super + Escape | recargar atajos |
| super + shift + r / q | reiniciar bspwm / salir |
| Impr | flameshot |

## Ajustes

- **Otra resolución**: las píldoras se anclan a los bordes (`offset-x = 100%:-N`),
  así que se acomodan solas. Si alguna IP larga no entra, sube su `width` en
  `config.ini`.
- **picom en VMware**: si no arranca o parpadea, cambia `backend = "glx"` por
  `"xrender"` (se pierde el blur).
- **Íconos que salen como cuadros**: falta `ttf-jetbrains-mono-nerd` o el glifo
  cambió de código; cámbialo en `config.ini` o en `polybar/scripts/*.sh`.

## Login (SDDM)

`sddm/` tiene el tema **Orbital**: una terminal verde para elegir entre Plasma y bspwm,
sobre la escena ASCII del fondo Orbiter (Tierra y luna reales, 0,02 rad/s, sin seguir al ratón).

```bash
sudo bash sddm/install-sddm-theme.sh hacker
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/orbital   # probar sin cerrar sesión
```

Lo activa en `/etc/sddm.conf.d/theme.conf`. No toca el autologin: con autologin
el login aparece al **cerrar sesión**. Para volver al de KDE, borra ese archivo.
