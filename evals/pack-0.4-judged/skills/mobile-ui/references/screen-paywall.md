# Paywall

**Job:** help the user choose a plan and start (usually a trial) — honestly. **Focal:** headline + the recommended plan card. **Primary action:** one pinned button whose label states the deal ("Start 7-day free trial").

## Anatomy

```
┌─────────────────────────────────┐
│ (×)                    Restore  │  ← close always visible (top-left or right), restore as text
│                                 │
│     [ hero art / app icon ]     │  ← personality zone: illustration, product shot, or bold color
│                                 │
│ More play.                      │  ← headline: outcome, 2 short lines, hero/largeTitle
│ Less routine.                   │
│ ✓ Unlimited dictation           │  ← benefits: ≤5, check glyph accent/ink, body
│ ✓ Works in every app            │
│ ✓ Learns your writing style     │
│                                 │
│ ┌──────────────┐┌─────────────┐ │  ← plan cards (2 side by side, or 3 stacked)
│ │ Monthly      ││ Yearly  ✓   │ │     selected: 2px ink/accent border + check
│ │ $7.99/mo     ││ $49.99/yr   │ │     badge "Save 48%" on recommended
│ │              ││ $4.17/mo    │ │
│ └──────────────┘└─────────────┘ │
│ [   Start 7-day free trial    ] │  ← pinned primary
│ 7 days free, then $49.99/year.  │  ← footnote ink2: plain-language terms
│ Cancel anytime.  Terms · Privacy│
└─────────────────────────────────┘
```

## Rules

1. **Close is visible from the first frame.** Hidden or delayed close buttons are a dark pattern and an App Review risk.
2. **Price clarity:** total price + period on each plan; per-month equivalent as secondary; trial length and what happens after it in plain words next to the CTA.
3. **Pre-select the recommended plan** (usually yearly) — visibly selected, not just badged. Allow switching with one tap.
4. **Benefits are outcomes**, ≤5, one line each. A comparison table belongs behind "See all features".
5. **The CTA label reflects the selection**: "Start 7-day free trial" vs "Subscribe for $7.99/month" when the plan has no trial.
6. **Personality allowed**: the hero zone can be bold (color field, illustration, gradient backdrop, dark mode). The plan + CTA zone stays calm and legible.
7. **Restore purchases, Terms, Privacy** always reachable (top bar or footer). Promo code as a tertiary link if supported.
8. **Contextual paywalls** (hitting a limit) lead with what they tried to do: "Unlock unlimited journals" + the benefit they hit.
9. **Timeline variant** for trials: Today (full access) → Day 5 (reminder) → Day 7 (billing) as a small vertical timeline — builds trust.

## Budget

1 primary (pinned) · 2–3 plans · ≤5 benefits · ≤2 accent elements (selection + savings badge) · legal always visible.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Gradient button + gradient text + gradient background | Solid ink CTA; one gradient backdrop max |
| Tiny grey close button appearing after 5s | Visible close from frame one |
| "Continue" CTA with price hidden below | Price and terms adjacent to CTA |
| 8 feature rows with icons in colored circles | ≤5 check rows, monochrome |
| Three plan cards with three different badges | One badge, on the recommended plan |
