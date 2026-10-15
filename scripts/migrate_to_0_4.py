#!/usr/bin/env python3
"""Migrate your app code from mobile-ui 0.3 to 0.4 (Q-prefixed API).

  python3 scripts/migrate_to_0_4.py swift path/to/Sources [--write]
  python3 scripts/migrate_to_0_4.py dart  lib/            [--write]
  python3 scripts/migrate_to_0_4.py rn    app/ components/ [--write]

Without --write it prints which files would change. It renames only the pack's own symbols, and only
where they aren't member accesses (Stack.Screen, Theme.of… are left alone). If your app defines its own
type with the same name as an old pack symbol (the reason for this release), review those files by hand.
Python 3 standard library only.
"""
import os, re, sys

def q(n): return "Q" + n
SPECIAL = {"Txt": "QText", "QuietBadge": "QBadge", "QuietChip": "QChip",
           "useTheme": "useQTheme", "useLargeText": "useQLargeText", "isLargeText": "qIsLargeText"}

SWIFT_TYPES = "Metrics Motion Palette Radius Space Typeface Avatar Badge BottomActionBarModifier Chip EmptyState HeroMetric HeroText LargeTextFooter ListRow MetricRow ObjectCard PlanCard PrimaryButton PrimaryButtonStyle ProgressRing SecondaryButtonStyle SectionHeader Shimmer Swatch TertiaryButtonStyle Toast".split()
SWIFT_FUNCS = "bottomActionBar canvasBackground surfaceRow overlineStyle shimmering toast".split()
DART_TYPES = "Avatar BottomActionBar Delta DisplayScale EmptyState GroupedSection HeroMetric LargeTextFooter ListRow MetricRow Metrics Motion ObjectCard PlanCard PrimaryButton ProgressRing QuietBadge QuietChip Radii RowKind SecondaryButton SectionHeader Skeleton SkeletonRow Space Swatch TertiaryButton ToggleRow isLargeText".split()
RN_TYPES = "Palette Theme useTheme useLargeText Txt Screen PrimaryButton SecondaryButton TertiaryButton IconButton BottomActionBar LargeTextFooter SectionHeader GroupedSection ListRow ToggleRow HeroMetric MetricRow ObjectCard Segmented TextField Swatch Chip Avatar Badge ProgressBar PlanCard EmptyState Skeleton SkeletonRow Toast".split()

def new(n): return SPECIAL.get(n, q(n))

def code_sub(text, names, platform):
    for n in sorted(names, key=len, reverse=True):
        # never touch member access like Stack.Screen / Theme.of / Colors.x, or already-prefixed names
        pat = r"(?<![.\w])" + re.escape(n) + r"\b"
        text = re.sub(pat, new(n), text)
    if platform == "swift":
        for f in SWIFT_FUNCS:
            text = re.sub(r"(\.|func )" + f + r"\b", lambda m: m.group(1) + "q" + f[0].upper() + f[1:], text)
        text = re.sub(r"\.buttonStyle\(\.(primary|secondary|tertiary)\)", lambda m: ".buttonStyle(.q" + m.group(1).capitalize() + ")", text)
        text = re.sub(r"static var (primary|secondary|tertiary): (Q\w+ButtonStyle)", lambda m: "static var q" + m.group(1).capitalize() + ": " + m.group(2), text)
        text = re.sub(r"(Color\.|static func )adaptive\(", lambda m: m.group(1) + "qAdaptive(", text)
    if platform == "dart":
        text = re.sub(r"\b(context|ctx|c)\.t\.", r"\1.qText.", text)
        text = re.sub(r"TextTheme get t =>", "TextTheme get qText =>", text)
    return text

def prose_names(names):  # CamelCase with 2+ capitals, or explicit hooks: safe to replace in prose
    return [n for n in names if len(re.findall(r"[A-Z]", n)) >= 2 or n.startswith(("use", "is"))]

def md_sub(text, names, platform):
    out = []
    for i, block in enumerate(re.split(r"(```.*?```)", text, flags=re.S)):
        if i % 2:  # fenced code
            out.append(code_sub(block, names, platform)); continue
        parts = re.split(r"(`[^`\n]+`)", block)
        for j, p in enumerate(parts):
            if j % 2: parts[j] = code_sub(p, names, platform)
            else:
                for n in sorted(prose_names(names), key=len, reverse=True):
                    p = re.sub(r"(?<![.\w])" + re.escape(n) + r"\b", new(n), p)
                parts[j] = p
        out.append("".join(parts))
    return "".join(out)


EXT = {"swift": (".swift",), "dart": (".dart",), "rn": (".ts", ".tsx", ".js", ".jsx")}
NAMES = {"swift": SWIFT_TYPES, "dart": DART_TYPES, "rn": RN_TYPES}

def main(argv):
    if len(argv) < 2 or argv[0] not in EXT:
        sys.exit(__doc__)
    platform, paths, write = argv[0], [a for a in argv[1:] if a != "--write"], "--write" in argv
    changed = 0
    for root in paths:
        files = [root] if os.path.isfile(root) else [os.path.join(dp, f) for dp, _, fs in os.walk(root) for f in fs]
        for f in files:
            if not f.endswith(EXT[platform]) or "node_modules" in f:
                continue
            s = open(f).read()
            t = code_sub(s, NAMES[platform], "swift" if platform == "swift" else platform)
            if t != s:
                changed += 1
                print(("updated " if write else "would update ") + f)
                if write:
                    open(f, "w").write(t)
    print("%d file(s) %s" % (changed, "updated" if write else "need changes (rerun with --write)"))

if __name__ == "__main__":
    main(sys.argv[1:])
