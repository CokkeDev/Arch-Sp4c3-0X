#!/usr/bin/env bash
# Vuelve al Plasma anterior: bash restore.sh ~/.config/orbital-plasma-backup-<fecha>
set -euo pipefail
BK="${1:?indica la carpeta de respaldo}"
cp "$BK"/* "$HOME/.config/"
plasma-apply-colorscheme OrbiterBlack || true
plasma-apply-desktoptheme orbiter || true
systemctl --user restart plasma-plasmashell.service
