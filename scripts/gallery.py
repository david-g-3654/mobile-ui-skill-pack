#!/usr/bin/env python3
"""Compose the before/after gallery images from eval screenshots (requires Pillow).

  python3 scripts/gallery.py hero     <out.png> <prompt> <swift_base> <swift_pack> <rn_base> <rn_pack> <fl_base> <fl_pack>
  python3 scripts/gallery.py platform <out.png> <platform> <prompt> <base_light> <base_dark> <base_axl> <pack_light> <pack_dark> <pack_axl>
  python3 scripts/gallery.py sheet    <out.png> <platform> <base_pattern> <pack_pattern>      # patterns contain {id}

Screenshots are pasted unedited (scaled only). Captions state the prompt, the model and the setup.
"""
import sys
from PIL import Image, ImageDraw, ImageFont

INK, INK2, CANVAS, RULE = (17, 17, 19), (110, 110, 118), (246, 245, 242), (220, 218, 212)
FONT = "/System/Library/Fonts/Helvetica.ttc"
MODEL_LINE = "Claude Opus 5.5 · one generation per arm · same prompt and constraints · unedited iPhone 17 / iOS 27 simulator screenshots"
import os
note = os.environ.get("GALLERY_NOTE")
IDS = "home settings paywall onboarding detail list stats auth".split()


def font(size, bold=False):
    return ImageFont.truetype(FONT, size, index=1 if bold else 0)


def phone(path, h):
    im = Image.open(path).convert("RGB")
    w = round(im.width * h / im.height)
    im = im.resize((w, h), Image.LANCZOS)
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w - 1, h - 1), radius=round(h * 0.055), fill=255)
    out = Image.new("RGBA", im.size)
    out.paste(im, (0, 0), mask)
    return out


def fit_text(d, xy, text, size, max_w, fill, bold=False):
    """Draw text, shrinking it until it fits max_w."""
    while size > 12 and d.textlength(text, font=font(size, bold)) > max_w:
        size -= 1
    d.text(xy, text, font=font(size, bold), fill=fill)


def card(sheet, img, x, y):
    # hairline frame so light screenshots separate from the canvas
    d = ImageDraw.Draw(sheet)
    d.rounded_rectangle((x - 2, y - 2, x + img.width + 1, y + img.height + 1), radius=round(img.height * 0.056), outline=RULE, width=2)
    sheet.paste(img, (x, y), img)


def hero(out, prompt, *shots):
    H, gap, group_gap, M = 1000, 36, 120, 110
    phones = [phone(p, H) for p in shots]
    pw = phones[0].width
    W = M * 2 + 3 * (2 * pw + gap) + 2 * group_gap
    top, Ht = 250, 250 + H + 230
    sheet = Image.new("RGB", (W, Ht), CANVAS)
    d = ImageDraw.Draw(sheet)
    fit_text(d, (M, 70), "Same prompt, same model. Left: without the pack. Right: with it.", 64, W - 2 * M, INK, True)
    d.text((M, 160), "“%s”" % prompt, font=font(44), fill=INK2)
    x = M
    for i, name in enumerate(("SwiftUI", "React Native", "Flutter")):
        a, b = phones[2 * i], phones[2 * i + 1]
        card(sheet, a, x, top)
        card(sheet, b, x + pw + gap, top)
        d.text((x, top + H + 34), name, font=font(46, True), fill=INK)
        d.text((x, top + H + 96), "without", font=font(36), fill=INK2)
        d.text((x + pw + gap, top + H + 96), "with mobile-ui", font=font(36, True), fill=INK)
        x += 2 * pw + gap + group_gap
    fit_text(d, (M, Ht - 66), note or MODEL_LINE, 32, W - 2 * M, INK2)
    sheet.save(out, optimize=True)


def platform(out, name, prompt, *shots):
    H, gap, M, label_w = 874, 40, 90, 300
    phones = [phone(p, H) for p in shots]
    pw = phones[0].width
    W = M * 2 + label_w + 3 * pw + 2 * gap
    top = 270
    Ht = top + 2 * H + gap + 60 + 120
    sheet = Image.new("RGB", (W, Ht), CANVAS)
    d = ImageDraw.Draw(sheet)
    fit_text(d, (M, 64), "%s: without and with the mobile-ui pack" % name, 58, W - 2 * M, INK, True)
    d.text((M, 148), "“%s”" % prompt, font=font(40), fill=INK2)
    for c, col in enumerate(("Light", "Dark", "Largest accessibility text")):
        d.text((M + label_w + c * (pw + gap), top - 58), col, font=font(34), fill=INK2)
    for r, row in enumerate(("Without", "With pack")):
        y = top + r * (H + gap)
        d.text((M, y + H // 2 - 30), row, font=font(48, True), fill=INK if r else INK2)
        for c in range(3):
            card(sheet, phones[r * 3 + c], M + label_w + c * (pw + gap), y)
    fit_text(d, (M, Ht - 80), note or MODEL_LINE, 30, W - 2 * M, INK2)
    sheet.save(out, optimize=True)


def sheet(out, name, base_pat, pack_pat):
    H, gap, M, label_w = 600, 28, 80, 260
    pw = phone(base_pat.format(id=IDS[0]), H).width
    W = M * 2 + label_w + len(IDS) * pw + (len(IDS) - 1) * gap
    top = 220
    Ht = top + 2 * H + gap + 70 + 110
    s = Image.new("RGB", (W, Ht), CANVAS)
    d = ImageDraw.Draw(s)
    fit_text(d, (M, 60), "%s: all 8 eval prompts, light mode, not cherry-picked" % name, 56, W - 2 * M, INK, True)
    for i, id_ in enumerate(IDS):
        d.text((M + label_w + i * (pw + gap), top - 54), id_, font=font(32), fill=INK2)
    for r, (row, pat) in enumerate((("Without", base_pat), ("With pack", pack_pat))):
        y = top + r * (H + gap)
        d.text((M, y + H // 2 - 28), row, font=font(44, True), fill=INK if r else INK2)
        for i, id_ in enumerate(IDS):
            card(s, phone(pat.format(id=id_), H), M + label_w + i * (pw + gap), y)
    fit_text(d, (M, Ht - 74), note or MODEL_LINE, 28, W - 2 * M, INK2)
    s.save(out, optimize=True)


if __name__ == "__main__":
    cmd, out, *rest = sys.argv[1:]
    {"hero": hero, "platform": platform, "sheet": sheet}[cmd](out, *rest)
