# Cross-family judging: GPT-6.1 Sol re-judges every run

**Why:** every published judgment so far came from Claude Opus 5.5, the same model family that generated the screens. This run hands the identical blind material to a model from another family.

**Setup:** `openai/gpt-6.1-sol` via OpenRouter, run with [`../../tools/judge_external.py`](../../tools/judge_external.py) `--all`. It judged the same 80 blind pair images (5 runs × 8 prompts × 2 orderings), with the same user request, the same [rubric](../../rubric.md) and the same output schema as the Claude judges. It never saw `ab-key.json` and was never told a skill pack existed. One request per image, no retries or cherry-picking; all 80 replies parsed. The raw replies are the `<run>.jsonl` files in this folder.

## Result: it agrees with the Claude judges on 78 of 80 judgments

| Run | Claude Opus 5.5: pack wins | GPT-6.1 Sol: pack wins | GPT: prompts won in both orderings | GPT: sign test | GPT mean, with / without |
|---|---|---|---|---|---|
| SwiftUI 0.1 | 16 / 16 | 15 / 16 | 7 / 8 (auth split) | p ≈ 0.008 | 3.98 / 2.93 |
| SwiftUI 0.2 | 16 / 16 | 16 / 16 | 8 / 8 | p ≈ 0.004 | 4.15 / 2.88 |
| React Native | 16 / 16 | 16 / 16 | 8 / 8 | p ≈ 0.004 | 4.16 / 2.92 |
| Flutter 0.2+ | 14 / 16 | 13 / 16 | 6 / 8 (lost auth, onboarding split) | **p ≈ 0.06** | 4.01 / 3.41 |
| Flutter 0.3 | 15 / 16 | 15 / 16 | 7 / 8 (auth split) | p ≈ 0.008 | 4.14 / 3.37 |
| **All** | **77 / 80** | **75 / 80** | | | |

Position check: GPT chose "A" 7–8 times in each run of 16.

**The two disagreements** both go against the pack, and both come down to large text:
- SwiftUI 0.1, auth: GPT preferred the baseline because the pack screen's title was "visibly cut off" at AX-XL.
- Flutter 0.2+, onboarding: GPT preferred the baseline because "AX-XL clips [the pack's] primary CTA".

Both are failures the later pack versions fixed: the unpinned footer in 0.2, and wrapping buttons plus the display cap in 0.3. Neither disagreement involves a current version.

## How GPT's scores differ from Claude's

- **Same shape:** the biggest gap is restraint (pack 4.56–5.00, baseline 2.19–2.81), followed by focal hierarchy and typography.
- **Harsher on large text, for both sides:** GPT's accessibility scores are lower overall (pack 2.31–3.00, baseline 1.06–2.06) than Claude's. The pack still leads on accessibility in every run.
- **Flutter 0.2+ is not significant on its own** under GPT (6 of 7 decided prompts, p ≈ 0.06). That matches the earlier finding that 0.2 was the pack's weakest Flutter version. On 0.3, GPT's Flutter result is 15/16 and significant.
- **Dark mode on Flutter:** GPT, like Claude, scores the Material 3 baseline about level with the pack (4.38 vs 4.00 on 0.2+, 4.19 vs 4.25 on 0.3).

## What this does and doesn't settle

It removes the main objection to the model-judged numbers. A judge from a different family, trained independently, reaches the same verdict on 78 of the same 80 blind comparisons (98%). It doesn't make the result a human one: both judges are language models reading screenshots against the same rubric. Human ratings are still open ([`../../HUMAN_RATING.md`](../../HUMAN_RATING.md)).

A second cross-family judge, Grok 4.7, has since re-judged the same images and is stricter: 71/80 ([results](../cross-family-grok-4.7/README.md)). Gemini was planned but is restricted on the OpenRouter account used.

## Pack 0.4 (pre-registered run, 2026-10-15)

GPT-6.1 Sol judged the 48 new blind images (3 platforms × 8 prompts × 2 orderings) the same way: one request per image, no retries, every reply parsed. Raw replies: `2026-10-15-<platform>-v0.4.jsonl` in this folder. Results and reasons are in each run's README: [SwiftUI](../2026-10-15-swiftui-v0.4/README.md), [React Native](../2026-10-15-react-native-v0.4/README.md), [Flutter](../2026-10-15-flutter-v0.4/README.md).
