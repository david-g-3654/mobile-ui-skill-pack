# Settings

**Job:** change preferences and manage the account. **Focal:** none — settings should be calm and scannable; the account header is the closest thing to a focal element. **Primary action:** none (toggles apply immediately; destructive actions live at the bottom).

## Anatomy

```
┌─────────────────────────────────┐
│ Settings                   Done │  ← large title (tab root) or inline + Done (modal)
│ ┌─────────────────────────────┐ │
│ │ (AO) Amara Okafor          › │ │  ← account header row: avatar 48 + name + email
│ │      amara@hey.com          │ │
│ └─────────────────────────────┘ │
│ PREFERENCES                     │  ← overline header
│ ┌─────────────────────────────┐ │
│ │ ◐ Appearance       System › │ │  ← value rows: value ink2 + chevron
│ │ ◷ Wake up        8:00 AM  ◉ │ │  ← inline value + toggle
│ │ ◔ Notifications          › │ │
│ └─────────────────────────────┘ │
│ Daily reminders appear at the   │  ← group footer (footnote ink2) explains consequences
│ time you choose.                │
│                                 │
│ SUBSCRIPTION                    │
│ ┌─────────────────────────────┐ │
│ │ Pro · renews Oct 3        › │ │
│ │ Restore purchases           │ │  ← action rows: ink or accent text, no chevron
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ Sign out                    │ │
│ │ Delete account              │ │  ← negative text, last, separate group
│ └─────────────────────────────┘ │
│        Joi 4.2.0 (1182)         │  ← version footer (footnote ink3-ink2), centered
└─────────────────────────────────┘
```

## Rules

1. **Inset-grouped sections** on `canvas`, no shadows, ≤7 rows each, ≤6 sections. Order: account → most-changed preferences → notifications → privacy/data → subscription → support/legal → sign out/delete.
2. **Row types are distinct and consistent:**
   - *Navigation*: title + optional value (`ink2`) + chevron.
   - *Toggle*: title (+ subtitle if consequence isn't obvious) + switch. Applies immediately.
   - *Inline value*: title + value, tapping opens a menu/picker in place.
   - *Action*: title only, `ink`/`accent` (or `negative`), no chevron.
   - *External link*: title + ↗ glyph, opens in-app browser.
3. **Icons:** either none, or a tinted rounded-square glyph tile (29pt, radius 7) on *every* row, consistently colored by category. Never a mix.
4. **Group footers** explain non-obvious consequences. Use them instead of subtitles on every row.
5. **Destructive actions** in their own last group, `negative` label, confirmation via system alert/action sheet with a specific verb ("Delete account").
6. **Version/build footer** + optional "Made by" line — small, centered: a cheap, human touch.
7. **Pro/upsell**: one row or one compact card at the top for free users — not a banner on every section.

## Budget

0 primary buttons · ≤1 accent use (switch tint or upsell) · ≤7 rows/section · ≤6 sections per screen (nest the rest).

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Each row is its own card | One grouped section per category |
| Random-color circle icons | Consistent rounded-square tiles, or no icons |
| Save button at the bottom of toggles | Remove; toggles apply immediately |
| "Logout" in the middle in red | Last group |
| Title Case Everywhere, ALL CAPS ROW LABELS | Sentence case rows; caps only in overline headers |
