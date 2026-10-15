# Eval run: 2026-10-14, Flutter (pack v0.2+), 8 prompts

**Question:** does the pack make agent-built Flutter screens look more designed?
**Answer for this run:** yes, with clear gaps. The with-pack screen won **14 of 16** blind pairwise judgments, winning 7 of 8 prompts in both orderings. It lost **auth** in both orderings. This is the weakest of the three platforms and the only one below the ship bar's mean score.

## Setup

Same method as the [SwiftUI](../2026-10-14-swiftui/README.md) and [React Native](../2026-10-14-react-native/README.md) runs.

| | |
|---|---|
| Prompts | 8 from `evals/README.md`: home, settings, paywall, onboarding, detail, list, stats, auth |
| Platform | Flutter 3.47.7, Material 3. Built for and rendered on an iPhone 17 / iOS 27 simulator. Judges were asked to judge them as iOS screens |
| Generators | 16 independent agents (Claude Opus 5.5), one per prompt × arm, with identical prompts and constraints. Each had to pass `flutter analyze`. **Without pack:** told not to use skills. **With pack:** told to read `mobile-ui` + `mobile-ui-flutter` and use the pack's `theme.dart` / `components.dart` |
| Rendering | One host app (`harness/main.dart`) built once per screen with `--dart-define=EVAL_SCREEN=<arm>-<id>`, captured in light, dark and accessibility-XL text (`harness/fl_eval_render.sh`) |
| Judging | 16 blind judges (Claude Opus), each prompt judged twice with positions swapped (`ab-key.json`) |

**Harness incident:** the first capture showed the same screen in all 48 images. The host read its screen key from a file that the iOS sandbox didn't expose, and silently fell back to a default screen. Blank-frame detection doesn't catch this, but an overview grid did. The host now fails loudly on an unknown key, the render script checks that all captures differ, and `evals/README.md` tells you to check both before judging. Judging happened only after the corrected capture.

## Results

| | Without pack | With pack |
|---|---|---|
| `flutter analyze` | 8 / 8 clean | 8 / 8 clean |
| Blind pairwise wins | 2 / 16 | **14 / 16** |
| Mean rubric score (1–5) | 3.27 | **3.95** |
| Lint errors per file (median) | 9 | 0 |
| Lines of code (total) | 5,526 | 2,880 |

Position-bias check: judges chose "A" 8/16 times.

Per criterion (with / without): restraint **4.81 / 2.69** · content 4.50 / 4.06 · focal **4.12 / 3.38** · typography **4.06 / 3.06** · spacing 3.81 / 3.50 · platform fit 3.75 / 3.12 · dark mode 3.69 / 3.81 · accessibility 2.81 / 2.50.

The Flutter baseline is the strongest of the three platforms (3.27). Material 3 gives a coherent theme, real dark mode and decent spacing for free, and the baseline actually beat the pack slightly on dark mode. The pack's lead is in restraint, typography and focal point. Baseline screens were Material on iOS (kebab menus, check chips, tonal cards, small inline titles, FABs over content), and the pack moved them to iOS-native large titles and grouped lists.

## Why the pack lost auth

Both judges marked the pack's Apple and Google buttons down for having **no brand marks**. The pack's own rule caused this: it said that if the official asset isn't available, ship the provider name with a neutral glyph. The baseline drew the marks and won. Fixed in 0.3: `screen-auth.md` now requires the provider SDK's button (or the official asset, or the platform's Apple glyph) and calls a logo-less provider button an anti-pattern.

## Weaknesses the judges found in the pack's output, and what changed

| Finding | Seen in | Status |
|---|---|---|
| CTA label truncates at AX-XL ("Record your first…", "Add to…") | paywall, onboarding, detail | **Fixed in 0.3**: `PrimaryButton` / `SecondaryButton` use a minimum height instead of a fixed one, with centred wrapping labels. Verified on the simulator |
| Display headline fills the screen at AX-XL | auth, onboarding, paywall | **Fixed in 0.3**: new `DisplayScale` caps display type at 1.5× (same cap as RN's `Txt`), used in `HeroMetric` and the paywall template. Verified on the simulator |
| Logo-less provider buttons | auth | **Fixed in 0.3** (rule change, see above) |
| Material pill tab indicator on iOS | list | **Fixed in 0.3**: `NavigationBar` has no indicator on iOS in the Quiet theme |
| Check-mark filter chips | list (baseline, and the risk for pack screens) | **Fixed in 0.3**: chip theme is capsule, no check mark, selection by fill. Verified light and dark |
| Pinned footer hides the last content section ("How your trial works") | paywall | Open: covered by the content-inset rule, but agents still miss it in Flutter. Candidate lint rule |
| Flutter overflow stripe at AX-XL | home | Open: the hero row needs `Wrap` / `Flexible`. Candidate for the taste gate |
| Flat near-black dark mode | list, onboarding | Partly addressed by the 0.3 dark-list guidance (rows on `surface`) |
| Big gap under the large title, unclear goal legend | stats | Covered by the 0.3 stats guidance (fixed chart box, labelled goal line) |

The 0.3 fixes have not been re-evaluated yet. The next Flutter run should regenerate only the pack arm, as SwiftUI v0.2 did.
