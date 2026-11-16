#!/usr/bin/env python3
"""Orbital: genera un fondo estático en ASCII (Tierra + luna + estrellas)
a partir de las texturas del tema Orbiter de KDE.

uso: make_wallpaper.py <salida.png> [ancho] [alto]
Requiere python-pillow.
"""
import math
import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT = sys.argv[1] if len(sys.argv) > 1 else "wallpaper.png"
W = int(sys.argv[2]) if len(sys.argv) > 2 else 1920
H = int(sys.argv[3]) if len(sys.argv) > 3 else 1080

TEX = Path.home() / ".local/share/plasma/wallpapers/org.orbiter.wallpaper/contents/ui/textures"
FONT_CANDIDATES = [
    "/usr/share/fonts/TTF/JetBrainsMonoNerdFontMono-Regular.ttf",
    "/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf",
    "/usr/share/fonts/TTF/DejaVuSansMono.ttf",
]

RAMP = " .-=+*%0@#"
random.seed(7)


def load_font(size):
    for f in FONT_CANDIDATES:
        if Path(f).exists():
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


def load_tex(name, fallback):
    p = TEX / name
    if p.exists():
        return Image.open(p).convert("RGB")
    return Image.new("RGB", (64, 32), fallback)


def sphere(draw, font, cw, ch, cx, cy, r, tex, clouds, light, rot, tint, boost):
    tw, th = tex.size
    lx, ly, lz = light
    for row in range(int((cy - r) // ch), int((cy + r) // ch) + 1):
        y = row * ch + ch / 2
        if y < 0 or y > H:
            continue
        for col in range(int((cx - r) // cw), int((cx + r) // cw) + 1):
            x = col * cw + cw / 2
            if x < 0 or x > W:
                continue
            nx, ny = (x - cx) / r, (y - cy) / r
            d = nx * nx + ny * ny
            if d > 1:
                continue
            nz = math.sqrt(1 - d)
            lat = math.asin(-ny)
            lon = math.atan2(nx, nz) + rot
            u = (lon / (2 * math.pi) + 0.5) % 1.0
            v = 0.5 - lat / math.pi
            px = tex.getpixel((int(u * (tw - 1)), int(v * (th - 1))))
            lum = (0.3 * px[0] + 0.59 * px[1] + 0.11 * px[2]) / 255
            if clouds is not None:
                cl = clouds.getpixel((int(u * (clouds.size[0] - 1)), int(v * (clouds.size[1] - 1))))
                cl = (cl[0] + cl[1] + cl[2]) / 765
                lum = max(lum, cl * 0.9)
            shade = max(0.0, nx * lx + ny * ly + nz * lz)
            val = min(1.0, (lum * boost + 0.18) * (0.25 + 0.75 * shade))
            ch_ = RAMP[min(len(RAMP) - 1, int(val * (len(RAMP) - 1) + 0.5))]
            if ch_ == " ":
                continue
            col_rgb = tuple(int(min(255, (px[i] * 0.55 + tint[i] * 0.45) * (0.35 + 0.9 * shade))) for i in range(3))
            draw.text((col * cw, row * ch), ch_, font=font, fill=col_rgb)


def main():
    img = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(img)
    s = H / 1080
    font = load_font(max(7, int(9 * s)))
    cw, ch = max(4, int(5.6 * s)), max(7, int(10 * s))

    # estrellas
    small = load_font(max(8, int(11 * s)))
    for _ in range(int(220 * (W * H) / (1920 * 1080))):
        x, y = random.randrange(W), random.randrange(H)
        b = random.random()
        c = (255, 255, 255) if b > 0.9 else (196, 202, 214) if b > 0.55 else (90, 98, 116)
        draw.text((x, y), random.choice(".....+*"), font=small, fill=c)

    earth = load_tex("earth.jpg", (40, 70, 160))
    clouds = load_tex("earth_clouds.jpg", (0, 0, 0)) if (TEX / "earth_clouds.jpg").exists() else None
    moon = load_tex("moon.jpg", (150, 150, 160))

    # luna (arriba a la derecha)
    sphere(draw, font, cw, ch, W * 0.79, H * 0.17, H * 0.11, moon, None,
           (-0.5, -0.4, 0.77), 0.0, (200, 205, 215), 1.0)
    # Tierra (abajo, asomando como en Orbiter)
    sphere(draw, font, cw, ch, W * 0.49, H * 1.10, W * 0.42, earth, clouds,
           (-0.45, -0.55, 0.70), 1.9, (91, 124, 250), 1.25)

    img.save(OUT, format="PNG")
    print(f"fondo generado: {OUT} ({W}x{H})")


if __name__ == "__main__":
    main()
