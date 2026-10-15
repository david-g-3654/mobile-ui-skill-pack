# Stats

**Job:** show how a metric changes over time and whether the user is on track. **Focal:** the hero number for the selected period. **Primary action:** none; the period control is the main interaction.

## Anatomy

```
┌─────────────────────────────────┐
│ Activity                    (×) │
│ [  Day  |  Week  |  Month  ]    │  ← segmented control (native), 2–4 periods
│ ‹      This week, Sep 16–22   › │  ← period stepper: subhead, chevrons 44 hit
│                                 │
│ 33.19                           │  ← HERO (64–72, tabular or mono), left or centered
│ miles · ↑ 12% vs last week      │  ← unit + delta (sign + color), subhead ink2
│                                 │
│ ▁ ▃ ▅ ▂ ▇ ▃ ░                   │  ← one chart: bars or line, one series highlighted
│ M T W T F S S                   │     today/selected bar = accent, others ink @ 85% or surface2
│ ─ ─ ─ ─ goal 5 mi ─ ─ ─         │  ← goal line dashed, labeled at the end
│                                 │
│ 4:48:00   8'40"     12          │  ← metric row: 3 secondary metrics
│ time      avg pace  runs        │
│                                 │
│ History                         │
│ Sat, Sep 21  ·  5.2 mi  · 44:10 │  ← history rows (list)
└─────────────────────────────────┘
```

## Rules

1. **One hero, one chart** per period view. More metrics → metric row or rows, not more charts.
2. **Hero for the selected period**, updated with a numeric transition when the period changes. Selecting a bar updates the hero to that bar ("Thu · 6.1 mi"), releasing returns to the period total.
3. **Charts are minimal**: no chart borders, no background grids (or 1–2 hairline guides), no legends when one series (label in the hero), axis labels in footnote `ink2`, bars with 4pt top radius, gap ≥ 40% of bar width.
4. **Highlight with color, compare with grey**: the current/selected item in `accent`, the rest in `ink` (85%) or `surface2`; goals as a dashed line; goal-met bars may use `positive`.
5. **Ring/gauge** is good for progress toward a daily goal (steps, calories) — centered composition with the value inside; pair with "of 10,000 steps".
6. **Mono or tabular numerals** are a strong personality move for data apps.
7. **Compare like with like.** Mid-period, compare to the *same point* of the previous period ("vs. this time last week"), or show progress toward a goal instead of a delta. Never color a partial period red against a complete one — "↓ 43% vs last week" on a Wednesday reads as an alarm (eval finding).
8. **Hero at large text**: the hero row (number + unit + delta) must reflow, never clip at the screen edge — stack the delta under the number and shrink-to-fit the number (`minimumScaleFactor` / `adjustsFontSizeToFit` / `FittedBox`). **Axis labels at large text** switch to single letters (M T W T F S S) or every other label, and never run into each other. Seven three-letter day names don't fit under a phone-width chart at accessibility sizes (gallery finding). The pack's `QBarChart` does this for you, on every platform; use it rather than hand-rolling bars and axis labels.
9. **Chart box is fixed height** (160–200) directly under the hero, with no dead band above it; a goal marker only appears with its labeled goal line.
10. **Empty periods**: show the axis and a "No runs this week" line inside the chart area, not a blank screen.
11. **Accessibility**: the chart has an accessibility summary ("Miles per day, Monday 3.1 to Sunday 0") and values are reachable as a list.

## Budget

1 hero · 1 chart · 1 segmented control · ≤3 secondary metrics · ≤2 accent elements.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Four charts stacked, each in a card | One chart per period; others behind rows |
| Rainbow bars | One highlight color + neutral |
| Chart with legend, gridlines, axis titles, border | Strip to bars + day labels + goal line |
| Pie chart for 7 categories | Horizontal bar list sorted by value |
