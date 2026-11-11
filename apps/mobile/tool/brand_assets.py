"""BiTadilat marka işaretinden iOS uygulama ikonunu ve açılış görselini üretir.

İşaret, uygulamadaki `BrandMark` (lib/features/common/widgets.dart) ile aynı
geometriyi kullanır: koyu teal degrade karo, beyaz ev çizgisi, nane yeşili onay.
Bu dosyayı değiştirirsen `BrandMark` ölçülerini de aynı tut.

Kullanım (Pillow gerekir):
    python3 tool/brand_assets.py            # apps/mobile içinden
"""

import json
import os

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, "..", "ios", "Runner", "Assets.xcassets")

TOP = (0x11, 0x59, 0x6B)  # degrade üst
BOTTOM = (0x0A, 0x39, 0x45)  # AppColors.primaryDark
HOUSE = (0xFF, 0xFF, 0xFF)
CHECK = (0x72, 0xD9, 0xAE)

# 32 birimlik çizim alanı; karo kenarının GLYPH oranı kadarına sığdırılır.
VIEWBOX = 32.0
GLYPH = 0.62
TILE_RADIUS = 0.2237
HOUSE_PTS = [(6, 13.5), (16, 5.5), (26, 13.5), (26, 26), (6, 26), (6, 13.5)]
HOUSE_STROKE = 2.5
CHECK_PTS = [(11.5, 18), (14.5, 21), (20, 14.5)]
CHECK_STROKE = 2.75

SS = 8  # süper örnekleme


def _gradient(size):
    grad = Image.new("RGB", (1, size))
    for y in range(size):
        t = y / max(size - 1, 1)
        grad.putpixel(
            (0, y), tuple(round(a + (b - a) * t) for a, b in zip(TOP, BOTTOM))
        )
    return grad.resize((size, size))


def _stroke(draw, pts, width, color):
    draw.line(pts, fill=color, width=round(width))
    r = width / 2
    for x, y in pts:
        draw.ellipse((x - r, y - r, x + r, y + r), fill=color)


def render(px, rounded):
    """`px` kenarlı işaret; `rounded` ise köşeler saydam yuvarlatılır."""
    s = px * SS
    img = _gradient(s).convert("RGBA")
    draw = ImageDraw.Draw(img)
    unit = s * GLYPH / VIEWBOX
    off = (s - s * GLYPH) / 2

    def tr(pts):
        return [(off + x * unit, off + y * unit) for x, y in pts]

    _stroke(draw, tr(HOUSE_PTS), HOUSE_STROKE * unit, HOUSE)
    _stroke(draw, tr(CHECK_PTS), CHECK_STROKE * unit, CHECK)
    if rounded:
        mask = Image.new("L", (s, s), 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            (0, 0, s - 1, s - 1), radius=round(s * TILE_RADIUS), fill=255
        )
        img.putalpha(mask)
    return img.resize((px, px), Image.LANCZOS)


def app_icons():
    folder = os.path.join(ASSETS, "AppIcon.appiconset")
    with open(os.path.join(folder, "Contents.json")) as f:
        images = json.load(f)["images"]
    master = render(1024, rounded=False).convert("RGB")  # iOS alfa istemez
    for item in images:
        pt = float(item["size"].split("x")[0])
        scale = int(item["scale"].rstrip("x"))
        px = round(pt * scale)
        out = master if px == 1024 else master.resize((px, px), Image.LANCZOS)
        out.save(os.path.join(folder, item["filename"]), optimize=True)


# Açılış ekranındaki karo: 96 pt. `SplashScreen` aynı ölçüyü kullanır.
LAUNCH_PT = 96


def launch_images():
    folder = os.path.join(ASSETS, "LaunchImage.imageset")
    for scale, name in ((1, "LaunchImage.png"), (2, "LaunchImage@2x.png"),
                        (3, "LaunchImage@3x.png")):
        render(LAUNCH_PT * scale, rounded=True).save(
            os.path.join(folder, name), optimize=True
        )


if __name__ == "__main__":
    app_icons()
    launch_images()
    print("AppIcon ve LaunchImage güncellendi.")
