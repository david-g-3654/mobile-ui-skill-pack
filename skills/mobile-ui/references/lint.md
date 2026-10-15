# Lint — `scripts/mobile_ui_lint.py`

The script lives in this skill's `scripts/` directory (paths below are relative to the `mobile-ui` skill root). Python 3 standard library only, no install.

A dependency-free static check for the mechanical "generic screen" tells across SwiftUI (`.swift`), React Native (`.tsx/.jsx/.ts/.js`), and Flutter (`.dart`). It cannot judge taste — the taste gate in `SKILL.md §8` does that — but it reliably catches what agents get wrong most often.

```bash
python3 scripts/mobile_ui_lint.py app/ src/screens/     # human output
python3 scripts/mobile_ui_lint.py lib/ --json            # machine output
python3 scripts/mobile_ui_lint.py Sources/ --strict      # warnings fail too
```

Exit code 1 on any `error` (or `warning` with `--strict`). Token files (`theme.*`, `tokens.*`, `DesignSystem.swift`, `colors.*`, `palette.*`, or any file containing the comment `mobile-ui: tokens`) are allowed to hold raw values. Test files are skipped. Product/data colors (a colorway swatch, a chart series) are content, not UI: mark the line with `// mobile-ui: content-color` and MU001 skips it.

## Rules

| ID | Severity | Catches | Fix |
|---|---|---|---|
| MU001 | error | Raw colors in screens (`Color(red:)`, `'#333'`, `Colors.grey`, `Color(0xFF…)`) | Color roles from the token file |
| MU002 | error | Default blue/purple brand (`#007AFF`, `#6200EE`, `#6750A4`, `#6366F1`, `Color.blue`, `Colors.deepPurple`, `fromSeed`) | Ink primary + one considered accent |
| MU003 | warning | Gradient near a button | Solid `primaryFill` |
| MU004 | error / warning | Lorem ipsum, John/Jane Doe/Smith (error); "Item 1", "User 2", "Subtitle" (warning; plain labels like "Name" are fine) | Realistic sample data (`copy.md`) |
| MU005 | warning | Emoji inside UI strings | One icon family |
| MU100 | error | > 5 distinct raw font sizes in a file | ≤ 4 styles + hero |
| MU101 | warning | Any raw font size in screen code | Type ramp tokens |
| MU102 | warning | > 3 bold/heavy weights in a file | Two weights |
| MU103 | warning / info | > 2 shadows/elevations (card soup); Material `Card` | Canvas vs surface + space |
| MU104 | warning | Off-grid spacing (not 0, 1, 2 or a multiple of 4) | `Space.*` tokens |
| MU105 | warning | Hand-drawn back chevron / "‹ Back" text without native nav | Native navigation |
| MU106 | warning | Full-screen spinner | Skeleton in final layout |
| MU107 | error | Icon-only button without accessibility label / tooltip | Label "Verb object" |
| MU109 | warning / info | Hamburger / drawer navigation; FAB (Flutter) | Tab bar; nav-bar `+` |
| MU111 | error | Text scaling disabled | Let text scale |
| MU112 | info | `TouchableOpacity` | `Pressable` + pressed style |
| MU113 | warning | Hard-coded safe-area insets (44/47/59 top, 34 bottom) | Safe-area APIs |
| MU114 | warning | `TextInput` with placeholder and no visible label | Label above the field |
| MU116 | warning | Bare `.fixedSize()` (SwiftUI) — widens the screen at accessibility sizes | `.fixedSize(horizontal: false, vertical: true)` |
| MU117 | warning | Mixed money formats in one file (`"$12"` next to a currency formatter or `US$`) | One formatter per screen |
| MU118 | error / warning | React Native: `Intl` APIs Hermes on iOS doesn't have (`NumberFormat#formatToParts`, `formatRange`, `Intl.RelativeTimeFormat`/`PluralRules`/`ListFormat`/`DisplayNames`/`Segmenter`/`Locale`/`DurationFormat`) or gets wrong (`style: 'unit'` converts km to miles) — error; `notation: 'compact'`, `signDisplay` are ignored, and an untyped `.formatToParts` might be a NumberFormat — warning | `format()` + string ops (`mobile-ui-react-native` → Money and numbers on Hermes) |
| MU115 | warning | Bottom bar with a button overlaid on content (`.overlay(alignment: .bottom)`, `ZStack(alignment: .bottom)`, absolute `bottom: 0`, `Positioned(bottom: 0)`) | Inset the content; pin with the pack's bottom action bar |

## How agents should use it

1. Run it on every file you created or restyled before handing off.
2. Fix every `error`. Fix `warning`s unless you can state why the rule doesn't apply (e.g. a 6pt optical adjustment) — then say so in the hand-off.
3. A clean lint is necessary, not sufficient. Then run the taste gate.

## Tests

`python3 -m unittest discover -s scripts/tests` — asserts the pack's own assets are clean and that the generic fixtures in `scripts/tests/fixtures/generic/` (one per platform, written the way agents typically write screens) trigger the expected rules.
