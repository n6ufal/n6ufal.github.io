#!/usr/bin/env python3
"""Generate favicon PNG/ICO assets (green A on Nord dark)."""

from __future__ import annotations

import urllib.request
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
STATIC = ROOT / "static"
CACHE = Path(__file__).resolve().parent / ".cache"
FONT_URL = (
    "https://github.com/IBM/plex/raw/master/packages/plex-sans/fonts/complete/ttf/"
    "IBMPlexSans-Bold.ttf"
)

BG = (0x2E, 0x34, 0x40, 255)
BG_HEX = "#2E3440"
FG = (0xA3, 0xBE, 0x8C, 255)
FG_HEX = "#A3BE8C"
CANVAS = 512
PADDING = 56


def ensure_font() -> Path:
    CACHE.mkdir(parents=True, exist_ok=True)
    font_path = CACHE / "IBMPlexSans-Bold.ttf"
    if not font_path.exists():
        print(f"Downloading {FONT_URL}")
        urllib.request.urlretrieve(FONT_URL, font_path)
    return font_path


def render_letter(size: int, font_path: Path) -> Image.Image:
    img = Image.new("RGBA", (size, size), BG)
    draw = ImageDraw.Draw(img)
    font_size = max(8, int(size * 0.66))
    font = ImageFont.truetype(str(font_path), font_size)
    text = "A"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = (size - tw) / 2 - bbox[0]
    y = (size - th) / 2 - bbox[1] + size * 0.03
    draw.text((x, y), text, font=font, fill=FG)
    return img


def write_png(path: Path, image: Image.Image) -> None:
    image.convert("RGB").save(path, format="PNG", optimize=True)


def glyph_path(font_path: Path) -> tuple[str, tuple[float, float, float, float]]:
    font = TTFont(font_path)
    glyph_set = font.getGlyphSet()
    glyph_name = font.getBestCmap()[ord("A")]
    bounds_pen = BoundsPen(glyph_set)
    glyph_set[glyph_name].draw(bounds_pen)
    path_pen = SVGPathPen(glyph_set)
    glyph_set[glyph_name].draw(path_pen)
    return path_pen.getCommands(), bounds_pen.bounds


def svg_transform(bounds: tuple[float, float, float, float]) -> str:
    x0, y0, x1, y1 = bounds
    gw, gh = x1 - x0, y1 - y0
    scale = (CANVAS - 2 * PADDING) / gh
    tx = (CANVAS - gw * scale) / 2 - x0 * scale
    ty = (CANVAS + gh * scale) / 2 + y0 * scale
    return f"translate({tx:.3f} {ty:.3f}) scale({scale:.6f} {-scale:.6f})"


def write_svgs(font_path: Path) -> None:
    path_d, bounds = glyph_path(font_path)
    transform = svg_transform(bounds)

    favicon_svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {CANVAS} {CANVAS}" role="img" aria-label="alifnaufal">
  <rect width="{CANVAS}" height="{CANVAS}" fill="{BG_HEX}"/>
  <path fill="{FG_HEX}" transform="{transform}" d="{path_d}"/>
</svg>
"""
    pinned_svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {CANVAS} {CANVAS}">
  <path fill="#000" transform="{transform}" d="{path_d}"/>
</svg>
"""
    (STATIC / "favicon.svg").write_text(favicon_svg, encoding="utf-8")
    (STATIC / "safari-pinned-tab.svg").write_text(pinned_svg, encoding="utf-8")
    print(f"Wrote {STATIC / 'favicon.svg'}")
    print(f"Wrote {STATIC / 'safari-pinned-tab.svg'}")


def write_ico(path: Path, images: list[Image.Image]) -> None:
    images[0].save(
        path,
        format="ICO",
        sizes=[(img.width, img.height) for img in images],
        append_images=images[1:],
    )


def main() -> None:
    font_path = ensure_font()
    outputs = {
        "favicon-16x16.png": 16,
        "favicon-32x32.png": 32,
        "apple-touch-icon.png": 180,
        "android-chrome-192x192.png": 192,
        "android-chrome-512x512.png": 512,
    }

    rendered: dict[int, Image.Image] = {}
    for name, size in outputs.items():
        img = render_letter(size, font_path)
        rendered[size] = img
        out = STATIC / name
        write_png(out, img)
        print(f"Wrote {out}")

    ico_path = STATIC / "favicon.ico"
    write_ico(ico_path, [rendered[16], rendered[32]])
    print(f"Wrote {ico_path}")

    write_svgs(font_path)


if __name__ == "__main__":
    main()
