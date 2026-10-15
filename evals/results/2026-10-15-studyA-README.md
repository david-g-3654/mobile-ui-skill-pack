# Study A: the pack vs a one-line design instruction

Pre-registered in [`../PREREGISTRATION-followups.md`](../PREREGISTRATION-followups.md) before any screen existed, including the correction committed before generation. The question: how much of the pack's gain would a single sentence get?

- **"Generic" arm:** the no-instructions baseline prompt plus one sentence: *"Make it look polished and native, and respect large text sizes."* Built by Claude Opus 5.5, 8 prompts × 3 platforms. Sources: [`2026-10-15-studyA-screens-generic/`](2026-10-15-studyA-screens-generic/).
- **Pack arm:** the 0.4 pack screens that were already judged, with React Native list taken from the 0.4.1 regeneration (pre-registered).
- **No-instructions arm:** the same baselines as every earlier run.
- **Same protocol as 0.4:** two orderings, judges blind, same judge template and rubric.

## Results (Claude Opus 5.5; GPT-6.1 Sol and Grok 4.7 pending)

| | **A1: pack vs one-line prompt** | **A2: one-line prompt vs no instructions** |
|---|---|---|
| SwiftUI | **15 / 16**, 7/8 prompts (detail split), p ≈ 0.008 | 13 / 16, 6/8 prompts, p ≈ 0.06 |
| React Native | **16 / 16**, 8/8 prompts, p ≈ 0.004 | 12 / 16, 5/8 prompts, p ≈ 0.11 |
| Flutter | **16 / 16**, 8/8 prompts, p ≈ 0.004 | 8 / 16, 3/8 vs 3/8, p ≈ 0.66 |
| All | **47 / 48** | 33 / 48 |

Mean rubric score with / without:

| | A1: pack / one-line | A2: one-line / nothing |
|---|---|---|
| SwiftUI | 4.06 / 3.23 | 3.71 / 3.30 |
| React Native | 4.05 / 3.23 | 3.48 / 3.33 |
| Flutter | 4.14 / 3.15 | 3.48 / 3.45 |

## What it shows (under the Claude judge)

- **The one-line prompt gets a little of the gain, and the pack gets the rest.** The one-liner beats no instructions on SwiftUI and slightly on React Native, and does nothing on Flutter. The pack beats the one-liner on 47 of 48 judgments.
- **What the one-liner buys is mostly large-text behaviour.** On SwiftUI A2, accessibility rises from 1.75 to 3.50 but restraint barely moves (3.06 → 3.38). On React Native, accessibility rises from 1.56 to 2.56 and restraint doesn't change. The judges' reasons for the generic screens still mention gradient hero cards, colored icon tiles and card soup, which the pack's rules target.
- **The pack's gain is mostly restraint and focal hierarchy.** In A1, restraint is 4.56 against 2.44 on SwiftUI, and similar on the other platforms.

## Caveats

- **The judge is Claude, from the same family as the builder.** GPT-6.1 Sol and Grok 4.7 have not judged these images yet.
- **The rubric was written by the pack's author, and it rewards restraint,** which is what the one-liner doesn't add. The plain pairwise question ("which looks like a designer worked on it?") is less exposed to this. A2 means are close even where wins differ.
- **This is one sentence.** A longer, more specific generic prompt might close more of the gap. It's untested.
- **Capture notes:** Flutter generic `home` light and dark show a "◀ EvalRN" status-bar breadcrumb. The judge prompt says to ignore these, and the frames were kept as captured.
- **Scoring keys:** `ab-key.json` maps the arms to the scoring script's two labels (A1: pack = `pack`, one-line = `base`; A2: one-line = `pack`, nothing = `base`). `ab-key.labels.json` has the real arm names.

Folders: [SwiftUI A1](2026-10-15-studyA-swiftui-A1/) · [SwiftUI A2](2026-10-15-studyA-swiftui-A2/) · [React Native A1](2026-10-15-studyA-react-native-A1/) · [React Native A2](2026-10-15-studyA-react-native-A2/) · [Flutter A1](2026-10-15-studyA-flutter-A1/) · [Flutter A2](2026-10-15-studyA-flutter-A2/)
