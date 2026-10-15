# Eval results

Each run uses the same 8 prompts (home, settings, paywall, onboarding, detail, list, stats, auth). One agent generates each screen with the pack and one without. Each screen is rendered on an iPhone 17 / iOS 27 simulator in light, dark and accessibility-XL text, then judged blind and pairwise by LLM judges, twice per prompt with the A/B positions swapped. Rubric: [`../rubric.md`](../rubric.md). Per-screen scores: [`../scores.csv`](../scores.csv).

Each run is **8 prompts × 2 orderings = 16 blind judgments** by Claude Opus 5.5, with one generation per arm. Method, limits and every prompt verbatim: [`../METHOD.md`](../METHOD.md).

## Pack 0.4, pre-registered (the version you install)

Run on 2026-10-15 under [`../PREREGISTRATION-0.4.md`](../PREREGISTRATION-0.4.md), with the commitment to publish whatever it showed. Same 8 prompts, both orderings, new with-pack generations on 0.4, the same baselines (React Native's recaptured from a release build). Every input fingerprint matched at publication (`tools/verify_prereg.py`).

| Platform | Judgments won by the pack (Claude) | Prompts won in both orderings | Mean with / without | GPT-6.1 Sol | Grok 4.7 | Write-up |
|---|---|---|---|---|---|---|
| SwiftUI | **16 / 16** | 8 / 8 (p ≈ 0.004) | 4.10 / 2.95 | 16 / 16 | 15 / 16 | [2026-10-15-swiftui-v0.4](2026-10-15-swiftui-v0.4/README.md) |
| React Native | **14 / 16** | 7 / 8, lost list (p ≈ 0.035) | 3.67 / 3.15 | 14 / 16 | 14 / 16 | [2026-10-15-react-native-v0.4](2026-10-15-react-native-v0.4/README.md) |
| Flutter | **15 / 16** | 7 / 8, auth split (p ≈ 0.008) | 4.11 / 3.17 | 14 / 16 | **11 / 16** (p ≈ 0.19) | [2026-10-15-flutter-v0.4](2026-10-15-flutter-v0.4/README.md) |

- **Across the three judges** (48 judgments each): Claude gives the pack 45, GPT 44 and Grok 40. All three agree on 43, and a two-of-three majority gives the pack 44 (SwiftUI 16, React Native 14, Flutter 14).
- **Flutter is still the weak spot.** Grok gives Flutter 0.4 11/16, slightly below the 12/16 it gave 0.3, and not significant on its own (4 prompts won in both orderings, 1 lost, 3 split). It gave the baseline auth in both orderings, and one ordering each of detail, paywall and stats. In those, it mostly preferred the Material baseline's dark-mode surfaces and complete forms, and said the pack screens clipped or overlapped at AX-XL.
- **0.4.1 follow-up (one prompt, not a new eval):** the React Native list prompt was regenerated on 0.4.1, the crash fix, and judged in both orderings: pack 6/6 across Claude, GPT and Grok ([results](2026-10-15-react-native-v0.4.1-list/README.md)).
- **React Native's lost prompt is a crash.** The pack-built list screen calls `Intl.NumberFormat.formatToParts`, which Hermes doesn't implement, so the release build exits at launch and the judges saw the iOS home screen. As pre-registered, the screen was not regenerated.
- **Flutter's stats prompt,** the one Grok gave to the baseline on 0.3 over a clipping chart, went to the pack in both orderings with `QBarChart`. Auth is split again, as on 0.3.

## Earlier runs (kept in the record)

| Run | Pack | Judgments won by the pack | Prompts won in both orderings | Mean with / without | Median lint errors with / without | Write-up |
|---|---|---|---|---|---|---|
| SwiftUI | 0.1 | **16 / 16** | 8 / 8 | 4.01 / 3.01 | 0 / 5 | [2026-10-14-swiftui](2026-10-14-swiftui/README.md) |
| SwiftUI (pack arm regenerated) | 0.2 | **16 / 16** | 8 / 8 | 4.04 / 3.02 | 0 / 5 | `2026-10-14-swiftui-v0.2/summary.txt` |
| React Native (Expo SDK 57) | 0.2+ | **16 / 16** | 8 / 8 | 4.05 / 3.11 | 0 / 26 | [2026-10-14-react-native](2026-10-14-react-native/README.md) |
| Flutter (rendered on iOS) | 0.2+ | **14 / 16** | 7 / 8 | 3.95 / 3.27 | 0 / 9 | [2026-10-14-flutter](2026-10-14-flutter/README.md) |
| Flutter (pack arm regenerated) | 0.3 | **15 / 16** | 7 / 8 (auth split 1–1) | 4.07 / 3.24 | 0 / 9 | [2026-10-14-flutter-v0.3](2026-10-14-flutter-v0.3/README.md) |

"0.2+" means 0.2 plus the `Swatch`, MU116/MU117 and display-cap changes released in 0.3. Judges chose position "A" 8 of 16 times in every run except Flutter 0.3 (7 of 16).

## Per criterion, with pack / without

| Criterion | SwiftUI 0.2 | React Native | Flutter 0.3 |
|---|---|---|---|
| Focal point | 3.94 / 3.38 | 3.88 / 3.56 | 4.38 / 3.38 |
| Restraint | 4.69 / 2.25 | 4.62 / 2.75 | 4.69 / 2.88 |
| Typography | 4.00 / 2.88 | 4.00 / 3.38 | 4.12 / 3.31 |
| Spacing | 3.88 / 3.62 | 3.81 / 3.56 | 3.88 / 3.44 |
| Platform fit | 4.00 / 3.31 | 3.94 / 3.12 | 4.19 / 3.06 |
| Dark mode | 3.81 / 3.31 | 3.81 / 2.88 | 3.75 / 3.62 |
| Accessibility (AX-XL) | 3.50 / 1.69 | 3.75 / 1.56 | 3.31 / 2.31 |
| Content | 4.50 / 3.75 | 4.56 / 4.06 | 4.25 / 3.94 |

## What this shows

- **Restraint is the pack's biggest and most consistent gain** (about +2 on every platform). Gradient cards, coloured icon tiles and card soup disappear.
- **Accessibility at large text gains a lot on SwiftUI and RN, and less on Flutter.** On 0.2, Flutter's fixed-height buttons and uncapped display type held it to 2.81. After the 0.3 fixes it reached 3.31.
- **The Flutter baseline is the strongest** (Material 3 gives a coherent theme and dark mode for free). Dark mode is nearly level (3.75 / 3.62), so Flutter is where the pack has to earn its keep.
- **The one lost prompt (Flutter auth on 0.2) was the pack's own fault.** A rule told agents to drop provider logos when no asset was at hand. On 0.3, with the marks back, it split 1–1.

## Ship bar status (v1.0: ≥ 80% wins, mean ≥ 4.0, median lint 0, no compile regression)

On 0.4, the version you install (Claude judge):

| | SwiftUI | React Native | Flutter |
|---|---|---|---|
| Wins ≥ 80% | ✅ 100% | ✅ 88% | ✅ 94% |
| Mean ≥ 4.0 | ✅ 4.10 | ❌ 3.67 (the crashed screen scores 1s; 4.05 on the other 7 prompts) | ✅ 4.11 |
| Median lint 0 | ✅ | ✅ | ✅ |
| No compile regression | ✅ 8/8 | ⚠️ 8/8 compile, **1 crashes at launch** | ✅ 8/8 |

React Native misses the bar on 0.4. The fix belongs in the pack, for example a lint rule or an RN skill note about Intl APIs that Hermes lacks. It ships in a later version, and that version gets its own judged run. The 0.4 result stays as published.

## Caveats that apply to every run

**Cross-family check:** two judges from other labs re-judged all 80 blind images. GPT-6.1 Sol gives the pack 75/80 and agrees with Claude on 78; Grok 4.7 gives it 71/80 and agrees with Claude on 74. Grok finds the Flutter 0.3 win not significant on its own (12/16), mostly over large-text failures ([GPT](cross-family-gpt-6.1-sol/README.md), [Grok](cross-family-grok-4.7/README.md)). Human ratings are still pending.

Small sample (8 prompts, one generation per arm). LLM judges (Claude Opus 5.5, cross-checked by GPT-6.1 Sol and Grok 4.7), not humans. A rubric written alongside the pack that shares its values. Lint counts that favour the pack by construction, because pack agents ran the linter. No human raters yet. Judged screens are rendered on iOS only; Android is checked separately on the templates (see the main README). The plain pairwise question ("which looks like a designer worked on it?") is the least exposed to the rubric bias, and it agrees with the scores.
