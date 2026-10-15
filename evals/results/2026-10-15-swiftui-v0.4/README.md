# SwiftUI on pack 0.4 (pre-registered re-run)

The version people install, judged blind. Protocol and publishing rules were fixed before any 0.4 screen existed: [`../../PREREGISTRATION-0.4.md`](../../PREREGISTRATION-0.4.md).

- **With pack:** 8 new screens generated on 0.4 (prompts: [`../../prompts/swiftui-v0.4/generate/`](../../prompts/swiftui-v0.4/generate/)). Sources: [`screens/with-pack-v0.4/`](screens/with-pack-v0.4/).
- **Without pack:** the same baseline captures judged in the 0.1 and 0.2 runs. No regeneration.
- **Judges:** Claude Opus 5.5, one fresh instance per image, with the same prompt template as earlier runs ([`../../prompts/swiftui-v0.4/judge/`](../../prompts/swiftui-v0.4/judge/)). New A/B seed (4041). GPT-6.1 Sol and Grok 4.7 judged the same images via OpenRouter (`tools/judge_external.py`), with no retries; all replies parsed.

## Result (Claude Opus 5.5)

| | |
|---|---|
| Judgments won by the pack | **16 / 16** |
| Prompts won in both orderings | 8 / 8 (sign test p ≈ 0.004) |
| Mean rubric score, with / without | 4.10 / 2.95 |
| Position "A" chosen | 8 of 16 |

| Criterion | With pack | Without |
|---|---|---|
| Focal point | 4.31 | 3.19 |
| Restraint | 4.94 | 2.12 |
| Typography | 4.06 | 2.88 |
| Spacing | 3.94 | 3.50 |
| Platform fit | 3.94 | 3.25 |
| Dark mode | 3.75 | 3.31 |
| Accessibility (AX-XL) | 3.44 | 1.69 |
| Content | 4.44 | 3.62 |

## Flaws the judges found in the pack screens

- **Paywall:** the yearly card shows "Save 0%" instead of about 44%. The generated code computed the saving wrongly. Both judges flagged it, and the pack still won both orderings.
- **Detail:** no back button, and the product hero stays light in dark mode.
- **Settings:** the focal point is weak, because a plain grouped list has no single hero.
- **AX-XL:** paywall content is cut off under the pinned footer, and auth's Google button wraps clumsily.

## Capture notes

- 24 captures, none blank, 8 distinct screens. Captured on the iPhone 17 / iOS 27 simulator (region en_MY, so currency renders as "US$" on both arms, as in every earlier run).
- `home-light` was captured once more before judging. The first capture had a "◀ scene-deeplink-repro" status-bar breadcrumb from a test app left on the simulator. The app was removed and the frame retaken. Nothing else was recaptured.

## GPT-6.1 Sol and Grok 4.7

| Judge | Judgments won by the pack | Prompts won in both orderings | Mean with / without |
|---|---|---|---|
| Claude Opus 5.5 | 16 / 16 | 8 / 8 | 4.10 / 2.95 |
| GPT-6.1 Sol | 16 / 16 | 8 / 8 (p ≈ 0.004) | 4.13 / 2.88 |
| Grok 4.7 | 15 / 16 | 7 / 8, detail split (p ≈ 0.008) | 4.19 / 3.28 |

Raw replies: [`../cross-family-gpt-6.1-sol/2026-10-15-swiftui-v0.4.jsonl`](../cross-family-gpt-6.1-sol/2026-10-15-swiftui-v0.4.jsonl), [`../cross-family-grok-4.7/2026-10-15-swiftui-v0.4.jsonl`](../cross-family-grok-4.7/2026-10-15-swiftui-v0.4.jsonl).

Reproduce: `python3 ../../tools/unblind.py judgments.jsonl ab-key.json`
