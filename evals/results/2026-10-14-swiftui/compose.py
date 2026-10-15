import json, os, random, sys
from PIL import Image, ImageDraw, ImageFont
E = os.path.dirname(os.path.abspath(__file__))
IDS = "home settings paywall onboarding detail list stats auth".split()
random.seed(int(sys.argv[1]) if len(sys.argv) > 1 else 7)
os.makedirs(f"{E}/pairs", exist_ok=True)
key = {}
try:
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 64)
except Exception:
    font = ImageFont.load_default()
def row(arm, id_):
    ims = []
    for v in ("light", "dark", "axl"):
        p = f"{E}/shots/{arm}/{id_}-{v}.png"
        ims.append(Image.open(p).convert("RGB").resize((402, 874)) if os.path.exists(p) else Image.new("RGB", (402, 874), (255, 0, 255)))
    return ims
for id_ in IDS:
    first = random.choice(["base", "pack"]); second = "pack" if first == "base" else "base"
    for order, (a, b) in (("1", (first, second)), ("2", (second, first))):
        W, H = 402 * 3 + 40 * 4 + 120, 874 * 2 + 40 * 3
        sheet = Image.new("RGB", (W, H), (210, 210, 210)); d = ImageDraw.Draw(sheet)
        for r, (label, arm) in enumerate((("A", a), ("B", b))):
            y = 40 + r * (874 + 40)
            d.text((30, y + 400), label, fill=(0, 0, 0), font=font)
            for c, im in enumerate(row(arm, id_)):
                sheet.paste(im, (120 + 40 + c * (402 + 40), y))
        sheet.save(f"{E}/pairs/{id_}_{order}.png")
        key[f"{id_}_{order}"] = {"A": a, "B": b}
json.dump(key, open(f"{E}/KEY_do_not_show_judges.json", "w"), indent=1)
print("composed", len(key))
