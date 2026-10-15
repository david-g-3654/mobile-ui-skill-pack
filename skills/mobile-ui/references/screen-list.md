# Feed / list

**Job:** browse and pick from many similar items. **Focal:** the content itself — the first item's title/image. **Primary action:** usually none in content; create lives in the nav bar (`+`) or tab bar.

## Anatomy

```
┌─────────────────────────────────┐
│ Inbox                       (+) │  ← large title (collapses on scroll)
│ [🔍 Search                    ] │  ← search in the bar (iOS searchable / M3 search bar)
│ (All) (Unread 3) (Flagged)      │  ← optional chips: ≤5 filters, h-scroll
│                                 │
│ (AO) Amara Okafor        9:41   │  ← row: avatar 40 · title headline · time footnote ink2
│      Lease renewal — I've sig…  │     preview subhead ink2, 1–2 lines
│ ─────────────────────────────── │     hairline inset to text start
│ (LW) Lucas Wei          Yesterday│
│      Photos from Sunday · 2 att.│
│ ─────────────────────────────── │
│ (TH) Theo                  Mon  │
│ ...                             │
└─────────────────────────────────┘
```

## Rules

1. **Rows are homogeneous.** Same anatomy, same heights per type; variety comes from *content*, not from styling individual rows.
2. **Full-bleed rows with inset hairlines** for content lists (mail, messages, transactions). Inset-grouped sections for finite, categorized lists (settings, accounts).
3. **Leading element communicates type or identity**: avatar for people, thumbnail for media/products, glyph for categories. Pick one per list.
4. **Trailing**: time/amount/status in `ink2`. Amounts are tabular and right-aligned; negative amounts use `−` (minus) and `ink` (not red) unless the domain needs color — then color *and* sign.
5. **Unread/new state**: semibold title + an 8pt `accent` dot; read = regular.
6. **Section by time** for chronological feeds ("Today", "Yesterday", "Earlier this week") with overline headers, sticky on scroll.
7. **Swipe actions** for frequent row actions (archive, delete) — max 2 per side; destructive in `negative`. Also available via long-press menu.
8. **Media feeds** (photos/products): 2-column grid, gutter 12 (or 2 for photo walls), consistent aspect ratio per feed, title below image (not overlaid unless the image is the content and text is short with a scrim).
9. **Pull to refresh** with the native control; infinite scroll with a skeleton row at the end, not a spinner.
10. **Summary header when the list has a natural total** (balance, count due, unread): one hero line above the first section (title2 or larger, tabular). Without it, transaction and task lists have no focal point (eval finding).
11. **Dark mode**: rows sit on `surface` over `canvas` (inset-grouped) or on `canvas` with hairlines that are visible in dark. A row list drawn directly on a near-black canvas reads flat (eval finding).
12. **Bottom-pinned controls** (search bar, compose bar, filter bar) get the same bottom content inset as an action bar, so the last row scrolls clear of them.

## Budget

Rows: ≤2 lines of meta. Chips: ≤5. Accent: unread dots/selected chip only. No cards around individual rows.

## States

Empty (first use + filtered-empty are *different* screens), loading (5–8 skeleton rows), error (inline, keep cached rows visible), offline (banner row). See `screen-states.md`.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Each row is its own floating card with shadow | Full-bleed rows + hairlines, or one grouped section |
| Icon + title + subtitle + chevron + badge on every row | Remove chevron (if row opens detail, it's implied in content lists on iOS mail-like UIs; keep chevrons in settings-like lists), keep 1 leading + 1 trailing |
| Bold titles on all rows | Semibold only for unread/new |
| Red for all negative amounts in a spending list | `ink` + minus sign; color reserved for unusual events (refunds/positive, declines/negative) |
