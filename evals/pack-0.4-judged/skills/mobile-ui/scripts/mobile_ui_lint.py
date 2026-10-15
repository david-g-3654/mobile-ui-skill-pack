#!/usr/bin/env python3
"""mobile_ui_lint — catch the "generic screen" tells in SwiftUI, React Native and Flutter code.

Static, regex-based, dependency-free. It cannot judge taste; it catches the mechanical
mistakes that make agent-built screens look templated (raw colors, default-blue brands,
flat type scales, card soup, placeholder content, fake chrome, missing labels).

Usage:
    python3 scripts/mobile_ui_lint.py <file-or-dir> [...] [--json] [--strict] [--quiet]

Exit code: 1 if any `error` (or any `warning` with --strict), else 0.
Rules are documented in skills/mobile-ui/references/lint.md.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, asdict

EXTS = {".swift": "swift", ".tsx": "rn", ".jsx": "rn", ".ts": "rn", ".js": "rn", ".dart": "flutter"}
SKIP_DIRS = {"node_modules", ".git", "build", "Pods", ".dart_tool", "ios", "android", "DerivedData", ".expo", "dist"}
TOKEN_FILE = re.compile(r"(^|/)(theme|tokens?|design[_-]?system|designsystem|colors?|palette|styles?/tokens)[^/]*\.(swift|tsx?|jsx?|dart)$", re.I)
TOKEN_MARKER = "mobile-ui: tokens"
# Product/data colors (a shoe colorway, a chart series, a user-picked label color) are content, not UI.
# Mark the line with this comment and MU001 skips it.
CONTENT_COLOR = "mobile-ui: content-color"
TEST_FILE = re.compile(r"(\.test\.|\.spec\.|_test\.dart$|Tests?\.swift$|/__tests__/)")

EMOJI = re.compile(
    "[\U0001F300-\U0001FAFF\U00002600-\U000026FF\U00002700-\U00002712\U00002715-\U000027BF\U0001F000-\U0001F2FF\U00002B50\U00002B55\U000023E9-\U000023FA\U0000231A\U0000231B]"
)


@dataclass
class Finding:
    file: str
    line: int
    rule: str
    severity: str  # error | warning | info
    message: str
    fix: str


def strip_comments(lines: list[str]) -> list[str]:
    """Blank out // line comments and /* */ block comments, preserving line count."""
    out, in_block = [], False
    for raw in lines:
        line, i, buf, in_str = raw, 0, [], None
        while i < len(line):
            ch, nxt = line[i], line[i + 1] if i + 1 < len(line) else ""
            if in_block:
                if ch == "*" and nxt == "/":
                    in_block = False
                    i += 2
                    continue
                i += 1
                continue
            if in_str:
                buf.append(ch)
                if ch == "\\":
                    buf.append(nxt)
                    i += 2
                    continue
                if ch == in_str:
                    in_str = None
                i += 1
                continue
            if ch in "\"'`":
                in_str = ch
                buf.append(ch)
                i += 1
                continue
            if ch == "/" and nxt == "/":
                break
            if ch == "/" and nxt == "*":
                in_block = True
                i += 2
                continue
            buf.append(ch)
            i += 1
        out.append("".join(buf))
    return out


def string_literals(line: str) -> list[str]:
    found = re.findall(r'"((?:[^"\\]|\\.)*)"', line) + re.findall(r"'((?:[^'\\]|\\.)*)'", line) + re.findall(r"`((?:[^`\\]|\\.)*)`", line)
    # JSX text children: <Text>Jane Smith</Text>
    found += [t.strip() for t in re.findall(r">([^<>{}]+)</", line) if t.strip()]
    return found


class Linter:
    def __init__(self) -> None:
        self.findings: list[Finding] = []

    def add(self, f: str, ln: int, rule: str, sev: str, msg: str, fix: str) -> None:
        self.findings.append(Finding(f, ln, rule, sev, msg, fix))

    # ── per file ────────────────────────────────────────────────────
    def lint_file(self, path: str) -> None:
        ext = os.path.splitext(path)[1]
        plat = EXTS.get(ext)
        if not plat:
            return
        try:
            with open(path, encoding="utf-8") as fh:
                raw = fh.read()
        except (UnicodeDecodeError, OSError):
            return
        if plat == "rn" and ext in (".ts", ".js") and "react-native" not in raw and "StyleSheet" not in raw:
            return  # plain logic file
        if TEST_FILE.search(path.replace(os.sep, "/")):
            return
        is_tokens = bool(TOKEN_FILE.search(path.replace(os.sep, "/"))) or TOKEN_MARKER in raw
        lines = raw.splitlines()
        code = strip_comments(lines)
        getattr(self, f"_lint_{plat}")(path, lines, code, is_tokens)
        self._lint_common(path, lines, code, is_tokens, plat)

    # ── shared rules ────────────────────────────────────────────────
    def _lint_common(self, f, lines, code, is_tokens, plat):
        bold_lines, shadow_lines, sizes = [], [], {}
        for i, line in enumerate(code, 1):
            low = line.lower()
            # MU002 default-brand colors (even in token files: that's the point)
            if re.search(r"#(007AFF|6200EE|6750A4|6366F1|3F51B5|2196F3)\b", line, re.I) or re.search(
                r"\b(Color\.blue|Colors\.(blue|deepPurple|indigo|purple)(Accent)?\b|\.systemBlue\b|UIColor\.blue\b)", line
            ):
                self.add(f, i, "MU002", "error", "Default platform/template blue or purple used as a brand color.",
                         "Use ink for primary actions and one considered accent (Palette.accent / c.accent / context.q.accent).")
            # MU004 placeholder content
            for s in string_literals(line):
                sl = s.lower()
                if "lorem ipsum" in sl or re.search(r"\b(john|jane) (doe|smith)\b", sl):
                    self.add(f, i, "MU004", "error", f'Placeholder content: "{s[:40]}".',
                             "Write realistic, varied sample data (see mobile-ui/references/copy.md).")
                elif re.fullmatch(r"(Item|User|Title|Label|Product|Name|Card|Row) \d+|Subtitle", s.strip()):
                    self.add(f, i, "MU004", "warning", f'Generic placeholder string "{s}".',
                             "Use domain-true sample content.")
                # MU005 emoji in UI strings
                if EMOJI.search(s) and not is_tokens:
                    self.add(f, i, "MU005", "warning", f'Emoji in a UI string ("{s[:30]}") — emoji used as icons reads as generic.',
                             "Use one icon family (SF Symbols / Ionicons / Material Symbols); keep emoji for user content only.")
            # MU003 gradients
            if not is_tokens and re.search(r"\bLinearGradient\b|linear-gradient", line):
                near = " ".join(code[max(0, i - 6): i + 6])
                if re.search(r"Button|Pressable|Touchable|onPress|onTap|CTA", near):
                    self.add(f, i, "MU003", "warning", "Gradient near a button — gradient CTAs are a top generic tell.",
                             "Solid primaryFill. Gradients only as subtle image-like backdrops on onboarding/paywall heroes.")
            # MU102 bold
            if re.search(r"\.bold\b|fontWeight:\s*['\"]?(bold|700|800|900)['\"]?|FontWeight\.(bold|w700|w800|w900)|\.heavy\b|\.black\b(?!\))", line):
                if not is_tokens:
                    bold_lines.append(i)
            # MU103 shadows
            if not is_tokens and re.search(r"\.shadow\(|shadowOpacity|BoxShadow\(|elevation:\s*[1-9]", line):
                shadow_lines.append(i)
            # MU101 raw font sizes
            if not is_tokens:
                for m in re.finditer(r"(?:\.system\(size:\s*|fontSize:\s*)(\d+(?:\.\d+)?)", line):
                    sizes.setdefault(m.group(1), i)
            # MU111 disabled text scaling
            if re.search(r"allowFontScaling=\{false\}|TextScaler\.noScaling|textScaleFactor:\s*1(\.0)?\b|\.dynamicTypeSize\(\.(xSmall|small|medium|large)\)", line):
                self.add(f, i, "MU111", "error", "Text scaling disabled — breaks Dynamic Type / font scale.",
                         "Let text scale; cap only space-critical chrome (maxFontSizeMultiplier / .dynamicTypeSize(...accessibility2)).")
            # MU113 hard-coded safe areas
            if re.search(r"(paddingTop|marginTop|top):\s*(44|47|48|50|54|59)\b|(paddingBottom|marginBottom|bottom):\s*34\b|\.padding\(\.(top|bottom),\s*(34|44|47|59)\)", line):
                self.add(f, i, "MU113", "warning", "Hard-coded status bar / home indicator inset.",
                         "Use safe-area insets (safeAreaInset / useSafeAreaInsets / SafeArea).")
            # MU115 bottom bar drawn over scroll content instead of insetting it
            if not is_tokens and re.search(r"\.overlay\(alignment:\s*\.bottom\)|ZStack\(alignment:\s*\.bottom\)|position:\s*['\"]absolute['\"][^}]*bottom:\s*0|Positioned\([^)]*bottom:\s*0", line):
                near = " ".join(code[max(0, i - 2): i + 8])
                if re.search(r"Button|Pressable|onPress|onTap|ElevatedButton|FilledButton|PrimaryButton", near):
                    self.add(f, i, "MU115", "warning", "Bottom action bar overlaid on content — the last items hide underneath and it can't unpin at large text.",
                             "Inset instead: .safeAreaInset / .qBottomActionBar (SwiftUI), a sibling <QBottomActionBar> (RN), Scaffold.bottomNavigationBar (Flutter).")
            # MU109 hamburger
            if re.search(r"line\.3\.horizontal|name=['\"]menu(-outline)?['\"]|Icons\.menu\b|\bDrawer\(", line):
                self.add(f, i, "MU109", "warning", "Hamburger/drawer navigation.",
                         "Use a tab bar for 3–5 top-level destinations.")
        if not is_tokens:
            joined = "\n".join(code)
            hand_typed = re.search(r"[\"'`]\s*[-−+]?\\?\$\d|[\"'`]\\?\$[\"'`]", joined)
            formatted = re.search(r"US\$|\.currency\(|NumberFormat\.(simpleC|c)urrency|Intl\.NumberFormat|style:\s*['\"]currency", joined)
            if hand_typed and formatted:
                ln = joined[:hand_typed.start()].count("\n") + 1
                self.add(f, ln, "MU117", "warning", "Mixed money formats in one screen (hand-typed \"$12\" alongside a currency formatter / \"US$\").",
                         "Format every amount with the same formatter (copy.md: one format per screen).")
        if len(bold_lines) > 3:
            self.add(f, bold_lines[3], "MU102", "warning", f"{len(bold_lines)} bold/heavy weights in one file — flat, shouty hierarchy.",
                     "Two weights: semibold for titles, regular for the rest; bold only for large titles.")
        if len(shadow_lines) > 2:
            self.add(f, shadow_lines[2], "MU103", "warning", f"{len(shadow_lines)} shadows/elevations — card soup.",
                     "Separate with canvas vs surface and space; shadows only on floating elements.")
        if sizes:
            first = min(sizes.values())
            self.add(f, first, "MU101", "warning", f"Raw font sizes in screen code ({', '.join(sorted(sizes, key=float))}).",
                     "Use the type ramp (dsHeadline / type.headline / context.qText.titleMedium).")
            if len(sizes) > 5:
                self.add(f, first, "MU100", "error", f"{len(sizes)} distinct font sizes — no hierarchy.",
                         "Max 4 text styles + one hero per screen.")
        # MU104 off-grid spacing
        if not is_tokens:
            pat = {
                "swift": r"\.padding\((?:\.[a-z]+,\s*)?(\d+(?:\.\d+)?)\)|spacing:\s*(\d+(?:\.\d+)?)",
                "rn": r"(?:padding|margin|gap|rowGap|columnGap)(?:Horizontal|Vertical|Top|Bottom|Left|Right)?:\s*(\d+(?:\.\d+)?)",
                "flutter": r"EdgeInsets\.(?:all|symmetric|only|fromLTRB)\(([^)]*)\)|SizedBox\((?:height|width):\s*(\d+(?:\.\d+)?)\)",
            }[plat]
            for i, line in enumerate(code, 1):
                for m in re.finditer(pat, line):
                    nums = re.findall(r"(?<![\w.])(\d+(?:\.\d+)?)(?![\w.])", " ".join(g for g in m.groups() if g))
                    bad = [n for n in nums if float(n) not in (0, 0.5, 1, 2) and float(n) % 4 != 0]
                    if bad:
                        self.add(f, i, "MU104", "warning", f"Off-grid spacing value(s) {', '.join(bad)}.",
                                 "Use 4pt-grid tokens (Space.* / space.*).")

    # ── SwiftUI ─────────────────────────────────────────────────────
    def _lint_swift(self, f, lines, code, is_tokens):
        text = "\n".join(code)
        has_nav = re.search(r"\.navigationTitle|NavigationStack|NavigationView|\.toolbar", text)
        for i, line in enumerate(code, 1):
            if re.search(r"\.fixedSize\(\)", line):
                self.add(f, i, "MU116", "warning", "Bare .fixedSize() pins a view to its one-line width — at accessibility sizes it widens the whole screen and clips both edges.",
                         "Use .fixedSize(horizontal: false, vertical: true) for text; give buttons a max width instead.")
            if not is_tokens and CONTENT_COLOR not in lines[i - 1] and re.search(r"Color\((red|hex|white:)|UIColor\((red|hex)|Color\(\s*\"#|Color\.(red|green|orange|yellow|pink|purple|gray|grey|black|white)\b|\.foregroundColor\(\.gray\)", line):
                self.add(f, i, "MU001", "error", "Raw color in a screen.", "Use a Palette role (Palette.ink2, Palette.surface …).")
            if re.search(r"Image\(systemName:\s*\"chevron\.(left|backward)\"", line) and not has_nav:
                self.add(f, i, "MU105", "warning", "Hand-drawn back chevron without NavigationStack — fake navigation bar.",
                         "Use NavigationStack + .navigationTitle; the system provides back + swipe.")
            if re.search(r"^\s*ProgressView\(\)\s*$", line):
                near = " ".join(code[max(0, i - 3): i + 2])
                if "Spacer" in near or ".frame(maxWidth: .infinity, maxHeight: .infinity" in near:
                    self.add(f, i, "MU106", "warning", "Full-screen spinner.", "Use .redacted(reason: .placeholder) on the real layout.")
            if re.search(r"label:\s*\{\s*(Image\(systemName:.*)?$", line) or re.search(r"Button\((action:[^)]*)?\)\s*\{\s*$", line):
                body = " ".join(code[i - 1: i + 4])
                window = " ".join(code[i - 1: i + 9])
                if "Image(systemName:" in body and "Text(" not in body and "Label(" not in body and "accessibilityLabel" not in window:
                    self.add(f, i, "MU107", "error", "Icon-only button without an accessibility label.",
                             'Add .accessibilityLabel("Verb object").')

    # ── React Native ────────────────────────────────────────────────
    def _lint_rn(self, f, lines, code, is_tokens):
        for i, line in enumerate(code, 1):
            if not is_tokens and CONTENT_COLOR not in lines[i - 1] and re.search(r"['\"](#[0-9A-Fa-f]{3,8}|rgba?\([^)]*\))['\"]|(color|backgroundColor|borderColor|tintColor)\s*[:=]\s*['\"](white|black|gray|grey|red|blue|green)['\"]", line):
                self.add(f, i, "MU001", "error", "Raw color in a screen.", "Use theme roles: const { c } = useQTheme(); c.ink2 …")
            if re.search(r"<Text[^>]*>\s*(\{['\"])?(<|‹|←)\s*(Back)?", line):
                self.add(f, i, "MU105", "warning", "Text back arrow — fake navigation header.",
                         "Use native-stack / Expo Router Stack headers.")
            if re.search(r"<ActivityIndicator[^>]*size=['\"]large['\"]", line):
                self.add(f, i, "MU106", "warning", "Large spinner — likely a full-screen loader.", "Use skeleton rows in the final layout.")
            if "<TouchableOpacity" in line:
                self.add(f, i, "MU112", "info", "TouchableOpacity.", "Prefer Pressable with an explicit pressed style.")
            m = re.search(r"<(Pressable|TouchableOpacity|TouchableHighlight)\b", line)
            if m:
                window = "\n".join(code[i - 1: i + 10])
                end = window.find(f"</{m.group(1)}>")
                block = window[: end if end > 0 else len(window)]
                if re.search(r"<(Ionicons|Icon|MaterialIcons|Feather|[A-Z]\w*Icon)\b", block) and "<Text" not in block and "<Txt" not in block and "accessibilityLabel" not in block and "aria-label" not in block:
                    self.add(f, i, "MU107", "error", "Icon-only pressable without accessibilityLabel.",
                             'Add accessibilityLabel="Verb object" and accessibilityRole="button".')
            if re.search(r"<TextInput\b", line):
                window = " ".join(code[i - 1: i + 8])
                if "placeholder" in window and "accessibilityLabel" not in window and "label=" not in window:
                    prev = " ".join(code[max(0, i - 3): i - 1])
                    if "<Text" not in prev and "<Txt" not in prev:
                        self.add(f, i, "MU114", "warning", "TextInput with a placeholder but no visible label.",
                                 "Put a label above the field; placeholders are examples, not labels.")

    # ── Flutter ─────────────────────────────────────────────────────
    def _lint_flutter(self, f, lines, code, is_tokens):
        text = "\n".join(code)
        for i, line in enumerate(code, 1):
            if not is_tokens and CONTENT_COLOR not in lines[i - 1] and re.search(r"\bColor\(0x[0-9A-Fa-f]{8}\)|Color\.fromARGB|Color\.fromRGBO|\bColors\.(?!transparent\b)[a-z]\w*", line):
                self.add(f, i, "MU001", "error", "Raw color in a widget.", "Use context.q.<role>.")
            if re.search(r"ColorScheme\.fromSeed\(", line):
                self.add(f, i, "MU002", "warning", "ColorScheme.fromSeed — tinted Material defaults read as generic.",
                         "Build the scheme from Quiet roles (quietTheme) or map the brand explicitly.")
            if re.search(r"Center\(\s*child:\s*CircularProgressIndicator", line):
                self.add(f, i, "MU106", "warning", "Full-screen spinner.", "Use SkeletonRow()s in the final layout.")
            if re.search(r"\bFloatingActionButton(\.extended)?\(", line):
                self.add(f, i, "MU109", "info", "FloatingActionButton — wrong on iOS.", "Use an app-bar + action on iOS (or adaptive).")
            if re.search(r"\bIconButton\(", line):
                window = " ".join(code[i - 1: i + 8])
                if "tooltip:" not in window and "Semantics(" not in " ".join(code[max(0, i - 3): i]):
                    self.add(f, i, "MU107", "error", "IconButton without tooltip (its accessibility label).",
                             "Add tooltip: 'Verb object'.")
            if re.search(r"\bCard\(", line) and "elevation: 0" not in " ".join(code[i - 1: i + 4]):
                self.add(f, i, "MU103", "info", "Material Card (adds tint + shadow).", "Use ObjectCard, or GroupedSection for lists.")
            if re.search(r"Icons\.arrow_back(_ios)?\b", line) and "AppBar" not in text and "SliverAppBar" not in text:
                self.add(f, i, "MU105", "warning", "Hand-drawn back arrow without an AppBar — fake navigation bar.",
                         "Use AppBar/SliverAppBar (automatic back + predictive back).")


def walk(paths: list[str]):
    for p in paths:
        if os.path.isfile(p):
            yield p
            continue
        for root, dirs, files in os.walk(p):
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not d.startswith(".")]
            for name in sorted(files):
                if os.path.splitext(name)[1] in EXTS:
                    yield os.path.join(root, name)


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("paths", nargs="+")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    ap.add_argument("--strict", action="store_true", help="warnings also fail")
    ap.add_argument("--quiet", action="store_true", help="hide info findings")
    args = ap.parse_args(argv)

    linter = Linter()
    files = list(walk(args.paths))
    for path in files:
        linter.lint_file(path)
    findings = [x for x in linter.findings if not (args.quiet and x.severity == "info")]
    findings.sort(key=lambda x: (x.file, x.line, x.rule))

    errors = sum(x.severity == "error" for x in findings)
    warnings = sum(x.severity == "warning" for x in findings)
    if args.json:
        print(json.dumps({"files": len(files), "errors": errors, "warnings": warnings,
                          "findings": [asdict(x) for x in findings]}, indent=2))
    else:
        icon = {"error": "✖", "warning": "▲", "info": "·"}
        for x in findings:
            print(f"{x.file}:{x.line}  {icon[x.severity]} {x.rule} {x.message}\n    → {x.fix}")
        print(f"\n{len(files)} file(s) · {errors} error(s) · {warnings} warning(s)")
    return 1 if errors or (args.strict and warnings) else 0


if __name__ == "__main__":
    sys.exit(main())
