# Anti-patterns — what makes a screen look generic

Each entry: **the tell** → why it reads as generic → **the fix**. The lint script (`scripts/mobile_ui_lint.py`) detects the ones marked 🔎.

## Structure

1. **Card soup.** Every section is a white rounded rectangle with a drop shadow; cards nest inside cards. Everything gets equal weight, so nothing is important. → Use canvas + space + section headers to group. Reserve cards for *objects* (a plan, a payment method, a photo tile, a booking). Max 3 cards above the fold. 🔎 (shadow count)
2. **The 2×2 stat grid.** Four equal tiles, each with a pastel circle icon, a number, and a label. This is the single most recognisable AI-dashboard tell. → One hero metric with context ("$2,140 left this month · 12 days to go"), then one quiet row of 2–3 secondary metrics separated by space or a hairline, no icons.
3. **Section header + card + "See all" for everything.** A home screen that is six identical carousels. → Pick the one section that answers the screen's job and give it the room; demote the rest to rows or a second screen.
4. **Equal-weight button pairs.** "Cancel" and "Confirm" as two identical filled buttons side by side. → One primary (filled), one tertiary (text), stacked vertically on phones with the primary *on top/closest to the thumb* per platform convention (iOS sheets: primary on top; Android dialogs: confirm on the right).
5. **Dead whitespace vs. cramped.** Either 8pt margins with walls of text, or a single small element floating in an empty screen. → Screen margin 16 (aligned with native titles), section gap 32, and let the focal element be big.
6. **Everything centered.** Centered titles, paragraphs, form labels. → Left-align. Center only ceremonial, short moments: success, empty state, onboarding hero, paywall headline.

## Typography

7. **Flat hierarchy.** Title 20, subtitle 18, body 16, caption 14 — all close, all bold-ish. → Big jumps: 34 → 17 → 13. Size, then weight, then color. 🔎 (distinct font sizes)
8. **Bold everything.** → Two weights. Semibold for titles/row titles, regular for everything else. 🔎 (bold count)
9. **Title Case On Every Label.** → Sentence case. 
10. **Grey via opacity** (`opacity: 0.6` text, `Colors.black54`) on colored or photo backgrounds — muddy and fails contrast. → Use `ink2` or a scrim.
11. **Tiny legal text at 10pt, light weight.** → 13pt `footnote`, regular, `ink2`.
12. **Non-tabular numbers** that jitter as they update. → Tabular/monospaced digits.

## Color

13. **Default blue / Material purple / Tailwind indigo** as the brand. 🔎 (`#007AFF`, `#6200EE`, `#6750A4`, `#6366F1`, `Colors.blue`, `Color.blue`, `systemBlue` used as brand)
14. **Rainbow icon tiles** with a different random color per row (outside of settings). → Monochrome glyphs.
15. **Gradient buttons, gradient text, purple→blue hero gradients.** 🔎 → Solid fills. Gradients only as image-like backgrounds on onboarding/paywall heroes, and then subtle (2 adjacent hues).
16. **Accent everywhere** (all icons, all links, all titles tinted). → ≤2 accent elements per screen.
17. **Pure `#FFFFFF` cards on pure `#FFFFFF` background with `#CCC` borders.** → `surface` on `canvas`, hairlines at 10% ink.
18. **Hard-coded hex in screens.** Breaks dark mode and rebranding. 🔎 → Roles from the token file only.
19. **Dark mode = inverted light mode** with the same shadows and the same accent. → See style-guide dark rules.

## Native-ness

20. **Fake navigation bar.** A custom `View`/`Row` with "‹ Back" text, a centered title, and no swipe-back. → Platform navigator (`NavigationStack`, React Navigation native-stack / Expo Router `Stack`, `Navigator`/go_router with `CupertinoPageRoute` on iOS).
21. **Hamburger menu on iOS.** → Tab bar for 3–5 top-level destinations.
22. **FAB on iOS.** → A `+` in the navigation bar, or a primary row/button in content.
23. **Material ripple and Android-style top app bar on iOS** (Flutter/RN defaults). → Platform-adaptive: Cupertino-style on iOS, Material 3 on Android, or a deliberately neutral custom style that respects both platforms' navigation.
24. **Custom alert dialogs** for simple confirmations. → System alert / confirmation dialog / action sheet.
25. **Toggles that need a Save button.** → Toggles apply immediately; forms with text fields need Save.
26. **Ignoring safe areas.** Content under the notch/home indicator, bottom buttons cut off. → SafeArea + bottom action bar with `safe-area inset + 8`.
27. **Full-screen spinner** on every load. → Skeletons in the final layout shape; spinner only inside buttons or for < 1s blocking actions.

## Content

28. **Placeholder data.** Lorem ipsum, John Doe, Jane Smith, "Item 1/2/3", "$0.00", identical rows, perfect-length strings. 🔎 → Varied, realistic data: long names, missing avatars, big and small numbers.
29. **Emoji as icons.** 🔎 (emoji inside Text in buttons/rows) → One icon family.
30. **Vague buttons.** "Submit", "OK", "Click here", "Learn more" everywhere. → Verb + object.
31. **Empty state = big icon + "No data".** → What will be here, why it's empty, the one action to fill it.
32. **Every row has an icon, a title, a subtitle, and a chevron** even when nothing navigates. → Chevron only on rows that push a screen. Subtitle only when it adds information.

## Interaction

33. **No pressed states.** → Every tappable thing has a pressed state (opacity 0.6–0.7 or `surface2` background) and a ≥44pt hit area.
34. **No haptics on commit actions** (iOS). → Light impact on toggle/selection, success notification on purchase/complete.
35. **Linear 300ms ease-in-out** on everything. → Springs; snappier for small things.
36. **Modals for everything.** → Push for drill-down, sheet for a quick task that keeps context, full-screen modal only for a separate mode (compose, camera, onboarding).

## Found in evals (2026-10-14)

37. **Tall pinned footers at large text.** Terms + links + secondary buttons pinned under the CTA grow to half the screen at accessibility sizes and cover the content. → Pin only the primary button at accessibility sizes; move the footer into the scroll content.
38. **Overlaid bottom bars.** A bar drawn with an overlay/ZStack on top of a ScrollView hides the last rows. → Inset the content (`safeAreaInset`, sibling view, `bottomNavigationBar`).
39. **Mixed money formats** (`$1,284` beside `US$640.00`). → One formatter per screen.
40. **Alarming partial-period deltas** ("↓ 43% vs last week" on a Wednesday). → Compare to the same point of the previous period, or show goal progress.
41. **Template copy reused verbatim.** → Templates are structure, not copy.
42. **Hand-drawn or missing brand logos** (a text "G" for Google, or provider buttons with no mark). → The provider SDK's button, or the official asset.
43. **Invisible swatches** (black product swatch on a dark canvas). → Hairline ring on every swatch.
44. **Single-theme screens** (light only, or dark only). → Every color from the skin's roles, so both modes come for free; check both in previews.
45. **Truncated chips and links at large text** ("S…", "Restore pur…"). → Wrap chip rows; let tertiary links wrap.
46. **Lists without a focal point.** A transactions or tasks list with no total. → A one-line summary header (balance, due count) above the first section.
