#!/usr/bin/env python3
"""Orbital — estilo de Plasma: copia el tema Orbiter y cambia el fondo de los
paneles por píldoras redondeadas (fondo #0b0e17 de bspwm, borde verde del login).
Uso: make_theme.py <dir-tema-orbiter> <dir-destino>"""
import json, os, shutil, sys

src, dst = sys.argv[1], sys.argv[2]
if os.path.exists(dst):
    shutil.rmtree(dst)
shutil.copytree(src, dst)

meta = os.path.join(dst, "metadata.json")
m = json.load(open(meta, encoding="utf-8"))
m["KPlugin"].update({"Id": "orbital", "Name": "Orbital",
                     "Description": "Píldoras redondeadas estilo bspwm con borde verde de terminal"})
json.dump(m, open(meta, "w", encoding="utf-8"), indent=4, ensure_ascii=False)

R = 10            # radio = tamaño de esquina
FILL = "#0b0e17"
OP = "0.94"
STROKE = "#1c6b36"
h = 0.5           # medio píxel para trazo nítido

def corner(name, ox, oy, sx, sy, mask=False):
    # arco de cuarto de círculo; (sx, sy) = hacia dónde está el interior
    cx, cy = ox + (R if sx > 0 else 0), oy + (R if sy > 0 else 0)
    # punto de inicio en el borde exterior horizontal, fin en el vertical
    x0, y0 = cx, oy + (h if sy > 0 else R - h)
    x1, y1 = ox + (h if sx > 0 else R - h), cy
    sweep = 0 if (sx > 0) == (sy > 0) else 1
    area = f'M{x0},{y0} A{R-h},{R-h} 0 0 {sweep} {x1},{y1} L{cx},{cy} Z'
    arc = f'M{x0},{y0} A{R-h},{R-h} 0 0 {sweep} {x1},{y1}'
    g = [f'<g id="{name}">',
         f'<rect x="{ox}" y="{oy}" width="{R}" height="{R}" fill="#000" fill-opacity="0"/>']
    if mask:
        g.append(f'<path d="{area}" fill="#000"/>')
    else:
        g.append(f'<path d="{area}" fill="{FILL}" fill-opacity="{OP}"/>')
        g.append(f'<path d="{arc}" fill="none" stroke="{STROKE}" stroke-width="1"/>')
    g.append('</g>')
    return "\n".join(g)

def edge(name, ox, oy, side, mask=False):
    g = [f'<g id="{name}">']
    if mask:
        g.append(f'<rect x="{ox}" y="{oy}" width="{R}" height="{R}" fill="#000"/>')
    else:
        g.append(f'<rect x="{ox}" y="{oy}" width="{R}" height="{R}" fill="{FILL}" fill-opacity="{OP}"/>')
        line = {"top": (ox, oy + h, ox + R, oy + h), "bottom": (ox, oy + R - h, ox + R, oy + R - h),
                "left": (ox + h, oy, ox + h, oy + R), "right": (ox + R - h, oy, ox + R - h, oy + R)}[side]
        g.append(f'<line x1="{line[0]}" y1="{line[1]}" x2="{line[2]}" y2="{line[3]}" stroke="{STROKE}" stroke-width="1"/>')
    g.append('</g>')
    return "\n".join(g)

def frame(prefix, oy, mask=False):
    p = prefix
    out = [
        corner(p + "topleft", 0, oy, 1, 1, mask),
        edge(p + "top", R, oy, "top", mask),
        corner(p + "topright", 2 * R, oy, -1, 1, mask),
        edge(p + "left", 0, oy + R, "left", mask),
        f'<rect id="{p}center" x="{R}" y="{oy + R}" width="{R}" height="{R}" fill="{"#000" if mask else FILL}"'
        + ("" if mask else f' fill-opacity="{OP}"') + '/>',
        edge(p + "right", 2 * R, oy + R, "right", mask),
        corner(p + "bottomleft", 0, oy + 2 * R, 1, -1, mask),
        edge(p + "bottom", R, oy + 2 * R, "bottom", mask),
        corner(p + "bottomright", 2 * R, oy + 2 * R, -1, -1, mask),
    ]
    return "\n".join(out)

svg = [
    '<svg xmlns="http://www.w3.org/2000/svg" width="80" height="120" viewBox="0 0 80 120">',
    frame("", 0),
    frame("mask-", 40, mask=True),
    '<rect id="hint-top-margin" x="40" y="0" width="1" height="3" fill="none"/>',
    '<rect id="hint-bottom-margin" x="42" y="0" width="1" height="3" fill="none"/>',
    '<rect id="hint-left-margin" x="44" y="0" width="8" height="1" fill="none"/>',
    '<rect id="hint-right-margin" x="44" y="4" width="8" height="1" fill="none"/>',
    '</svg>',
]
text = "\n".join(svg) + "\n"
for sub in ("widgets", "opaque/widgets", "solid/widgets", "translucent/widgets"):
    d = os.path.join(dst, sub)
    if os.path.isdir(d):
        open(os.path.join(d, "panel-background.svg"), "w", encoding="utf-8").write(text)
print("tema Orbital escrito en", dst)
