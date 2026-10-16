# Study B: a different harness and model build the screens (Codex + GPT-6.1 Sol)

Pre-registered in [`../PREREGISTRATION-followups.md`](../PREREGISTRATION-followups.md), including the builder amendment that was committed before any Study B screen existed. The question: does the pack still help when the builder is not Claude?

- **Builder:** Codex CLI 0.139.0 running `openai/gpt-6.1-sol` via OpenRouter. Each screen got one fresh `codex exec` session, sandboxed, and all 48 ran once. Config and runner: [`../harness/codex/`](../harness/codex/).
- **Arms:** without the pack, and with pack 0.4.1. The prompts are the same baseline and with-pack prompts as earlier runs, with only the output paths changed ([`../prompts/*-codex/generate/`](../prompts/)).
- **Sources, Codex event logs and checks:** [`2026-10-16-studyB-screens/`](2026-10-16-studyB-screens/).
- **Same protocol as 0.4:** iPhone 17 / iOS 27, light, dark and AX-XL; two orderings; the same judge template and rubric; seeds 5021 / 5022 / 5023.

## Results, all three judges

Judgments won by the pack (16 per cell; prompts won in both orderings in brackets):

| | Claude Opus 5.5 | GPT-6.1 Sol | Grok 4.7 |
|---|---|---|---|
| SwiftUI | 15 (7/8) | 16 (8/8) | 13 (5/8) |
| React Native | 16 (8/8) | 16 (8/8) | 16 (8/8) |
| Flutter | 13 (6/8, lost 1) | 13 (6/8, lost 1) | 14 (6/8) |
| **Total** | **44 / 48** | **45 / 48** | **43 / 48** |

One-sided sign test over prompts: SwiftUI p ≈ 0.008 / 0.004 / 0.03, React Native p ≈ 0.004 under all three, Flutter p ≈ 0.06 / 0.06 / 0.016 (Claude / GPT / Grok).

Mean rubric score, pack / no pack:

| | Claude | GPT-6.1 Sol | Grok 4.7 |
|---|---|---|---|
| SwiftUI | 3.90 / 2.90 | 4.16 / 2.93 | 4.09 / 3.21 |
| React Native | 3.95 / 2.77 | 4.07 / 2.65 | 4.23 / 2.89 |
| Flutter | 3.88 / 3.29 | 4.07 / 3.33 | 4.13 / 3.45 |

Split by what the scores measure (pack / no pack):

| | Six criteria other than dark mode and large text | Dark mode | Large text (AX-XL) |
|---|---|---|---|
| SwiftUI (Claude · GPT · Grok) | 3.96 / 3.50 · 4.33 / 3.52 · 4.28 / 3.68 | 3.94 / 1.12 · 4.19 / 1.12 · 4.44 / 1.44 | 3.50 / 1.06 · 3.06 / 1.19 · 2.56 / 2.19 |
| React Native | 4.07 / 3.27 · 4.24 / 3.17 · 4.41 / 3.44 | 3.81 / 1.00 · 4.25 / 1.00 · 4.50 / 1.00 | 3.38 / 1.56 · 2.88 / 1.19 · 2.88 / 1.50 |
| Flutter | 4.07 / 3.38 · 4.31 / 3.43 · 4.35 / 3.56 | 3.44 / 3.94 · 4.00 / 4.50 · 4.31 / 4.44 | 3.19 / 2.12 · 2.69 / 1.56 · 2.62 / 1.81 |

Per-criterion scores are in each folder's `summary.txt` (Claude) and in the raw replies: [`cross-family-gpt-6.1-sol/`](cross-family-gpt-6.1-sol/), [`cross-family-grok-4.7/`](cross-family-grok-4.7/) (`2026-10-16-studyB-*.jsonl`). All 96 external replies parsed; no retries.

## What it shows

- **The pack helps a GPT builder in a different harness, by about as much as it helps Claude.** The pack wins 44, 45 and 43 of 48 judgments under Claude, GPT and Grok. React Native is significant under every judge and SwiftUI under every judge. Flutter is significant only under Grok (p ≈ 0.06 under Claude and GPT), which matches Flutter's preview status.
- **The builder doesn't favour its own unassisted screens.** GPT-6.1 Sol built both arms and, judging blind, prefers the pack-guided ones in 45 of 48, the most of any judge.
- **On SwiftUI and React Native, a large part of the gap is dark mode and large text.** Most of GPT's no-pack screens on those two platforms hard-code light colours and fixed font sizes. Their dark and AX-XL frames look the same as the light frame, and the judges score them close to 1. That is a real defect, and the pack's guidance is what prevents it. But it means these two platforms measure basic dark-mode and large-text support more than taste.
- **The gap remains without those two criteria.** On the other six criteria the pack leads on every platform under every judge, by 0.5 to 1.1 points (table above). Restraint and platform fit carry most of it, which is what the pack's rules target. The judges' recurring complaints about the no-pack screens are brand headers, taglines, emoji, tilted card stacks, icon tiles and hand-rolled tab bars.
- **Flutter is the fair comparison for looks, and the pack wins it more narrowly.** GPT's no-pack Flutter screens do support dark mode, and all three judges score their tinted dark themes slightly above the pack's (for example 3.94 vs 3.44 under Claude). The pack still wins 6 prompts outright under every judge. Claude and GPT give detail to the baseline both ways; the pack's AX-XL frame shows a Flutter overflow stripe and loses the size picker.
- **Large text is still the pack's weak spot.** The pack's AX-XL scores are its lowest criterion under GPT and Grok (2.6–3.1). All five of Grok's votes for the no-pack screen cite the pack breaking at large text, as in Study A. Even when the pack wins, the judges point at large-text problems: subtitles clipped under pinned footers, a React Native list hero amount that collapses to a bare "$" at AX-XL, and wrapped segmented controls. The same weakness showed up in Study A.

## Caveats

- **The builder is also one of the judges.** GPT-6.1 Sol built every screen and judged them blind. Its verdicts are close to the other two judges' (45 vs 44 and 43), so there's no sign it favoured either arm.
- **The rubric was written by the pack's author.** Two of its criteria are dark mode and large-text support, and the no-pack screens on two platforms skip both.
- **Lint is not a result here.** The pack screens all lint clean and the no-pack screens don't, but the linter checks the pack's own rules ([`2026-10-16-studyB-screens/checks/`](2026-10-16-studyB-screens/checks/)).
- **Builds:** all 48 screens typecheck or analyze clean when checked afterwards, including the 16 SwiftUI screens whose agents could not typecheck inside the sandbox. No screen crashed, and no React Native screen uses the Intl APIs that are missing on Hermes.
- **Generation notes:**
  - One run (Flutter, with pack, detail) dropped its stream once. Codex reconnected on its own, and the run produced output, so it stands.
  - No agent opened another arm's screen. Some pack agents listed the filenames in their workspace.
  - Codex wrote its own state into the config folder during the run: databases, a plugin cache, and a "trusted" entry in `config.toml` for each workspace. The runtime state was left out of the repo, and `config.toml` is the committed, fingerprinted version. The trust entries applied to both arms. No workspace has an AGENTS.md or project config for trust to unlock, and no agent used one of Codex's bundled skills. The pack agents searched parent folders for an AGENTS.md, but no folder they checked has one.
  - Codex's event logs don't record the model name. The model comes from the committed config and the author's OpenRouter account.
  - Token totals: 14.9M input (13.2M cached), 289k output.
- **Capture:** React Native ran from a release build and Flutter from debug builds, as in earlier runs, which is why Flutter shows overflow stripes. A few light frames show a "◀" back-to-app status-bar label, which the judge prompt says to ignore.
- **Harness slip, fixed before judging:** the first version of the judge prompts quoted the home-screen request for every pair. This was caught and rebuilt from each prompt's own template before any judge ran. Each published prompt differs from its template only in the two file paths.

Folders: [SwiftUI](2026-10-16-studyB-swiftui/) · [React Native](2026-10-16-studyB-react-native/) · [Flutter](2026-10-16-studyB-flutter/)

Reproduce: `python3 ../tools/unblind.py 2026-10-16-studyB-<platform>/judgments.jsonl 2026-10-16-studyB-<platform>/ab-key.json`
