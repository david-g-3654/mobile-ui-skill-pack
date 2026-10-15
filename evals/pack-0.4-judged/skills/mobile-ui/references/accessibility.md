# Accessibility (non-negotiable)

A screen that breaks at large text or under VoiceOver is not "properly designed", however it looks at default size.

## Text & contrast

- Body/secondary text ≥ **4.5:1**; large text (≥ 24pt regular or ≥ 19pt semibold) and essential glyphs ≥ **3:1**. The Quiet skin is verified; re-verify any custom `accent`/`ink2`.
- `ink3` (placeholder/disabled) is exempt *only* because it never carries information. If it does, it's `ink2`.
- Support **Dynamic Type** (iOS text styles / `@ScaledMetric`), **font scale** (RN `allowFontScaling` default true; cap with `maxFontSizeMultiplier={1.6}` only on space-critical chrome like tab labels), **textScaler** (Flutter — never `TextScaler.noScaling` on content).
- At XXL / 1.3×: rows grow vertically, horizontal metric rows wrap to vertical stacks, primary button labels stay on one line (shorten copy rather than shrink type).

## Touch

- Targets ≥ **44×44pt** (iOS) / **48×48dp** (Android), including glyph buttons in nav bars — extend the hit area, not the glyph.
- ≥ 8pt between adjacent targets.
- No essential action is gesture-only (swipe-to-delete also needs an edit mode or context menu).

## Screen readers

- Icon-only buttons: label = action ("Add expense", "Close"), not glyph name ("plus").
- Group composite rows into one element with a combined label ("Wake up, 8:00 AM, on").
- Hero metrics read naturally: "Balance, 1,240 dollars 50 cents, up 3 percent this month".
- Decorative images/illustrations are hidden from accessibility.
- Headings are marked as headers (`.accessibilityAddTraits(.isHeader)`, `accessibilityRole="header"`, `Semantics(header: true)`).
- Custom controls expose role, value, and state (selected plan card → "selected, Yearly, 34.99 dollars per year").

## Color & motion

- Never color alone: deltas get ↑/↓ or +/−; errors get text; selected states get a checkmark or border change, not only a tint.
- Reduce Motion: see [`motion-and-feedback.md`](motion-and-feedback.md).
- Increase Contrast (iOS) / high-contrast text (Android): hairlines become stronger (20%), `ink2` darkens.

## Quick test (do it before hand-off)

1. Largest accessibility text size — does the primary action survive?
2. VoiceOver/TalkBack swipe through the screen — is the order the visual order, and does every stop make sense?
3. Grayscale screenshot — does hierarchy still read? Does any state rely on color?
