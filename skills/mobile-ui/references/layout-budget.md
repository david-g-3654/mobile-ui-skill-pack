# Layout & budget

## Reference frames

Design and check at three sizes. If it works at the extremes it works everywhere.

| Frame | Points | Why |
|---|---|---|
| Small | 375 × 667 (iPhone SE) / 360 × 640 dp | Primary action still above the fold? Titles wrap gracefully? |
| Default | 402 × 874 (iPhone 17) / 393 × 852 (iPhone 15/16) / 412 × 915 dp (Pixel) | The design target |
| Large text | Default frame at Dynamic Type **XXL** / font scale **1.3** | Rows grow, nothing truncates mid-word, CTA still visible |

Tablet: constrain readable content to 560–640pt and center the column; don't stretch rows edge to edge.

## Vertical rhythm (top to bottom)

```
status bar (system)
navigation bar  ─ inline title 44pt, or large title 52pt collapsing
  24  ← xl: header → first content
focal element (hero / title block / image)
  32  ← xxl: between unrelated sections
section header (overline or headline)
  8–12
grouped content
  32
…
  bottom content inset = bottom bar height + 16
bottom action bar / tab bar (system, safe-area aware)
home indicator (system)
```

## Horizontal

- Screen margin **16** (iOS and Android) — the same inset the system uses for large titles and inset-grouped lists, so custom content lines up with native chrome. Grouped sections inset **16** with radius **20**, or full-bleed rows with **16** leading inset — pick one per app. (20 on Max/Plus phones if you match `readableContentGuide`; never mix within a screen.)
- Row: 16 leading padding inside a grouped section; leading icon 20–24pt in a 28pt box; 12 gap icon→text; trailing value right-aligned, `ink2`; chevron 13pt semibold `ink3`.
- Two-column grids: gutter **12**; tiles share the screen margin.
- Horizontal carousels: first item aligns with the screen margin; peek the next item by 24–40pt so scrolling is discoverable; snap to items.

## Heights

| Element | Height |
|---|---|
| List row, 1 line | 52 (min 44 tap) |
| List row, 2 lines | 64–72 |
| Primary button | 52 (iOS) / 52–56 (Android) |
| Secondary button | 52 outline/tonal, or 44 text |
| Text field | 52 |
| Segmented control | 36 |
| Chip | 32–36 |
| Docked tab bar | system (49pt + safe area iOS / 80dp M3 nav bar) |
| Floating tab island | 64, inset 16 from sides, 8 above home indicator |
| Bottom action bar | button 52 + 12 top + safe-area bottom (min 16); ≤ 25% of screen height at any text size |

## Per-archetype budgets

| Archetype | Primary buttons | Accent | Cards above fold | Other |
|---|---|---|---|---|
| Home | 0–1 | 2 | 3 | 1 hero; ≤4 sections total |
| List / feed | 0 (nav `+`) | 1 | — | rows homogeneous; ≤2 lines meta |
| Detail | 1 (pinned) | 1 | 1 (media) | ≤3 facts above fold |
| Settings | 0 | 0–1 | 0 | ≤7 rows/section, ≤6 sections |
| Onboarding page | 1 | 1 | 0–1 | ≤3 value props, ≤40-word body |
| Paywall | 1 (pinned) | 2 | 2–3 plan cards | ≤5 benefits, legal visible |
| Auth | 1 | 0–1 | 0 | ≤3 auth providers visible |
| Profile | 0–1 | 1 | 1 | identity block + ≤3 stats |
| Stats | 0 | 2 | — | 1 hero, 1 chart, 1 segmented control |
| Form | 1 (pinned) | 0–1 | — | ≤6 fields per step |
| Chat | 0 (send is primary) | 1 | — | — |
| Search | 0 | 1 | — | recent + suggestions ≤8 |
| Sheet | 1 | 1 | — | ≤6 actions |
