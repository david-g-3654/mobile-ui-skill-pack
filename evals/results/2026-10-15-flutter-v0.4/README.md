# Flutter on pack 0.4 (pre-registered re-run)

The version people install, judged blind. Protocol and publishing rules were fixed before any 0.4 screen existed: [`../../PREREGISTRATION-0.4.md`](../../PREREGISTRATION-0.4.md).

- **With pack:** 8 new screens generated on 0.4 (prompts: [`../../prompts/flutter-v0.4/generate/`](../../prompts/flutter-v0.4/generate/)). Sources: [`screens/with-pack-v0.4/`](screens/with-pack-v0.4/).
- **Without pack:** the same baseline captures as the 0.2+ and 0.3 runs, with no regeneration.
- **Rendering:** both arms run as iOS apps on the iPhone 17 / iOS 27 simulator.
- **Judges:** Claude Opus 5.5, one fresh instance per image, with the same prompt template as earlier runs ([`../../prompts/flutter-v0.4/judge/`](../../prompts/flutter-v0.4/judge/)). The A/B order uses a new seed (4043). GPT-6.1 Sol and Grok 4.7 judged the same images via OpenRouter (`tools/judge_external.py`), with no retries; all replies parsed.

## Result (Claude Opus 5.5)

| | |
|---|---|
| Judgments won by the pack | **15 / 16** |
| Prompts won in both orderings | 7 / 8, with auth split 1–1 (sign test p ≈ 0.008) |
| Mean rubric score, with / without | 4.11 / 3.17 |
| Position "A" chosen | 7 of 16 |

| Criterion | With pack | Without |
|---|---|---|
| Focal point | 4.44 | 3.31 |
| Restraint | 4.69 | 2.75 |
| Typography | 4.00 | 3.12 |
| Spacing | 3.94 | 3.31 |
| Platform fit | 4.19 | 2.94 |
| Dark mode | 3.94 | 3.56 |
| Accessibility (AX-XL) | 3.38 | 2.38 |
| Content | 4.31 | 4.00 |

## Compared with 0.3 (same baseline, same prompts)

| | 0.3 | 0.4 |
|---|---|---|
| Claude: judgments won | 15 / 16 | 15 / 16 |
| Mean with / without | 4.07 / 3.24 | 4.11 / 3.17 |
| Accessibility (AX-XL), pack | 3.31 | 3.38 |
| Stats prompt | won both | won both |
| Auth prompt | split | split |

- **Stats:** on 0.3, Grok gave stats to the baseline in both orderings because the pack's chart "clips at AX-XL". The 0.4 screen uses `QBarChart`, and at AX-XL its axis shows single letters (M T W T F S S) instead of clipping. Claude gave the pack both orderings, and one judge noted that the baseline handles AX-XL better on this prompt (the week label and the change line wrap awkwardly). Grok split it this time (pack in one ordering, baseline in the other), and still says the chart clips at large text (see below).
- **Auth is still the soft spot.** The pack screen puts all three providers in a thumb-zone footer and leaves the email form for a later step. One ordering preferred that; the other preferred the baseline's complete email form and called the middle of the pack screen "a large empty gap". Grok raised the same point on 0.3.

## Capture notes

- **Captures:** 24 frames, none blank, 8 distinct screens.
- **Build:** a separate debug build for each screen (`--dart-define=EVAL_SCREEN`), using the same harness as 0.3 ([`harness/`](harness/)).

## GPT-6.1 Sol and Grok 4.7

| Judge | Judgments won by the pack | Prompts won in both orderings | Mean with / without |
|---|---|---|---|
| Claude Opus 5.5 | 15 / 16 | 7 / 8, auth split (p ≈ 0.008) | 4.11 / 3.17 |
| GPT-6.1 Sol | 14 / 16 | 6 / 8, auth and stats split (p ≈ 0.016) | 4.21 / 3.39 |
| Grok 4.7 | **11 / 16** | 4 / 8: lost auth; detail, paywall and stats split (**p ≈ 0.19**) | 4.26 / 3.55 |

**Flutter is still the weak spot.** Grok gave Flutter 0.3 12/16 and gives 0.4 11/16. Neither is significant on its own. What Grok held against the pack:
- **Auth, both orderings:** it preferred the baseline's complete email form and designed dark mode. It said the pack screen's dark secondary buttons "nearly vanish", and that large text drops Google, email and the legal copy below the fold.
- **Stats, one ordering:** the chart "clips at large text". `QBarChart` keeps its labels from colliding, but at AX-XL the chart starts at the bottom edge and is partly cut off. In the other ordering Grok preferred the pack.
- **Paywall, one ordering:** the trial timeline is hidden under the pinned button. Grok still noted that the baseline drops the requested monthly/yearly choice.
- **Detail, one ordering:** the oversized button overlaps content at large text.

The pack still leads every judge on the mean (+0.7 to +0.9). The gap is in pairwise preference, and it comes from large text and the Material baseline's strong dark mode.

Raw replies: [`../cross-family-gpt-6.1-sol/2026-10-15-flutter-v0.4.jsonl`](../cross-family-gpt-6.1-sol/2026-10-15-flutter-v0.4.jsonl), [`../cross-family-grok-4.7/2026-10-15-flutter-v0.4.jsonl`](../cross-family-grok-4.7/2026-10-15-flutter-v0.4.jsonl).

Reproduce: `python3 ../../tools/unblind.py judgments.jsonl ab-key.json`
