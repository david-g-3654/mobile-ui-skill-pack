# Cross-family judging: Grok 4.7 re-judges every run

A third judge from a third lab (xAI's `x-ai/grok-4.7` via OpenRouter) got the same 80 blind pair images, user requests, [rubric](../../rubric.md) and output schema as the Claude and GPT judges, through [`../../tools/judge_external.py`](../../tools/judge_external.py) `--all`. That was one request per image, with no retries; all 80 replies parsed. The raw replies are the `<run>.jsonl` files here. (A Gemini run was planned, but Gemini is restricted on the OpenRouter account used, so Grok took its place.)

## Result: the strictest of the three judges, and the clearest view of the Flutter gap

| Run | Claude Opus 5.5 | GPT-6.1 Sol | **Grok 4.7** | Grok: prompts won in both orderings | Grok: sign test | Grok mean, with / without |
|---|---|---|---|---|---|---|
| SwiftUI 0.1 | 16 / 16 | 15 / 16 | **14 / 16** | 6 / 8 (onboarding, stats split) | p ≈ 0.016 | 4.07 / 3.28 |
| SwiftUI 0.2 | 16 / 16 | 16 / 16 | **16 / 16** | 8 / 8 | p ≈ 0.004 | 4.22 / 3.19 |
| React Native | 16 / 16 | 16 / 16 | **16 / 16** | 8 / 8 | p ≈ 0.004 | 4.21 / 3.17 |
| Flutter 0.2+ | 14 / 16 | 13 / 16 | **13 / 16** | 6 / 8 (lost auth, list split) | p ≈ 0.06 | 4.16 / 3.50 |
| Flutter 0.3 | 15 / 16 | 15 / 16 | **12 / 16** | 6 / 8 (lost auth and stats) | **p ≈ 0.14** | 4.15 / 3.52 |
| **All** | **77 / 80** | **75 / 80** | **71 / 80** | | | |

- **Agreement:** all three judges agree on 72 of 80 judgments. Grok agrees with Claude on 74 and with GPT on 72.
- **Majority vote:** taking two of three judges, the pack wins 77 of 80 judgments.
- **Position check:** Grok chose "A" 6–8 times per run of 16.

## Where Grok disagrees, and what it's pointing at

Grok gave the baseline 8 judgments the other judges gave the pack. In 5 of them, the reason it gave was the pack screen failing at the largest text size:

- **Flutter 0.3 stats, both orderings:** the pack screen "clips the chart and loses lower stats" at AX-XL, while the baseline "reflows cleanly". This is the chart-at-large-text problem. The pack now handles it in its components (see 0.4) as well as in the guidance, but this judged screen predates that.
- **SwiftUI 0.1 stats:** the pack screen "overflows the delta line". That was fixed in 0.2/0.3.
- **Flutter 0.3 auth:** Grok preferred the baseline's complete sign-in form over the pack screen's empty upper half. The Claude judges had raised the same point at low confidence.
- **SwiftUI 0.1 onboarding** and **Flutter 0.2+ list:** genuine taste disagreements. Grok preferred the baseline's richer dark surfaces or balance card.

On Flutter, Grok's accessibility scores barely separate the arms: 2.44 for the pack against 2.38 for the baseline on 0.3. On SwiftUI and React Native, the pack leads by about a point (2.88–2.94 against 1.44–1.88).

## What this adds

With three judges from three labs, "Claude grading Claude" is settled. Restraint is the gap every judge sees, at about +2 everywhere. **SwiftUI and React Native** wins hold up under every judge (16/16 on the current versions). **Flutter** is a smaller win that one strict judge doesn't find significant, and the reasons it gives point at large-text behaviour, which is exactly the area the pack has been fixing. None of this replaces human raters ([`../../HUMAN_RATING.md`](../../HUMAN_RATING.md)).

## Pack 0.4 (pre-registered run, 2026-10-15)

Grok 4.7 judged the 48 new blind images (3 platforms × 8 prompts × 2 orderings) the same way: one request per image, no retries, every reply parsed. Raw replies: `2026-10-15-<platform>-v0.4.jsonl` in this folder. Results and reasons are in each run's README: [SwiftUI](../2026-10-15-swiftui-v0.4/README.md), [React Native](../2026-10-15-react-native-v0.4/README.md), [Flutter](../2026-10-15-flutter-v0.4/README.md).
