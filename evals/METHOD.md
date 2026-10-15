# How the evals were run, and what they can't tell you

Every number in `results/` comes from the procedure below. Everything needed to rerun or challenge it is in this folder: the prompts, the rubric, the generated source code, the blind pair images, the A/B keys and the raw judgments.

## The short version

**0.4 was re-judged, pre-registered:** all three platforms, the same 8 prompts in both orderings, all three judges. The results are published whatever they show, and the earlier runs stay in the record. All three judges have now judged the same 48 images (below). Protocol, publishing rules and input fingerprints were written down before any 0.4 screen existed: [`PREREGISTRATION-0.4.md`](PREREGISTRATION-0.4.md).

**0.4.1 is not a new eval.** The judged run is pack 0.4. 0.4.1 changes nothing except the React Native crash (guidance plus lint rule MU118; diff in [`pack-0.4-judged/`](pack-0.4-judged/), which also holds the judged 0.4 files and matches its pre-registered fingerprint).

**Which version was judged:** **0.4, the version you install, has now been judged** on all three platforms by Claude Opus 5.5 under the pre-registration: SwiftUI 16/16, Flutter 15/16, React Native 14/16. React Native lost one prompt because the pack-built screen crashes at launch. GPT-6.1 Sol agrees with 16/16, 14/16 and 14/16; Grok 4.7 gives 15/16, 14/16 and 11/16. Flutter is not significant under Grok, as on 0.3. The earlier runs stay in the record: SwiftUI on 0.1 and 0.2, React Native on 0.2+ (0.2 plus fixes that shipped in 0.3), Flutter on 0.2+ and 0.3. Each results folder names its version.

- **Unit of comparison:** one screen built by an agent *without* the pack and one built *with* it, from the same user request.
- **Sample:** 8 user requests per platform, with **one generation per arm**. Each pair is judged **twice**, with the sides swapped, so one platform run is "8 prompts × 2 orderings = 16 judgments". The 16 judgments are not 16 independent samples: the two orderings of a prompt judge the same two screens.
- **Judges from three labs.** The main judge is Claude Opus 5.5 (`claude-opus-5-5`), the same family that generated the screens. All 80 judgments were repeated blind by **GPT-6.1 Sol** (agrees on 78/80) and **Grok 4.7** (agrees on 74/80). All three agree on 72/80, and a two-of-three majority gives the pack 77/80 ([GPT](results/cross-family-gpt-6.1-sol/README.md), [Grok](results/cross-family-grok-4.7/README.md)).
- **Significance is counted per prompt, not per judgment.** A prompt counts for an arm only if that arm won both orderings. With a one-sided exact sign test, 8 of 8 prompts gives p ≈ 0.004, 7 of 8 with one loss gives p ≈ 0.035, and 7 of 7 decided (one split) gives p ≈ 0.008. That says the preference is very unlikely to be a coin flip *for these judges*. It says nothing about human taste.

| Run | Pack version | Judgments won by the pack (Claude) | Prompts won in both orderings | Sign test (prompts) | Mean rubric score, with / without | GPT-6.1 Sol | Grok 4.7 |
|---|---|---|---|---|---|---|---|
| SwiftUI | 0.1 | 16 / 16 | 8 / 8 | p ≈ 0.004 | 4.01 / 3.01 | 15 / 16 | 14 / 16 |
| SwiftUI | 0.2 | 16 / 16 | 8 / 8 | p ≈ 0.004 | 4.04 / 3.02 | 16 / 16 | 16 / 16 |
| React Native | 0.2+ | 16 / 16 | 8 / 8 | p ≈ 0.004 | 4.05 / 3.11 | 16 / 16 | 16 / 16 |
| Flutter | 0.2+ | 14 / 16 | 7 / 8 (lost auth) | p ≈ 0.035 | 3.95 / 3.27 | 13 / 16 | 13 / 16 |
| Flutter | 0.3 | 15 / 16 | 7 / 8 (auth split) | p ≈ 0.008 | 4.07 / 3.24 | 15 / 16 | 12 / 16 (p ≈ 0.14) |
| **SwiftUI** | **0.4** (pre-registered) | 16 / 16 | 8 / 8 | p ≈ 0.004 | 4.10 / 2.95 | 16 / 16 | 15 / 16 |
| **React Native** | **0.4** (pre-registered) | 14 / 16 | 7 / 8 (lost list: crash) | p ≈ 0.035 | 3.67 / 3.15 | 14 / 16 | 14 / 16 |
| **Flutter** | **0.4** (pre-registered) | 15 / 16 | 7 / 8 (auth split) | p ≈ 0.008 | 4.11 / 3.17 | 14 / 16 | 11 / 16 (p ≈ 0.19) |

`python3 evals/tools/unblind.py <run>/judgments.jsonl <run>/ab-key.json` reproduces each row.

## 1. Prompts

The 8 user requests are listed in [`README.md`](README.md#prompts) (home, settings, paywall, onboarding, detail, list, stats, auth). The other 4 prompts in that list (profile, form, chat, states) have not been run yet.

**Every generator and judge prompt used, verbatim:** [`prompts/`](prompts/), one folder per run, with `generate/` and `judge/` subfolders. The file count is not the sample size. It counts every agent instruction across eight runs:

| Run | Generator prompts | Judge prompts |
|---|---|---|
| SwiftUI 0.1 | 16 (8 user requests × 2 arms) | 16 (8 pairs × 2 orderings) |
| SwiftUI 0.2 | 8 (pack arm only; baseline reused from 0.1) | 16 |
| React Native | 16 | 16 |
| Flutter 0.2+ | 16 | 16 |
| Flutter 0.3 | 8 (pack arm only; baseline reused) | 16 |
| SwiftUI, React Native, Flutter 0.4 | 24 (pack arm only; baselines reused) | 48 |
| **Total** | **88** | **128**, so **216 files** |

In every run, the sample is the same **8 user requests**. Each is built once without the pack and once with it, and the pair is judged in **2 orderings**, which gives 16 judgments per run.

- **Without pack:** "You are a [platform] developer. A user asked you: '[request]'. Build it … as you normally would." Plus identical technical constraints (one file, must compile/typecheck/analyze, realistic sample data, no third-party packages or assets). These agents were told not to use any skills, and the pack is never mentioned.
- **With pack:** the same request and the same constraints, plus "read `mobile-ui` and the platform skill and follow them; no project tokens, so use the default skin". Nothing else differs.
- For the Flutter 0.3 rerun, the with-pack agents were also told not to read `evals/`, because by then it contained the judges' critiques of earlier screens.

## 2. Rendering

Each generated screen is built and run on an iPhone 17 simulator (iOS 27) and captured three ways: light, dark, and light at accessibility-XL text. The harness for each run is kept next to its results. Captures are checked for blank frames and for duplicate screens before judging. This check exists because one Flutter capture rendered the same screen 48 times and was caught before judging.

Flutter and React Native screens are judged as **iOS** screens. Android rendering is checked separately (see the README verification table) and is not part of the judged comparison.

## 3. Judging

- **Blind pair image:** the two arms stacked as rows A and B, with columns light / dark / AX-XL. Which arm goes on top is random (`compose_pairs.py`, fixed seed), and the second ordering swaps the rows. The key (`ab-key.json`) is never shown to judges.
- **What the judge sees:** only the pair image, the user's original request, and [`rubric.md`](rubric.md). Judges are never told a skill pack exists or that one arm is special.
- **Judge model:** Claude Opus 5.5 (`claude-opus-5-5`), one fresh instance per image with no memory of other judgments.
- **Output:** a 1–5 score per criterion for each side, a preference (A / B / tie), a confidence, and a ≤60-word reason. The raw output is in each run's `judgments.jsonl`.

### Score scale

Each criterion is scored 1–5, with anchors at 1, 3 and 5 defined in [`rubric.md`](rubric.md). The criteria are focal hierarchy, restraint, typography, spacing & alignment, platform fit, dark mode, accessibility, content realism, and states. **Overall** is the mean of the 8 criteria that apply to every screen. "States" is excluded everywhere because judged screens almost never showed an empty, loading or error state; one judge scored it once (SwiftUI 0.1 list, 2 on both sides). The **pairwise preference** answers one question: "Which one looks like a designer worked on it?"

### Same-family judging, and the cross-family check

Claude generated every screen, and Claude did the main judging, so a judge could favour output that resembles its own family's taste. To test that, all 80 blind images were re-judged by two judges from other labs via OpenRouter, using [`tools/judge_external.py`](tools/judge_external.py). They got the identical images, request, rubric and schema, with no retries.

| | Claude Opus 5.5 | GPT-6.1 Sol | Grok 4.7 |
|---|---|---|---|
| Judgments won by the pack | 77 / 80 | 75 / 80 | 71 / 80 |
| Agreement with Claude | — | 78 / 80 | 74 / 80 |

- All three agree on 72/80, and a two-of-three majority gives the pack 77/80.
- **SwiftUI and React Native** are 16/16 under every judge on their current judged versions.
- **Flutter** is the soft spot. Grok gives Flutter 0.3 12/16, which isn't significant on its own (p ≈ 0.14). Its reasons are mostly large-text failures, including a stats chart that clips at AX-XL.
- Details: [GPT](results/cross-family-gpt-6.1-sol/README.md), [Grok](results/cross-family-grok-4.7/README.md).

That settles "Claude grading Claude". It doesn't make the result a human judgment: blind ratings by 2–3 designers are still open ([`HUMAN_RATING.md`](HUMAN_RATING.md)).

## 4. What these results do not show

- **Other harnesses and models.** Every judged screen was built by Claude Opus 5.5 in Claude Code. The pack *installs* in Codex and Cursor (checked), but whether it *helps* there is untested. Codex runs GPT models, Cursor users choose their own, and other models may follow skills differently. A Codex run is pre-registered: [`PREREGISTRATION-followups.md`](PREREGISTRATION-followups.md), Study B.
- **No "generic design prompt" baseline.** The comparison is pack against no design instructions at all. A one-line prompt such as "make it look polished and native, respect large text" might get part of the gain, so these results can't say how much comes from the pack's specific rules. A third arm was pre-registered ([`PREREGISTRATION-followups.md`](PREREGISTRATION-followups.md), Study A) and run. Under the Claude judge, the pack beats the one-line prompt on 47/48 judgments, and the one-line prompt beats no instructions on 33/48, mostly on large text ([results](results/2026-10-15-studyA-README.md); GPT and Grok pending).
- **Circularity.** The same author wrote the pack and the rubric, and both value restraint, the criterion with the biggest gap (about +2). The judges may partly be measuring how well agents follow that taste. The plain pairwise question ("which looks like a designer worked on it?") is less exposed, and it agrees with the scores. Judges from three labs don't remove this. Only blind ratings by human designers would, and there are none yet.
- **Looks only.** Judges saw screenshots. Code quality, maintainability and correctness weren't measured. The pack can introduce bugs as well as fix looks: in 0.4, its money-formatting guidance led to a React Native screen that crashes on Hermes (fixed in 0.4.1).
- **Small sample.** 8 prompts per platform, one generation per arm. Agent output varies between runs, so a rerun could move results by a prompt or two either way.
- **Taste in general:** the results show that the pack beats the same model without the pack, under this rubric, on these prompts. That is not a claim about what designers prefer.
- **Lint counts favour the pack by construction.** Pack agents were told to run the linter.
- **Android, interaction, and screens beyond the 8 requests** are not covered.

## 5. Reproduce

1. Generate: use the prompts in `prompts/<run>/generate/` with any agent, one file per screen.
2. Render: use the harness in `results/<run>/harness/` (Flutter) or the scripts next to each run.
3. Compose blind pairs: `python3 tools/compose_pairs.py <out_dir> <base_shots> <pack_shots> <seed> '{arm}-{id}-{v}'`.
4. Judge: with the prompts in `prompts/<run>/judge/`, or `tools/judge_external.py` for a different model family.
5. Score: `python3 tools/unblind.py <judgments.jsonl> <out_dir>.KEY.json`.
