# Component reference (platform-neutral)

Anatomy, measurements, states, and usage rules for the 23 core components. Every value is a token from [`style-guide.md`](style-guide.md). Native implementations:

- SwiftUI → [`../../mobile-ui-swiftui/references/components.md`](../../mobile-ui-swiftui/references/components.md)
- React Native → [`../../mobile-ui-react-native/references/components.md`](../../mobile-ui-react-native/references/components.md)
- Flutter → [`../../mobile-ui-flutter/references/components.md`](../../mobile-ui-flutter/references/components.md)

Format per component: **Use for / Don't use for · Anatomy · Spec · States · Rules**.

---

## 1. Primary button

**Use for** the single most important action on the screen. **Don't use for** navigation between peers, or more than once per screen.

Anatomy: container → label (headline) → optional leading glyph (≤20pt) or trailing spinner.

| Spec | Value |
|---|---|
| Height | 52 |
| Width | full width minus screen margins on phones; hug + min 160 in toolbars |
| Shape | capsule (default) or `radiusM` — one per app |
| Fill / label | `primaryFill` / `onPrimary` |
| Label | `headline`, sentence case, verb + object, ≤ 24 chars |

States: default · pressed (scale 0.98 + 90% opacity, spring) · disabled (`surface2` fill, `ink3` label — not 40% opacity of the fill) · loading (label stays, spinner replaces glyph, width stable, non-interactive).

Rules: Pin inside a **bottom action bar** on form, detail, paywall, onboarding, auth. Never two filled buttons side by side. Haptic on success outcome, not on press.

## 2. Secondary & tertiary buttons

- **Secondary** (an alternative, e.g. "Log in" under "Create account"): 52 high, `surface2` fill *or* 1px `hairline` outline, `ink` label. Same shape as primary.
- **Tertiary / text** (escape hatches: "Not now", "Restore purchases", "Skip"): no container, `ink2` or `accent` label, `subhead`/`headline`, min 44 hit area.
- **Destructive**: secondary style with `negative` label; filled `negative` only inside a confirmation step.

Stacking: primary on top, secondary below, 12 apart; tertiary below that, 8 apart.

## 3. Navigation bar & large title

**Use** the platform bar. Large title (34 bold) on top-level tab roots and long lists; inline title (17 semibold) on pushed details, forms, and sheets.

Rules: ≤2 trailing actions (glyphs, 44 hit area), ≤1 leading (back is system). The title in the bar is the *only* title — don't repeat it as a heading in content. On image-led details use a transparent bar over the image that becomes opaque on scroll.

## 4. Tab bar

**Docked** (default): system tab bar, 3–5 items, glyph + short label (1 word), selected = `ink` (or `accent`), unselected = `ink3`/`ink2`. 
**Floating island** (personality option): capsule, `surface` + level-2 shadow (light) / `surface2` (dark), height 64, inset 16, sits 8 above the home indicator, glyph-only allowed if every glyph is unambiguous; content scrolls *under* it with bottom inset = 64 + 16 + safe area.

Rules: never 6+ items; never a hamburger instead; the center "+" bump is allowed only when creation is *the* core action (camera, compose, log).

## 5. List row

The workhorse. Most screens are lists of rows; get this right and the app looks right.

Anatomy: [leading: glyph 20–24 / avatar 40 / thumbnail 48] · 12 · [title (headline or body) / subtitle (subhead, `ink2`)] · flexible space · [trailing: value (body, `ink2`) | toggle | badge | chevron].

| Spec | Value |
|---|---|
| Min height | 52 (one line), 64–72 (two lines) |
| Padding | 16 horizontal (inside group) / 20 (full-bleed), 12–14 vertical |
| Separator | `hairline`, inset to start at the title (not under the icon) |
| Chevron | only if the row pushes a screen |

States: pressed (`surface2` background, immediate), selected (checkmark trailing, `accent`), disabled (`ink3` text).

Rules: rows in one list share the same anatomy. Truncate subtitles to 1–2 lines with ellipsis; never truncate titles to fewer than ~12 characters — wrap instead. Values right-aligned in `ink2`; editable values get a chevron or become inline fields.

## 6. Grouped section

A set of related rows on a `surface` container on `canvas`, radius 20, inset 20 from screen edges (inset-grouped). Optional header (overline or headline, 8 above) and footer (footnote, `ink2`, 8 below) explain the group.

Rules: ≤7 rows; sections separated by 32. No shadow. No border.

## 7. Section header

Either **overline** (12 semibold uppercase +6% tracking, `ink2`) for settings/forms, or **headline/title** (17–22 semibold, `ink`) for content sections on home/detail. Optional trailing "See all" (subhead, `accent` or `ink2`). 24 above the content on home; 8 above grouped rows.

## 8. Hero metric

The focal number of a home or stats screen.

Anatomy: overline/eyebrow label (what it is) → number (`hero`, tabular, unit/currency one style smaller in `ink2`) → context line (subhead: delta, goal, period — delta colored `positive`/`negative` *with* an arrow glyph or sign so it isn't color-only).

Rules: one per screen; left-aligned on dashboards, centered only in ring/gauge compositions; animate value changes with a numeric content transition; never inside a pastel tile with an icon.

## 9. Metric row

Secondary metrics after a hero: 2–3 items in a row, each `title` number + `footnote` label, separated by space (24+) or a vertical hairline. No icons, no tiles, no individual cards.

## 10. Card (object)

**Use for** things that are objects the user thinks of as discrete: a plan, a payment card, a booking, a media item, a recommendation. **Don't use for** grouping unrelated content or wrapping a whole section.

Spec: `surface` on `canvas`, radius 20, padding 20 (16 compact), no shadow in light mode unless it floats. Media cards: image top with radius 20 clipped, 12 gap, title headline, meta subhead.

Rules: ≤3 visible above the fold; cards never contain cards; a card is tappable as a whole (one destination) or not at all.

**Color swatch** (product variants; pack: `QSwatch`): 28–32 circle with a 1px `hairline` ring *always* (a black swatch vanishes on a dark canvas, a white one on light); selected = 2px `ink` ring with 2px canvas gap; accessible label is the color name.

## 11. Segmented control

For 2–4 mutually exclusive *views of the same content* (Day/Week/Month, Posts/Replies). Height 36, `surface2` track, `surface` selected thumb (light) / lighter thumb (dark), labels subhead semibold. Use the native one. Not for navigation between different features (that's tabs) or for > 4 options (use a menu/chips).

## 12. Text field

Label **above** the field (footnote/subhead, `ink2`) — never placeholder-as-label. Field 52 high, `surface` on canvas or `surface2` on surface, radius 14, 16 horizontal padding, body text. Focus: 1.5px `ink` (or `accent`) border. Error: `negative` border + footnote message below that says how to fix. Helper text below in `ink2`. Correct keyboard type, content type/autofill hints, return key, and secure entry per field.

## 13. Toggle row

A list row with a trailing native switch. Applies immediately (no Save). Switch tint = `positive` or `accent` (pick one per app). The whole row toggles, not just the switch. Subtitle explains consequence when not obvious.

## 14. Chip / filter

Capsule, 36 high, 12 horizontal padding, subhead. Unselected: `surface2` fill, `ink` label. Selected: `ink` fill + `onPrimary` label, or `accentSoft` fill + `accent` label. Horizontal scroll row aligned to the screen margin. ≤1 glyph per chip. Never truncate a chip label: at accessibility sizes, inline option chips (size, variant) wrap onto more lines instead of clipping (eval finding).

## 15. Bottom sheet

For a quick task or set of choices that keeps context visible. Use system sheets (detents medium/large) where available. Grabber visible; top radius 28; title (title style) left-aligned or centered — pick per app; content padding 20; ≤6 actions; destructive actions last in `negative`; a close affordance (grabber + swipe, plus an × or Cancel for accessibility).

## 16. Empty state

Anatomy: optional glyph or small muted illustration (48–120pt, `ink3`/`surface2`) → title (headline/title, `ink`) → one line of body (`ink2`, ≤ 2 lines, says what will appear and how) → optional one action (secondary or primary if it's the screen's job).

Placement: optical center (≈ 40% from top), left-aligned or centered (ceremonial), never a 300pt illustration.

## 17. Skeleton

Blocks in the exact shape of the final layout, `surface2`, radius matching the real element, subtle shimmer or pulse (disabled under Reduce Motion). Show after 300ms; don't flash for fast loads. Never a full-screen spinner.

## 18. Toast / banner

Transient confirmation ("Copied", "Saved to Favorites"): capsule, `ink` fill + `onPrimary` text (inverse), top or bottom with safe area, 2–3s, optional single "Undo". Persistent problems (offline, payment failed) use an inline banner row at the top of content in `warning`/`negative` soft fill — not a toast.

## 19. Avatar

Circle. Sizes 24 (inline), 32 (comments), 40 (rows), 64–96 (profile). Fallback: initials (1–2 letters, semibold) on `surface2` or `accentSoft`. Optional 2px canvas ring when overlapping in stacks (−8 overlap, max 3 + "+12").

## 20. Badge

Count or status. Count: capsule min 18×18, footnote semibold, `negative` fill for notifications only. Status: capsule `radiusS`, overline-ish label on soft fill (`accentSoft`/`positive` 12%). ≤1 per row.

## 21. Progress (ring / bar)

Ring: 8–14 stroke, round caps, track `surface2`, progress `accent` (or `positive` when it means "goal met"); value inside in hero/title. Bar: 4–8 high capsule. Segmented steps for onboarding (dots or a bar at top). Always pair with a text value.

## 22. Plan card (paywall)

Anatomy: plan name (headline) · price (title, tabular) + period (subhead `ink2`) · per-month equivalent or savings (footnote) · optional badge ("Best value", `accentSoft`). Selected: 2px `ink` or `accent` border + checkmark; unselected: `hairline` border. Height equal across plans. 2–3 plans max, side by side (2) or stacked (3).

## 23. Bottom action bar

Container pinned to the bottom with the primary button (+ optional footer: legal line, tertiary links). Padding 16 horizontal (screen margin), 12 top, bottom = safe area + 8 (min 16). Solid `canvas` background with a hairline top border. Keyboard-aware on forms.

Rules: the bar *insets* the content (SwiftUI `safeAreaInset`, an RN sibling after the scroll view, Flutter `bottomNavigationBar`) — never overlay it, or the last item hides underneath. **At accessibility text sizes only the primary button stays pinned**: the footer moves to the end of the scroll content (pack: `footer:` + `QLargeTextFooter`). A pinned bar must never exceed ~25% of the screen height. (Eval finding: a pinned terms block at AX-XL covered headlines and content on 3 of 8 screens.)

## 24. Bar chart (stats)

One series, one highlighted bar (`accent`: today or the selected bar), the rest in `ink` at ~85%, empty days as a hairline stub rather than nothing. Bars take ~55% of their column with a 4pt top radius. An optional goal is a dashed `ink3` line with a footnote label at its right end. No chart border, legend or grid beyond 1–3 hairline guides. Height 160–200, fixed (see screen-stats.md).

Rules: **axis labels must never collide or clip at any text size.** Use full labels ("Mon") when they fit their column, single letters ("M") at accessibility sizes, and every other label as a last resort. Never shrink the bars to make room. Every bar is reachable by VoiceOver/TalkBack with its label and value. Pack: `QBarChart` on all three platforms. (Eval finding: hand-rolled charts ran their day names together or clipped at AX-XL, and one cross-family judge preferred the baseline on that alone.)
