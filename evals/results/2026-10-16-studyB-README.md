# Study B: a different harness and model build the screens (Codex + GPT-6.1 Sol)

Pre-registered in [`../PREREGISTRATION-followups.md`](../PREREGISTRATION-followups.md), including the builder amendment that was committed before any Study B screen existed. The question: does the pack still help when the builder is not Claude?

- **Builder:** Codex CLI 0.139.0 running `openai/gpt-6.1-sol` via OpenRouter. Each screen got one fresh `codex exec` session, sandboxed, and all 48 ran once. Config and runner: [`../harness/codex/`](../harness/codex/).
- **Arms:** without the pack, and with pack 0.4.1. The prompts are the same baseline and with-pack prompts as earlier runs, with only the output paths changed ([`../prompts/*-codex/generate/`](../prompts/)).
- **Sources, Codex event logs and checks:** [`2026-10-16-studyB-screens/`](2026-10-16-studyB-screens/).
- **Same protocol as 0.4:** iPhone 17 / iOS 27, light, dark and AX-XL; two orderings; the same judge template and rubric; seeds 5021 / 5022 / 5023.

## Results

### Claude Opus 5.5 (GPT-6.1 Sol and Grok 4.7: pending)

| | Judgments won by the pack | Prompts won in both orderings | Mean, pack / no pack |
|---|---|---|---|
| SwiftUI | 15 / 16 | 7 / 8, auth split (p ≈ 0.008) | 3.90 / 2.90 |
| React Native | 16 / 16 | 8 / 8 (p ≈ 0.004) | 3.95 / 2.77 |
| Flutter | 13 / 16 | 6 / 8, lost detail, auth split (p ≈ 0.06) | 3.88 / 3.29 |
| **Total** | **44 / 48** | **21 / 24** | |

| Criterion (pack / no pack) | SwiftUI | React Native | Flutter |
|---|---|---|---|
| Focal point | 3.94 / 4.06 | 4.31 / 3.50 | 4.12 / 3.50 |
| Restraint | 4.31 / 3.12 | 4.50 / 2.69 | 4.56 / 3.12 |
| Typography | 3.81 / 3.62 | 3.88 / 3.19 | 3.88 / 3.25 |
| Spacing | 3.75 / 3.62 | 4.00 / 3.56 | 3.88 / 3.81 |
| Platform fit | 4.06 / 2.75 | 3.94 / 2.94 | 3.94 / 2.94 |
| Dark mode | 3.94 / 1.12 | 3.81 / 1.00 | 3.44 / 3.94 |
| Accessibility (AX-XL) | 3.50 / 1.06 | 3.38 / 1.56 | 3.19 / 2.12 |
| Content | 3.88 / 3.81 | 3.81 / 3.75 | 4.06 / 3.62 |

## What it shows

- **The pack helps a GPT builder in a different harness, by about as much as it helps Claude.** The pack wins 44 of 48 judgments under Claude. The SwiftUI and React Native results are significant. Flutter is borderline at p ≈ 0.06, which matches Flutter's preview status.
- **On SwiftUI and React Native, a large part of the gap is dark mode and large text.** Most of GPT's no-pack screens on those two platforms hard-code light colours and fixed font sizes. Their dark and AX-XL frames look the same as the light frame, and the judges score them close to 1. That is a real defect, and the pack's guidance is what prevents it. But it means these two platforms measure basic dark-mode and large-text support more than taste.
- **The gap remains without those two criteria.** Averaging only the other six criteria (pack / no pack): SwiftUI 3.96 / 3.50, React Native 4.07 / 3.27, Flutter 4.07 / 3.38. Restraint and platform fit carry most of it, which is what the pack's rules target. The judges' recurring complaints about the no-pack screens are brand headers, taglines, emoji, tilted card stacks, icon tiles and hand-rolled tab bars.
- **Flutter is the fair comparison for looks, and the pack wins it more narrowly.** GPT's no-pack Flutter screens do support dark mode; the judges actually score their tinted dark themes above the pack's flat black (3.94 vs 3.44). The pack still wins 6 prompts outright, but it loses detail both ways. Its AX-XL frame shows a Flutter overflow stripe and loses the size picker.
- **Large text is still the pack's weak spot.** Even when the pack wins, the judges point at large-text problems: subtitles clipped under pinned footers, a React Native list hero amount that collapses to a bare "$" at AX-XL, and wrapped segmented controls. The same weakness showed up in Study A.

## Caveats

- **The builder is also one of the judges.** GPT-6.1 Sol built every screen and will judge them too. It judges blind, but it may favour its own style in either arm. Its results will be reported next to the other two judges.
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
