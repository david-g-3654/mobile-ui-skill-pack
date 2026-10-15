# Home / dashboard

**Job:** answer "where do things stand?" and offer the next action. **Focal:** one hero (a metric, a greeting-with-status, or the next item). **Primary action:** 0–1; often the tab bar's create action or a single inline CTA.

## Anatomy

```
┌─────────────────────────────────┐
│ Today ▾                 (◯) (⚙) │  ← inline bar: date/context left, ≤2 glyphs right
│                                 │
│ Good morning, Amara             │  ← optional greeting (title, ink2) — only if it carries status
│ $2,140.50                       │  ← HERO (56, tabular; "$" and ".50" smaller ink2)
│ left to spend · 12 days to go   │  ← context (subhead, ink2)
│                                 │
│ 31h 34m   │  6     │  82%       │  ← metric row: 2–3 secondary metrics, no icons
│ screen    │ pickups│ goal       │
│                                 │
│ Up next                 See all │  ← section header (headline)
│ ┌─────────────────────────────┐ │
│ │ ▣ Rent · due Thu    −$1,450 │ │  ← grouped rows (≤4 on home)
│ │ ▣ Spotify · Sep 18   −$11.99│ │
│ └─────────────────────────────┘ │
│                                 │
│ For you                         │  ← ≤1 promo/recommendation card
│ ┌───────────────┐┌──────────┐   │     (carousel peeks next item)
│ └───────────────┘└──────────┘   │
│  [⌂]   [▤]   [＋]   [◔]   [◯]   │  ← tab bar (docked or floating island)
└─────────────────────────────────┘
```

## Rules

1. **Decide the hero.** Money app → balance. Health → today's ring/steps. Habit → today's checklist progress. Social → the feed itself is the hero (use `screen-list.md`). Utility (alarm, timer) → the next event, huge ("8:30 AM", 56–72pt).
2. **Hero is left-aligned**, plain, on canvas — not in a tile. Exception: a ring/gauge composition centered with the value inside.
3. **≤4 sections total.** Each section must justify itself against the screen's job. Order: status (hero) → what needs attention → what's next → discovery.
4. **Secondary metrics are a row, not a grid of tiles.** 2–3 values, `title` size, `footnote` labels, separated by space or vertical hairlines.
5. **One promotional/upsell card max**, below the fold if possible, dismissible.
6. **Greeting only if it says something.** "Good morning, Amara" + status ("Everything is quiet, enjoy your night") is good; "Welcome back!" alone is filler.
7. **Personal context chips** (weather, location, next reminder) are a nice personality move — capsule chips in `surface`, `subhead`, max one row.

## Budget

1 hero · ≤3 metrics in the metric row · ≤4 sections · ≤3 cards above fold · ≤2 accent elements · 0–1 primary button.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| 2×2 grid of icon tiles (Steps / Calories / Sleep / Water) | Hero = the metric that matters today; others in a metric row; deep dive on Stats |
| Six horizontal carousels | Keep one; turn others into "See all" rows or remove |
| Every section in a shadowed card | Canvas + section headers; cards only for objects |
| Hero buried under a greeting banner | Greeting as a one-line eyebrow above the hero, or remove |
| Charts on home | One sparkline max; full charts belong on Stats |

## Variants

- **Calm/editorial**: serif greeting as the hero ("Today is going to be a good day."), illustration accent, metrics below.
- **Utility**: giant next-event time, two shortcut rows, nothing else.
- **Data-dense (pro)**: mono numerals, hairline-separated metric rows, no cards at all.
