# Form / checkout

**Job:** collect input correctly the first time. **Focal:** the current field / the order total. **Primary action:** one, pinned and keyboard-aware ("Save address", "Pay $42.80").

## Anatomy — checkout

```
┌─────────────────────────────────┐
│ (‹)          Checkout           │  ← inline title
│ DELIVER TO                      │  ← overline
│ ┌─────────────────────────────┐ │
│ │ Home                       › │ │  ← summary rows that open editors (sheets/pushes)
│ │ 221 Valencia St, Apt 4      │ │
│ └─────────────────────────────┘ │
│ PAYMENT                         │
│ ┌─────────────────────────────┐ │
│ │  Apple Pay                 › │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ Subtotal              $38.50 │ │  ← summary: body, values tabular right
│ │ Delivery               $2.99 │ │
│ │ Service fee            $1.31 │ │
│ │ ─────────────────────────── │ │
│ │ Total                 $42.80 │ │  ← total: headline/title semibold
│ └─────────────────────────────┘ │
│ [         Pay $42.80          ] │  ← pinned primary (or official Apple/Google Pay button)
└─────────────────────────────────┘
```

## Anatomy — data entry

```
│ Full name                       │  ← label above (subhead ink2)
│ [ Sofía Ramírez               ] │  ← field 52, surface, radius 14
│ Email                           │
│ [ sofia@…                     ] │
│ We'll send the receipt here.    │  ← helper (footnote ink2)
│ Postcode                        │
│ [ 9410                        ] │  ← error: negative border
│ Enter all 5 digits.             │  ← error text (footnote negative) — how to fix
```

## Rules

1. **Summary-first checkout**: show decisions as rows (address, payment, delivery time) that open editors, rather than one long form.
2. **One column**, labels above, ≤6 fields per step; split long forms into steps with a progress bar.
3. **Right keyboard, autofill, and return key** for every field (email, phone, numeric, postal code, name, one-time code, new password). Autofill is the best UX upgrade available.
4. **Validate on blur, not on every keystroke**; never before the user has typed. Errors say how to fix.
5. **Optional fields marked "(optional)"**; don't mark required ones with asterisks.
6. **Pinned primary** includes the decisive value ("Pay $42.80"); disabled until valid *only* if the reason is visible — otherwise keep enabled and show errors on tap.
7. **Platform pay buttons** (Apple Pay / Google Pay) use official components and go first when available.
8. **Totals**: tabular figures, right-aligned, total line semibold with a hairline above. Discounts in `positive` with a minus sign.
9. **Pickers**: native date/time pickers, menus for ≤7 options, a searchable sheet for long lists (countries).

## Budget

1 primary (pinned) · ≤6 fields per step · 0–1 accent · ≤3 summary groups.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Placeholder-only fields | Labels above |
| 14-field single page | Steps or summary rows |
| Red errors on untouched fields | Validate on blur/submit |
| Custom card form when Apple/Google Pay available | Platform pay first |
