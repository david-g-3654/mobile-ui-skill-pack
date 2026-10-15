# React Native, list prompt only, on pack 0.4.1

**Not a new eval.** It's one prompt, checking a single question: was the crash the only reason the pack lost the React Native list screen in the [0.4 run](../2026-10-15-react-native-v0.4/README.md)? The 0.4 results stand as published.

- **What changed in 0.4.1:** only the crash. The React Native skill now has Hermes-safe money and number guidance, and there's a new lint rule, MU118. Diff: [`../../pack-0.4-judged/0.4-to-0.4.1.diff`](../../pack-0.4-judged/0.4-to-0.4.1.diff).
- **With pack:** one new generation of the list screen on 0.4.1. It uses the same prompt as 0.4, with only the output path changed ([`../../prompts/react-native-v0.4.1/generate/`](../../prompts/react-native-v0.4.1/generate/)). Source: [`screens/with-pack-v0.4.1/list.tsx`](screens/with-pack-v0.4.1/list.tsx). It uses the skill's `moneyParts` pattern (`format()` plus string split) instead of `formatToParts`.
- **Without pack:** the same baseline list capture as the 0.4 run, from the release build.
- **Rendering:** the same release build harness, iPhone 17 / iOS 27, in light, dark and AX-XL. No crash, and nothing in the device log.
- **Judges:** two orderings, new A/B seed (4044), the same judge prompt template ([`../../prompts/react-native-v0.4.1/judge/`](../../prompts/react-native-v0.4.1/judge/)) and the same three judges.

## Result

| Judge | list_1 | list_2 | Pack mean / baseline mean |
|---|---|---|---|
| Claude Opus 5.5 | pack | pack | 4.19 / 3.31 |
| GPT-6.1 Sol | pack | pack | 3.88 / 3.12 |
| Grok 4.7 | pack | pack | 4.31 / 3.62 |

**6 of 6 judgments go to the pack**, all three judges in both orderings. In the 0.4 run the same prompt went to the baseline in all 6, because the pack screen never rendered. The crash was the only reason the pack lost this screen.

The judges' remaining complaints about the 0.4.1 pack screen: the filter chips clip at AX-XL (Claude, GPT), and the floating search bar covers row content (Claude, GPT). Grok said only that both screens fail at large text, with the pack's layout "the more designed". These are the same kind of large-text issues seen elsewhere, not crashes.

Raw replies: [`../cross-family-gpt-6.1-sol/2026-10-15-react-native-v0.4.1-list.jsonl`](../cross-family-gpt-6.1-sol/2026-10-15-react-native-v0.4.1-list.jsonl), [`../cross-family-grok-4.7/2026-10-15-react-native-v0.4.1-list.jsonl`](../cross-family-grok-4.7/2026-10-15-react-native-v0.4.1-list.jsonl).

Reproduce: `python3 ../../tools/unblind.py judgments.jsonl ab-key.json`
