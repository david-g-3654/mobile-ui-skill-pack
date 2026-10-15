# Style guide — the default "Quiet" skin

The pack ships one default skin, **Quiet**: warm off-white canvas, near-black ink, one tangerine accent used sparingly, ink-filled primary buttons, system type. It is deliberately restrained. A restrained default plus a strong hierarchy reads as designed; a loud default reads as a template.

When the project has its own tokens, **map them onto these roles** and ignore the values below. The *roles and rules* are the system; the hex values are a skin.

---

## Color roles

All values verified for contrast (WCAG 2.x) against `surface` and `canvas`.

### Light

| Role | Hex | Contrast on surface | Use |
|---|---|---|---|
| `canvas` | `#F5F5F2` | — | Screen background |
| `surface` | `#FFFFFF` | — | Grouped rows, sheets, object cards, inputs on canvas |
| `surface2` | `#EDEDEA` | — | Inputs/segmented tracks *on* surface, pressed state, skeleton base |
| `ink` | `#121212` | 18.7:1 | Primary text, primary glyphs |
| `ink2` | `#5E5E5B` | 6.5:1 | Secondary text (subtitles, metadata, row values) |
| `ink3` | `#9B9B97` | 2.8:1 | **Placeholder and disabled only.** Never information. |
| `hairline` | `#121212` @ 10% | — | Separators, input borders |
| `accent` | `#C2410C` | 5.2:1 | ≤2 elements/screen: selection, focal highlight, progress, links in body copy |
| `accentSoft` | `#C2410C` @ 10% | — | Selected chip/plan background, badge background |
| `primaryFill` | `#121212` | — | Primary button fill |
| `onPrimary` | `#FFFFFF` | 18.7:1 | Primary button label |
| `positive` | `#1E7F46` | 5.0:1 | Gains, success, "connected" |
| `negative` | `#C8312A` | 5.4:1 | Losses, errors, destructive actions |
| `warning` | `#9A5B00` | 5.4:1 | Warnings, "expiring" |

### Dark — designed, not inverted

| Role | Hex | Contrast on surface |
|---|---|---|
| `canvas` | `#111113` | — |
| `surface` | `#1E1E21` | — |
| `surface2` | `#2A2A2E` | — |
| `ink` | `#F4F4F2` | 15.1:1 |
| `ink2` | `#A3A3A0` | 6.6:1 |
| `ink3` | `#6E6E6B` | 3.3:1 (placeholder/disabled only) |
| `hairline` | `#FFFFFF` @ 10% | — |
| `accent` | `#FF6B35` | 5.9:1 |
| `accentSoft` | `#FF6B35` @ 16% | — |
| `primaryFill` | `#F4F4F2` | — |
| `onPrimary` | `#121212` | 15.1:1 |
| `positive` | `#3DD27A` | 8.5:1 |
| `negative` | `#FF6159` | 5.6:1 |
| `warning` | `#F5B342` | 9.0:1 |

Dark rules: elevation = a lighter surface (`canvas` → `surface` → `surface2`), never a shadow. Canvas is a lifted near-black, not `#000`: pure black makes full-bleed lists read flat and gives surfaces nowhere to step down to (eval finding). Content lists in dark mode sit on `surface` groups or get hairlines between rows. Accent gets brighter, not the same hex. Photos and illustrations may need a 4–8% dark scrim to sit in the UI.

### iOS note

On iOS you may bind roles to system semantic colors instead (`systemGroupedBackground` → `canvas`, `secondarySystemGroupedBackground` → `surface`, `label`/`secondaryLabel`/`tertiaryLabel` → `ink`/`ink2`/`ink3`, `separator` → `hairline`). This is the right choice for utility apps that should feel like part of iOS. Use the Quiet hexes when the app needs its own identity. Never mix the two within one app.

---

## Typography

### Families

| Platform | Default | Personality options (pick **one** per app, display sizes only) |
|---|---|---|
| iOS (SwiftUI) | SF Pro via `.font(.body)` etc. — **never import Inter on iOS** | `.serif` (New York) for editorial/journaling; `.rounded` for playful/health; `.monospaced` for data/dev/weather |
| React Native | System (`undefined` fontFamily → SF on iOS, Roboto on Android) | One brand display font loaded with `expo-font`, used for `hero`/`largeTitle`/`title` only |
| Flutter | Platform default via `Typography.material2021(platform:)` (SF on iOS, Roboto on Android) | Same as RN, via `google_fonts` or bundled asset |

A display face is the single cheapest way to stop looking generic — *if* it's used only for display sizes. Body text stays in the system face.

Good pairings seen in well-designed apps: system sans body + a serif display (journaling, reading, wellness); system sans + monospaced numerals (fitness, finance, weather); system rounded throughout (kids, habits, health).

### Ramp

| Token | iOS size/line (pt) | Android size/line (sp) | Weight | Tracking | Notes |
|---|---|---|---|---|---|
| `hero` | 56/60 (48–72) | 57/64 | semibold | −2% | tabular figures; one per screen |
| `largeTitle` | 34/41 | 32/40 | bold | −1% | top-level titles |
| `title` | 22/28 (up to 28/34) | 22/28 | semibold | 0 | sheet titles, section-defining titles |
| `headline` | 17/22 | 16/24 | semibold | 0 | row titles, card titles, buttons |
| `body` | 17/22 | 16/24 | regular | 0 | paragraphs, row values |
| `subhead` | 15/20 | 14/20 | regular | 0 | secondary lines |
| `footnote` | 13/18 | 12/16 | regular | 0 | metadata, legal |
| `overline` | 12/16 | 11/16 | semibold | +6% | UPPERCASE group labels only |

These match iOS text styles (`.largeTitle`, `.title2`, `.headline`, `.body`, `.subheadline`, `.footnote`, `.caption`) so Dynamic Type scales them for free. On Android they track Material 3 roles (`displayLarge`, `headlineMedium`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelSmall`).

### Rules

1. **Max 4 styles + hero per screen.** If you need a fifth, you need less content.
2. **Two weights:** regular and semibold. Bold only for `largeTitle`. Never `black`/`heavy` except a deliberate brand display face.
3. **Hierarchy order of operations:** size → weight → color (`ink` → `ink2`) → space. Never use opacity to make grey text over a colored background; use a role.
4. **Numbers:** tabular figures for anything that updates or aligns in columns. Units/currency symbols one step smaller and `ink2`: `7`**`h`** `8`**`m`**, `$`**`1,240`**`.50`.
5. **Sentence case** for titles, buttons, rows. UPPERCASE only for `overline`.
6. **Line length:** body text ≤ ~70 characters; on phones that's automatic, on tablets constrain width to 560–640pt.
7. **No text below 12pt/11sp.** No light/thin weights for body text.

---

## Spacing

4pt grid. Use named steps, never arbitrary numbers.

| Token | Value | Use |
|---|---|---|
| `xxs` | 4 | Icon-to-label inside a chip, number-to-unit |
| `xs` | 8 | Title-to-subtitle, between chips |
| `sm` | 12 | Between items within a group, card inner gap |
| `md` | 16 | Row horizontal padding, card padding (compact) |
| `margin` | 16 | **Screen margin** — matches iOS large titles, inset-grouped lists, M3 compact |
| `lg` | 20 | Card padding (default) |
| `xl` | 24 | Between a header and its content |
| `xxl` | 32 | **Between unrelated sections** |
| `xxxl` | 48 | Hero breathing room, onboarding vertical rhythm |

Rule of proximity: the space *between* groups must be at least 2× the space *within* a group. That alone replaces most cards and dividers.

---

## Shape

| Token | Value | Use |
|---|---|---|
| `radiusS` | 8 | Badges, small thumbnails, tags |
| `radiusM` | 14 | Inputs, rounded-rect buttons (if not capsule), segmented controls |
| `radiusL` | 20 | Grouped sections, object cards, media tiles |
| `radiusXL` | 28 | Sheet top corners, large hero cards |
| `capsule` | height / 2 | Buttons (default), chips, floating tab bar, search fields |

- **Concentric corners:** an element inset by `p` inside a container of radius `R` gets radius `R − p` (min 4).
- **Continuous ("squircle") corners** on iOS: `RoundedRectangle(cornerRadius:, style: .continuous)`.
- **One button shape per app.** Capsule (default) or `radiusM`. Never both.

---

## Elevation

| Level | Light | Dark |
|---|---|---|
| 0 — canvas | `canvas` | `canvas` |
| 1 — grouped content | `surface`, **no shadow** | `surface` |
| 2 — floating (tab island, FAB, popover) | `surface` + shadow `y 8, blur 24, #000 @ 8%` | `surface2`, no shadow, optional 1px `hairline` stroke |
| 3 — sheet / modal | `surface` + system sheet | `surface` + system sheet |

Never: shadows on every card, colored shadows, inner shadows, neumorphism, glass blur on content (blur belongs to system bars and sheets).

---

## Content colors

Colors that belong to the *content* — a shoe's colorway, a user-chosen label color, a chart's data series — are not UI roles and don't change with dark mode (a black shoe stays black). Define them next to the sample data, mark each line with `// mobile-ui: content-color` (the lint then allows the raw value), and render them through the pack's `QSwatch`, which adds the hairline ring that keeps black and white swatches visible in both modes.

## Iconography

- **One family.** SF Symbols on iOS; Material Symbols (Rounded or Outlined, pick one) on Android; for cross-platform RN/Flutter pick **one** of Phosphor, Lucide, or Material Symbols and use it everywhere.
- Default weight matches adjacent text weight. Size: 17–20pt in rows, 22–24pt in tab/nav bars.
- Glyphs are `ink` or `ink2`. Tinted glyph tiles (colored rounded squares) are allowed **only** in settings-style lists, and then every row gets one, in a consistent palette.
- **No emoji as UI icons.** Emoji are content (reactions, user-chosen avatars, celebration copy), not chrome.

---

## Imagery & illustration

- Photos and real content are the best decoration. A detail screen with a big, well-cropped image needs almost nothing else.
- Use one illustration style per app. Empty states may use a small (64–120pt), muted line illustration *or* a single glyph — not a 300pt stock 3D blob.
- Avatars: real photo, else initials on `accentSoft`/`surface2` — never a generic grey person icon when initials are available.
