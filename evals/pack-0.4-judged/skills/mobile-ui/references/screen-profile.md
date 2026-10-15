# Profile

**Job:** show who someone is (or manage your own identity) and their content. **Focal:** identity block — avatar + name. **Primary action:** others' profile → Follow/Message (one primary); own profile → Edit profile (secondary, not filled).

## Anatomy

```
┌─────────────────────────────────┐
│ (‹)                  (⤴) (···)  │
│ (◯◯)                            │  ← avatar 80–96, left-aligned (or centered on
│ Marcus Bennett                  │     media-heavy/creator profiles)
│ @marcusb · Birmingham           │  ← handle + 1 fact, subhead ink2
│ Climbing, film cameras, bad     │  ← bio, body, ≤3 lines + "more"
│ puns.                           │
│ 128 following · 2.4K followers  │  ← stats inline as text (headline numbers, ink2 labels)
│ [ Follow ]  [ Message ]         │  ← 1 filled + 1 secondary, or 2 equal secondary on own
│                                 │
│  Posts    Replies    Media      │  ← segmented / tab strip, sticky on scroll
│ ─────────────────────────────── │
│  (content list or grid)         │
└─────────────────────────────────┘
```

## Rules

1. **Identity first, left-aligned** for social/utility; centered for creator/portfolio profiles with a cover image.
2. **Stats as text, not tiles**: "128 following · 2.4K followers". 2–3 stats max.
3. **Cover images** only if users actually upload them; a default colored banner (the "blue rectangle") looks unfinished — omit it.
4. **Own profile**: "Edit profile" and "Share profile" as secondary buttons; settings via a nav glyph.
5. **Content tabs** sticky under the nav bar; empty tabs get their own empty state ("No replies yet").
6. **Account-management profile** (no social content): this is really a settings screen — use `screen-settings.md` with an identity header row.
7. **Avatar fallback**: initials, never a grey silhouette.

## Budget

≤1 filled button · ≤3 stats · ≤3 content tabs · 1 accent (follow button or verified mark).

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Default solid-color cover banner | Remove; start with the avatar |
| Stats in 3 bordered boxes | Inline text |
| Follow + Message + Share + More as 4 buttons | 1 primary + 1 secondary + overflow glyph |
