# Detail

**Job:** show one thing in depth and let the user act on it. **Focal:** the media or the title/price block. **Primary action:** one, pinned in a bottom action bar (Add to bag, Book, Play, Reply).

## Anatomy

```
┌─────────────────────────────────┐
│ (‹)                     (♡) (⤴) │  ← transparent bar over media; glyphs on 36pt
│ ┌─────────────────────────────┐ │     surface-blur circles; becomes opaque on scroll
│ │          MEDIA              │ │  ← media: full-bleed, 4:5 or 1:1, paged dots
│ │                       • ◦ ◦ │ │
│ └─────────────────────────────┘ │
│ PS PAUL SMITH                   │  ← overline (brand/category)
│ Zebra colour-block sweatshirt   │  ← title (22–28 semibold), wraps, left-aligned
│ $175.00  · 4.6 ★ (212)          │  ← price (title, tabular) + proof (subhead ink2)
│                                 │
│ Colour   White                › │  ← option rows (grouped or hairline)
│ Size     Select               › │
│                                 │
│ ⓘ Free delivery · Free returns  │  ← reassurance line (footnote ink2) — max 1
│                                 │
│ Details                       + │  ← disclosure sections (accordion), collapsed
│ Size & fit                    + │
│ ─────────────────────────────── │
│ ┌─────────────────────────────┐ │
│ │       Add to bag            │ │  ← bottom action bar (pinned) + safe area
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

## Rules

1. **Media first, big.** If the item has an image, it leads, full-bleed. Detail screens are where photography does the design work.
2. **Title block = 3 facts max above the fold**: what it is, how much / when, one proof point (rating, distance, availability).
3. **Pin the primary action.** Bottom action bar; button label includes the decisive info when useful ("Add to bag · $175", "Book for Fri, Sep 18").
4. **Secondary actions are glyphs** in the nav bar (save, share) — not extra buttons in content.
5. **Options as rows**, opening sheets/pickers — not a wall of inline radio buttons. Size/variant selectors may be inline chips if ≤6 options. Color swatches always get a hairline ring so dark/light swatches survive both modes (see components.md §10).
6. **Long content goes behind disclosure** (accordion rows with `+`/chevron) — "Details", "Size & fit", "Shipping". Description preview: 3 lines + "More".
7. **Nothing below the bar.** The pinned bar is the last thing on screen; description and disclosure rows scroll above it, with a bottom content inset (eval finding: description rendered under the CTA).
8. **Related items** at the bottom as one horizontal carousel, peeking.
9. **Status/urgency** ("Low in stock", "2 seats left") in footnote with a glyph — `warning` color only if it's actually urgent.

## Budget

1 pinned primary · ≤2 nav glyphs · ≤3 facts above fold · 1 accent (rating star or status) · ≤1 reassurance line.

## Variants

- **Media playback** (podcast/song/video): artwork 1:1 large, title + creator, scrubber, transport controls centered (the one place symmetry is right), secondary actions as a row of glyphs.
- **Place/booking**: photo carousel, title, rating + distance, 3 facts as a metric row (price · hours · distance), map snippet, pinned "Book".
- **Article/reading**: no media requirement; serif title, generous line height (1.5), 17–19pt body, reading progress optional.
- **Record detail** (transaction, order): hero amount centered (ceremonial), status chip, grouped rows of facts, receipt actions at bottom.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Media in a small card with margins and shadow | Full-bleed |
| Primary CTA at the very bottom of a long scroll | Bottom action bar |
| "Add to cart", "Buy now", "Save", "Share" as 4 buttons | 1 pinned primary + 2 nav glyphs |
| Description dumped in full | 3-line preview + disclosure |
