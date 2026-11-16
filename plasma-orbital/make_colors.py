#!/usr/bin/env python3
"""Orbital Terminal — esquema de colores KDE.
Parte del esquema OrbiterBlack y cambia la paleta: fondo de las píldoras de
bspwm + verdes de la terminal del login. Uso: make_colors.py <OrbiterBlack.colors> <salida>"""
import sys

MAP = {
    "6,10,14":     "7,11,10",      # fondo de ventana
    "0,0,0":       "2,6,4",        # vistas (listas, editores)
    "18,18,23":    "11,18,14",     # botones / alterno
    "9,9,12":      "5,10,7",
    "31,36,41":    "16,38,24",
    "234,160,103": "57,255,110",   # acento naranja -> verde login #39ff6e
    "181,186,241": "57,255,110",   # activo / enlaces
    "143,147,151": "43,191,85",    # texto inactivo -> verde tenue #2bbf55
    "236,239,243": "214,240,222",  # texto normal (blanco verdoso)
    "217,112,95":  "255,77,94",    # negativo -> rojo bspwm
    "143,181,138": "155,213,154",  # positivo
    "148,98,76":   "20,92,42",     # selección
    "215,192,181": "157,255,184",
    "251,243,238": "236,255,241",
}

src, out = sys.argv[1], sys.argv[2]
lines = []
for line in open(src, encoding="utf-8"):
    s = line.rstrip("\n")
    if "=" in s and not s.startswith("["):
        k, v = s.split("=", 1)
        if v in MAP:
            s = f"{k}={MAP[v]}"
        if k == "ColorScheme":
            s = "ColorScheme=OrbitalTerminal"
        if k == "Name":
            s = "Name=Orbital Terminal"
    if s.startswith("#"):
        s = "# Orbital Terminal — generado por make_colors.py a partir de OrbiterBlack"
    lines.append(s)
open(out, "w", encoding="utf-8").write("\n".join(lines) + "\n")
