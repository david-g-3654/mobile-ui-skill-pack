# Onboarding

**Job:** get a new user to their first moment of value with the least friction. **Focal:** the headline (an outcome, not a feature). **Primary action:** one per page — "Get started", "Continue", "Turn on notifications".

## Patterns (pick one)

| Pattern | When | Shape |
|---|---|---|
| **Single welcome + value list** (default) | Most apps | One screen: big left-aligned title, 3 icon+title+subtitle value props, bottom block with primary + "Log in" |
| **Personalization steps** | Recommendations depend on answers | Progress bar at top, one question per screen, big tappable options, Continue pinned |
| **Paged carousel** | Visual/emotional products | 3 pages max, illustration/photo + headline + one line, dots + Skip/Next |
| **Do-it-now** | Tools (camera, notes, timer) | Skip onboarding; teach in context with one inline tip |

## Anatomy — single welcome (default)

```
┌─────────────────────────────────┐
│                                 │
│ Welcome to                      │  ← largeTitle/hero (34–40 bold), left-aligned,
│ Voicenotes                      │     2 lines; display face if the app has one
│ Your notes, transcribed and     │  ← subhead ink2, 1–2 lines
│ searchable.                     │
│                                 │
│ ⏺  Record anything              │  ← value props: glyph 24 ink, title headline,
│    Meetings, ideas, voice memos │     subtitle subhead ink2; ≤3; spacing 24
│ ✦  Ask your notes               │
│    Summaries and action items   │
│ ⤴  Send anywhere                │
│    Notion, email, Slack         │
│                                 │
│ ┌─────────────────────────────┐ │  ← bottom block (optionally an inverse
│ │ I accept the Terms & Priv.◉ │ │     ink-colored panel with radius 28 top)
│ │ [      Get started        ] │ │  ← primary
│ │ [         Log in          ] │ │  ← secondary
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

## Rules

1. **Headline = outcome.** "Wake up without the snooze spiral." Not "Welcome to AlarmPro!".
2. **Left-aligned big type** is the modern default; centered is fine for one-line ceremonial screens ("You're all set").
3. **≤3 value props**, each ≤ 8 words title + ≤ 10 words subtitle. No feature dumps.
4. **Ask for permissions in context**, with a pre-prompt that states the benefit, *never* in a row of system prompts at launch. One permission per screen.
5. **Progress** for multi-step: a thin capsule bar (4pt) at top, or dots — plus a back button. Show the step count only if ≤5.
6. **Skip** is a tertiary text button top-right or bottom-left, always available unless the step is required (account creation).
7. **Personalization options** are big (≥56pt rows or 2-column tiles), single-select auto-advances after 250ms, multi-select needs Continue.
8. **Account creation late.** Let users see value first if the product allows it.
9. **Personality lives here.** Onboarding is the one place for a bold background color, a gradient backdrop, a full-bleed photo, or a mascot. Keep the next screens calm.

## Budget

1 primary per page · ≤3 value props · ≤3 carousel pages · ≤5 personalization steps · 1 accent.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| 5-page carousel of features with stock illustrations | One welcome screen + value list |
| Centered paragraph walls | Left-aligned title + ≤3 short props |
| Notification + tracking + location prompts on launch | In-context, one at a time, pre-prompt first |
| Gradient purple background on every step | Personality once, on the welcome screen |
