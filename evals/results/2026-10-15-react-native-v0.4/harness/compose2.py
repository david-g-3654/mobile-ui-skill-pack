"""compose2.py <out_dir> <base_shots_dir> <pack_shots_dir> <seed> [name_pattern]
Blind A/B pair images (rows A/B; columns light, dark, AX) + a key file kept out of out_dir's judge copy.
name_pattern: how shots are named; '{id}-{v}' (default) or '{arm}-{id}-{v}'."""
import json, os, random, sys
from PIL import Image, ImageDraw, ImageFont
out, bdir, pdir, seed = sys.argv[1:5]
pat = sys.argv[5] if len(sys.argv) > 5 else "{id}-{v}"
IDS = "home settings paywall onboarding detail list stats auth".split()
random.seed(int(seed)); os.makedirs(out, exist_ok=True)
font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 64)
def row(arm, id_):
    d = bdir if arm == "base" else pdir
    ims = []
    for v in ("light", "dark", "axl"):
        p = os.path.join(d, pat.format(arm=arm, id=id_, v=v) + ".png")
        ims.append(Image.open(p).convert("RGB").resize((402, 874)) if os.path.exists(p) else Image.new("RGB", (402, 874), (255, 0, 255)))
    return ims
key = {}
for id_ in IDS:
    first = random.choice(["base", "pack"]); second = "pack" if first == "base" else "base"
    for order, (a, b) in (("1", (first, second)), ("2", (second, first))):
        W, H = 402 * 3 + 40 * 4 + 120, 874 * 2 + 40 * 3
        sheet = Image.new("RGB", (W, H), (210, 210, 210)); dr = ImageDraw.Draw(sheet)
        for r, (label, arm) in enumerate((("A", a), ("B", b))):
            y = 40 + r * (874 + 40); dr.text((30, y + 400), label, fill=(0, 0, 0), font=font)
            for c, im in enumerate(row(arm, id_)): sheet.paste(im, (160 + c * (402 + 40), y))
        sheet.save(f"{out}/{id_}_{order}.png"); key[f"{id_}_{order}"] = {"A": a, "B": b}
json.dump(key, open(out + ".KEY.json", "w"), indent=1)
print("composed", len(key))
