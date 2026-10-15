# States — empty, loading, error, offline, success

Every list, home, search, and stats screen ships with these. Agents almost always forget them; designing them is a cheap way to look finished.

## Empty

Three different situations — don't use one component for all:

| Kind | Content | Action |
|---|---|---|
| **First use** | What will appear here + how to make it appear | The creation action (secondary, or primary if it's the screen's job) |
| **Cleared / done** | Positive closure ("You're all caught up") | None |
| **Filtered / no results** | Echo the filter/query, suggest a fix | "Clear filters" (tertiary) |

```
│                                 │
│            ◌ ✓                  │  ← glyph or small line illustration, 48–120pt,
│                                 │     ink3 / surface2 — never a 300pt 3D blob
│ No budgets yet                  │  ← title (headline/title), centered or left
│ Set a monthly limit for food,   │  ← body ink2 ≤2 lines: what + how
│ rent, or anything else.         │
│ [   Create a budget   ]         │  ← one action, hugging width (not full-bleed)
│                                 │
```

Rules: place at ~40% height; keep the nav bar, search, and tab bar visible; an empty list inside a populated screen gets an inline row-sized empty state ("No upcoming bills"), not a full-screen one.

## Loading

- **Skeleton** in the final shape: rows → 5–8 skeleton rows (circle + two bars of 60%/40% width); hero → a bar of hero height × 50% width; images → aspect-ratio blocks. `surface2`, radius matching, pulse 1.2s (none with Reduce Motion).
- Show only after 300ms. Keep the nav bar real (title, buttons), skeleton only the content.
- Pull-to-refresh/pagination: native refresh control; footer skeleton row.
- Button actions: spinner inside the button, label kept, width stable.

## Error

| Kind | Pattern |
|---|---|
| Whole screen failed, nothing cached | Empty-state layout: glyph, "Couldn't load your trips", "Check your connection and try again.", [Try again] |
| Refresh failed, cached content exists | Keep content; inline banner at top: "Couldn't refresh · Showing data from 9:41" + Retry |
| Field error | Under the field, `negative`, how to fix |
| Action failed (send, save) | Toast with Retry, or inline "Not sent · Tap to retry" on the item |

Never: raw error codes/messages as the headline, modal alerts for recoverable errors, blame ("You entered an invalid…").

## Offline

A thin persistent banner below the nav bar (`warning` soft fill, footnote): "You're offline. Changes will sync when you reconnect." Queue actions optimistically.

## Success

Most successes need only a haptic + a state change (checkmark, toast). Reserve a full success screen for meaningful completions (payment, booking, onboarding done): centered glyph/illustration in `positive` or accent, title ("You're booked"), 1–2 facts, one primary next step ("View booking"), one tertiary ("Done").
