import sys
from PIL import Image, ImageStat
im = Image.open(sys.argv[1]).convert("L")
w, h = im.size
body = im.crop((0, int(h * 0.12), w, int(h * 0.95)))   # ignore status bar
print("blank" if ImageStat.Stat(body).stddev[0] < 6 else "ok")
