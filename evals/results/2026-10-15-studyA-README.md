# Study A: the pack vs a one-line design instruction

Pre-registered in [`../PREREGISTRATION-followups.md`](../PREREGISTRATION-followups.md) before any screen existed, including the correction committed before generation. The question: how much of the pack's gain would a single sentence get?

- **"Generic" arm:** the no-instructions baseline prompt plus one sentence: *"Make it look polished and native, and respect large text sizes."* Built by Claude Opus 5.5, 8 prompts × 3 platforms. Sources: [`2026-10-15-studyA-screens-generic/`](2026-10-15-studyA-screens-generic/).
- **Pack arm:** the 0.4 pack screens that were already judged, with React Native list taken from the 0.4.1 regeneration (pre-registered).
- **No-instructions arm:** the same baselines as every earlier run.
- **Same protocol as 0.4:** two orderings, judges blind, same judge template and rubric.

## Results, all three judges

Judgments won by the first-named arm (16 per cell; prompts won in both orderings in brackets):

| | Claude Opus 5.5 | GPT-6.1 Sol | Grok 4.7 |
|---|---|---|---|
| **A1 pack vs one-liner**: SwiftUI | 15 (7/8) | 15 (7/8) | 14 (6/8) |
| React Native | 16 (8/8) | 16 (8/8) | 13 (5/8) |
| Flutter | 16 (8/8) | 16 (8/8) | 13 (6/8, lost 1) |
| **A1 total** | **47 / 48** | **47 / 48** | **40 / 48** |
| **A2 one-liner vs nothing**: SwiftUI | 13 (6/8) | 13 (6/8) | 11 (4/8) |
| React Native | 12 (5/8) | 11 (5/8) | 12 (5/8) |
| Flutter | 8 (3/8, lost 3) | 7 (2/8, lost 3) | 9 (3/8, lost 2) |
| **A2 total** | **33 / 48** | **31 / 48** | **32 / 48** |

Mean rubric score, first arm / second arm:

| | Claude | GPT-6.1 Sol | Grok 4.7 |
|---|---|---|---|
| A1 SwiftUI | 4.06 / 3.23 | 4.13 / 3.26 | 4.12 / 3.42 |
| A1 React Native | 4.05 / 3.23 | 4.12 / 3.15 | 4.14 / 3.51 |
| A1 Flutter | 4.14 / 3.15 | 4.25 / 3.38 | 4.30 / 3.48 |
| A2 SwiftUI | 3.71 / 3.30 | 3.50 / 3.05 | 3.68 / 3.41 |
| A2 React Native | 3.48 / 3.33 | 3.39 / 3.12 | 3.80 / 3.45 |
| A2 Flutter | 3.48 / 3.45 | 3.46 / 3.50 | 3.75 / 3.75 |

## What it shows

- **Every judge prefers the pack over the one-line prompt:** 47, 47 and 40 of 48. A1 is significant on every platform for Claude and GPT, and on SwiftUI and React Native for Grok (Flutter p ≈ 0.06 under Grok).
- **The one-line prompt alone helps a little, inconsistently.** It beats no instructions on SwiftUI and React Native under every judge (11–13 of 16), but none of these reach p < 0.05 (SwiftUI is borderline at p ≈ 0.06 for Claude and GPT). On Flutter it is a coin flip for all three judges.
- **What the one-liner buys is large-text behaviour, not restraint.** Under Claude on SwiftUI, accessibility rises from 1.75 to 3.50 while restraint barely moves (3.06 → 3.38). The judges still fault the one-liner's screens for gradient hero cards, coloured icon tiles and card soup, which is what the pack's rules target.
- **Where the one-liner beats the pack, it is large text.** In 6 of Grok's 8 A1 votes for the one-liner, Grok calls the pack screen cleaner or more restrained but says it breaks at the largest text size: pinned footers covering content, a floating search bar over rows, a clipped chart. The one-liner asks for large-text care explicitly, so this is the pack's real weak spot. It matches the existing Flutter findings.

## Caveats

- **All screens were built by Claude Opus 5.5.** The judges come from three labs, but the builder doesn't.
- **The rubric was written by the pack's author, and it rewards restraint,** which is what the one-liner doesn't add. The plain pairwise question ("which looks like a designer worked on it?") is less exposed to this. A2 means are close even where wins differ.
- **This is one sentence.** A longer, more specific generic prompt might close more of the gap. It's untested.
- **Capture notes:** Flutter generic `home` light and dark show a "◀ EvalRN" status-bar breadcrumb. The judge prompt says to ignore these, and the frames were kept as captured.
- **Scoring keys:** `ab-key.json` maps the arms to the scoring script's two labels (A1: pack = `pack`, one-line = `base`; A2: one-line = `pack`, nothing = `base`). `ab-key.labels.json` has the real arm names.

Folders: [SwiftUI A1](2026-10-15-studyA-swiftui-A1/) · [SwiftUI A2](2026-10-15-studyA-swiftui-A2/) · [React Native A1](2026-10-15-studyA-react-native-A1/) · [React Native A2](2026-10-15-studyA-react-native-A2/) · [Flutter A1](2026-10-15-studyA-flutter-A1/) · [Flutter A2](2026-10-15-studyA-flutter-A2/)
