# Arch-Sp4c3-0X — Arch Linux para pentesting (KDE Plasma 6 + bspwm)

Receta para **reconstruir** un Arch Linux de laboratorio de hacking ético con dos
escritorios a elegir en el login:

- **KDE Plasma 6** con estilo *Orbital*: paneles en píldora, acentos verdes de terminal.
- **bspwm** : polybar en píldoras, kitty, rofi y atajos de teclado.
- **Login (SDDM)** tipo terminal verde sobre una Tierra ASCII animada.

No incluye el disco de la máquina virtual: solo scripts y configuraciones, para
que la recrees desde la ISO oficial de Arch.

> ⚠️ **Solo para uso autorizado**: sistemas propios, laboratorios (HackTheBox,
> TryHackMe) o pruebas con autorización por escrito.

## Estructura

| Carpeta | Qué contiene |
|---|---|
| `scripts/arch_base_install.sh` | Instalación base desde la ISO: particiones UEFI, KDE Plasma, usuario, bootloader. **Borra el disco indicado** (pide confirmación). |
| `scripts/pentest_tools.sh`, `fix_tools.sh` | Repositorio BlackArch y herramientas por categoría. |
| `scripts/menu_setup.sh` | Menú de aplicaciones de pentest por categorías en español. |
| `scripts/privacy_setup.sh` | Tor, Tor Browser, uBlock Origin en Firefox y nombre de equipo privado. |
| `scripts/orbiter_apply.sh`, `panel.js`, … | Tema Orbiter y paneles de Plasma (scripting). |
| `widgets/` | Widgets propios de Plasma: objetivo IP y calaveras 8-bit por ventana. |
| `plasma-orbital/` | Estilo Orbital para Plasma (colores, paneles, Konsole). Ver su README. |
| `bspwm-orbital/` | Sesión bspwm + polybar + tema de login SDDM. Ver su README. |
| `packages-explicit.txt` | Paquetes instalados explícitamente. |

## Instalación (resumen)

1. Crea una VM UEFI (probado en VMware Workstation: 4 CPU, 6 GB RAM, 80 GB, 3D activado).
2. Arranca la ISO de Arch y ejecuta la instalación base (te pide confirmación y contraseñas):
   ```bash
   DISK=/dev/sda AH_USER=hacker AH_HOSTNAME=archhacker AH_TZ=UTC bash scripts/arch_base_install.sh
   ```
3. Reinicia y, como root: `pentest_tools.sh`, `fix_tools.sh`, `menu_setup.sh`.
4. Tema Orbiter para Plasma: `scripts/orbiter_apply.sh`.
5. Widgets: `kpackagetool6 --type Plasma/Applet --install widgets/<nombre>`.
6. Escritorio bspwm y login: [`bspwm-orbital/README.md`](bspwm-orbital/README.md).
7. Estilo Plasma Orbital: [`plasma-orbital/README.md`](plasma-orbital/README.md).
8. Privacidad (opcional): `sudo bash scripts/privacy_setup.sh localhost`.

## Créditos

- Tema y escena **Orbiter** — [omnicons/orbital-kde-shell](https://github.com/omnicons/orbital-kde-shell) (MIT).
  Se descarga e instala desde su repositorio; aquí no se redistribuyen sus archivos.
- Texturas de la Tierra y la Luna usadas por Orbiter: NASA (dominio público).
- **kvitals** — [yassine20011/kvitals](https://github.com/yassine20011/kvitals).
- Idea del entorno bspwm: estilo popularizado por S4vitar.
- [BlackArch](https://blackarch.org) para las herramientas de pentest.

## Licencia

[MIT](LICENSE)
