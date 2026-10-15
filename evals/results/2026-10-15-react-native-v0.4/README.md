# React Native (Expo SDK 57) on pack 0.4 (pre-registered re-run)

The version people install, judged blind. Protocol and publishing rules were fixed before any 0.4 screen existed: [`../../PREREGISTRATION-0.4.md`](../../PREREGISTRATION-0.4.md).

- **With pack:** 8 new screens generated on 0.4 (prompts: [`../../prompts/react-native-v0.4/generate/`](../../prompts/react-native-v0.4/generate/)). Sources: [`screens/with-pack-v0.4/`](screens/with-pack-v0.4/).
- **Without pack:** the same baseline code as the earlier RN run. As pre-registered, it was **recaptured from a release build**, so neither side shows Expo Go's dev-tools button or warning bars.
- **Both arms** come from one release build of the eval app (`harness/registry.tsx`), with the screen picked by a `-screen` launch argument ([`harness/rn_render04.sh`](harness/rn_render04.sh)).
- **Judges:** Claude Opus 5.5, one fresh instance per image, with the same prompt template as earlier runs ([`../../prompts/react-native-v0.4/judge/`](../../prompts/react-native-v0.4/judge/)). New A/B seed (4042). GPT-6.1 Sol and Grok 4.7 judged the same images via OpenRouter (`tools/judge_external.py`), with no retries; all replies parsed.

## Result (Claude Opus 5.5)

| | |
|---|---|
| Judgments won by the pack | **14 / 16** |
| Prompts won in both orderings | 7 / 8, lost **list** (sign test p ≈ 0.035) |
| Mean rubric score, with / without | 3.67 / 3.15 (the crashed list screen scores 1 on every criterion) |
| Position "A" chosen | 8 of 16 |

| Criterion | With pack | Without |
|---|---|---|
| Focal point | 3.62 | 3.56 |
| Restraint | 4.25 | 2.81 |
| Typography | 3.62 | 3.56 |
| Spacing | 3.50 | 3.56 |
| Platform fit | 3.69 | 3.06 |
| Dark mode | 3.62 | 2.75 |
| Accessibility (AX-XL) | 3.06 | 1.56 |
| Content | 4.00 | 4.31 |

Leaving out the list pair, the pack wins 14 of the other 14 judgments. That figure is for context only. The pre-registered result is the 14 / 16 above.

## The lost prompt: the pack's list screen crashes on launch

The with-pack transactions screen typechecks and lints clean, but in a release build it throws `TypeError: undefined is not a function` on its first render, and iOS returns to the home screen ([`crash/list-unhandled-exception.log`](crash/list-unhandled-exception.log)). The cause is `Intl.NumberFormat.prototype.formatToParts()`. TypeScript's types include it, but Hermes on iOS doesn't implement it. The pack's guidance never suggests `formatToParts`; the agent added it. The pack didn't prevent it either: neither the linter nor the RN skill warns about Intl APIs that Hermes is missing.

As pre-registered, the screen was not regenerated or patched. **Follow-up on 0.4.1** (the crash fix): the same prompt, generated and judged once more on its own, went to the pack in both orderings under all three judges, 6/6 ([`../2026-10-15-react-native-v0.4.1-list/`](../2026-10-15-react-native-v0.4.1-list/README.md)). That run is reported next to these results and doesn't replace them. The judges saw what a user would see, three frames of the iOS home screen, and gave the baseline both orderings.

The judges' other complaints about the pack screens:
- **Stats at AX-XL:** the 12.6 hero number disappears and only "mi" is left.
- **Paywall and onboarding at AX-XL:** content is clipped under the pinned footer.
- **Detail:** the colour row clips, there's no back button, and the title hierarchy is weaker than the baseline's.

## Capture notes

- **Capture:** 48 frames (base and pack), none blank, with 8 distinct screens per arm.
- **Simulator shutdown:** the simulator shut down during the first capture attempt, after 3 baseline screens. The capture was restarted from scratch before anything was judged.
- **Missed by the automatic check:** the blank-frame check didn't catch the crashed list screen, because the iOS home screen isn't blank. It was found by eye on the contact sheet, then confirmed in the device log.

## GPT-6.1 Sol and Grok 4.7

| Judge | Judgments won by the pack | Prompts won in both orderings | Mean with / without |
|---|---|---|---|
| Claude Opus 5.5 | 14 / 16 | 7 / 8, lost list | 3.67 / 3.15 |
| GPT-6.1 Sol | 14 / 16 | 7 / 8, lost list (p ≈ 0.035) | 3.75 / 2.95 |
| Grok 4.7 | 14 / 16 | 7 / 8, lost list (p ≈ 0.035) | 3.85 / 3.20 |

All three judges agree exactly on the outcome: the pack wins every prompt except the one that crashes.

Raw replies: [`../cross-family-gpt-6.1-sol/2026-10-15-react-native-v0.4.jsonl`](../cross-family-gpt-6.1-sol/2026-10-15-react-native-v0.4.jsonl), [`../cross-family-grok-4.7/2026-10-15-react-native-v0.4.jsonl`](../cross-family-grok-4.7/2026-10-15-react-native-v0.4.jsonl).

Reproduce: `python3 ../../tools/unblind.py judgments.jsonl ab-key.json`
