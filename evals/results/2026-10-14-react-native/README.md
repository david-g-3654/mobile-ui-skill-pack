# Eval run: 2026-10-14, React Native (pack v0.2+), 8 prompts

**Question:** does the pack make agent-built React Native screens look more designed?
**Answer for this run:** yes. The with-pack screen won **16 of 16** blind pairwise judgments, and won both orderings of every prompt.

## Setup

Same method as the [SwiftUI run](../2026-10-14-swiftui/README.md).

| | |
|---|---|
| Prompts | 8 from `evals/README.md`: home, settings, paywall, onboarding, detail, list, stats, auth |
| Platform | Expo SDK 57 / React Native 0.86, Expo Router, TypeScript. Rendered on an iPhone 17 / iOS 27 simulator |
| Generators | 16 independent agents (Claude Opus 5.5), one per prompt × arm, with identical prompts and constraints. Each had to make its own file typecheck. **Without pack:** told not to use skills. **With pack:** told to read `mobile-ui` + `mobile-ui-react-native` and use the pack's `theme.ts` / `components.tsx` |
| Rendering | One Expo app with both arms as routes. Each screen captured in light, dark and accessibility-XL text (cold relaunch for AX). Blank frames retried |
| Judging | 16 blind judges (Claude Opus), each prompt judged twice with positions swapped (`ab-key.json`). Judges saw only the image, the user prompt and `rubric.md` |

## Results

| | Without pack | With pack |
|---|---|---|
| Typechecks | 8 / 8 | 8 / 8 |
| Blind pairwise wins | 0 / 16 | **16 / 16** |
| Mean rubric score (1–5) | 3.11 | **4.05** |
| Lint errors per file (median) | 26 | 0 |
| Lines of code (total) | 4,115 | 2,234 |

Position-bias check: judges chose "A" 8/16 times.

Per criterion (with / without): restraint **4.62 / 2.75** · content 4.56 / 4.06 · typography 4.00 / 3.38 · platform fit 3.94 / 3.12 · focal 3.88 / 3.56 · spacing 3.81 / 3.56 · dark mode **3.81 / 2.88** · accessibility **3.75 / 1.56**.

Compared with SwiftUI, the gap in accessibility and dark mode is larger. React Native gives you neither for free. Three of the 8 baseline screens had a single theme: paywall and detail ignored dark mode, onboarding was dark-only. Most baseline screens also collapsed at accessibility-XL text: clipped buttons, numbers split mid-figure ("46." / "3 km"), overlapping badges. The pack's `Txt` display cap, `useLargeText()` and the unpinning bottom bar held up.

## Caveats

The SwiftUI caveats all apply: small sample, LLM judges from the same model family, a rubric that shares the pack's values, and lint counts that favour the pack by construction. Two more for RN:

1. Dev-build overlays: two baseline screens showed a React Native warning or LogBox bar in the capture, which judges penalized. That is a real defect in the generated code (it raised the warning), but it makes those two baseline captures look worse than a release build would.
2. Each screen is the root of its route, so "no back button" on detail is partly a harness effect.

## Weaknesses the judges found in the pack's output (backlog)

| Finding | Seen in | Likely fix in the pack |
|---|---|---|
| Option chips and "Restore purchases" truncate at AX-XL | detail, paywall | Chip rows wrap (flex-wrap) at large text; tertiary links get `numberOfLines` removed |
| Pinned footer clips a line of the legal text | paywall | Check `BottomActionBar` footer measurement at default size |
| Bottom search bar overlaps the last rows | list | Content inset = bar height for any bottom-pinned control, not only the action bar |
| No hero / weak focal point on list and settings | list, settings | `screen-list.md`: a summary header (balance, count) when the list has a natural total |
| Dark list looks flat | list | Use `surface` rows on `canvas`, not rows on `canvas` |
| Empty gap above the chart, orphaned dot | stats | `screen-stats.md`: chart height fixed; no stray goal marker without a goal line |
| Description sits below the CTA | detail | Long content above the bar; the bar is pinned, not inline |
| Apple/Google marks missing | auth | Caused by the pack's own rule ("name + neutral glyph"). **Fixed in 0.3**: the provider SDK's button or the official asset is now required |
