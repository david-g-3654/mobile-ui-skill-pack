# Eval run: 2026-10-14, Flutter, pack 0.3 (rerun of the with-pack arm)

**Why:** Flutter was the only platform below the ship bar on pack 0.2: 14/16 judgments, mean 3.95, and it lost auth in both orderings. 0.3 fixed the causes the judges named, and this run checks whether those fixes work.

**Result:** 15 of 16 judgments for the pack (8 prompts × 2 orderings). 7 prompts were won in both orderings and auth was split 1–1. Mean rubric score was **4.07 vs 3.24**, which clears the 4.0 bar. The prompt-level sign test gives p ≈ 0.008 (one-sided, 7 of 7 decided prompts).

## What changed from the 0.2 run

| | |
|---|---|
| Without-pack arm | **Unchanged**: the same 8 screens and captures as the [0.2 run](../2026-10-14-flutter/README.md) |
| With-pack arm | 8 new generations on pack 0.3. The prompt and constraints are identical, plus one added instruction: don't read `evals/`, which by then contained the judges' critiques of the earlier screens. Prompts are in `../../prompts/flutter-v0.3/` |
| Judging | New blind pairs with a new random A/B assignment (`ab-key.json`). The judge prompt, rubric and model (Claude Opus 5.5) are the same |

## Results

| | Without pack | With pack 0.2 | With pack 0.3 |
|---|---|---|---|
| Judgments won | | 14 / 16 | **15 / 16** |
| Mean rubric score | 3.27 / 3.24 | 3.95 | **4.07** |
| Accessibility (AX-XL) | 2.50 / 2.31 | 2.81 | **3.31** |
| Platform fit | 3.12 / 3.06 | 3.75 | **4.19** |
| Focal hierarchy | 3.38 / 3.38 | 4.12 | **4.38** |
| Dark mode | 3.81 / 3.62 | 3.69 | 3.75 |
| Lint errors per file (median) | 9 | 0 | 0 |
| Lines of code (total) | 5,526 | 2,880 | 3,202 |

The without-pack column shows two numbers because its screens were judged twice, against different pack screens.

Per criterion on 0.3 (with / without): restraint 4.69 / 2.88 · focal 4.38 / 3.38 · platform fit 4.19 / 3.06 · typography 4.12 / 3.31 · content 4.25 / 3.94 · spacing 3.88 / 3.44 · dark mode 3.75 / 3.62 · accessibility 3.31 / 2.31.

## What the 0.3 fixes did

- **Auth:** the pack screen now shows the Apple and Google marks. The agent drew Google's four-colour "G" in code, because the harness bans asset files. That was enough to turn 0–2 into 1–1. The remaining loss was low-confidence: the judge called the screen's top half an "empty void" and flagged a stray divider.
- **Large text:** buttons wrap instead of truncating and display type is capped, so accessibility rose by half a point.
- **Platform fit:** with no tab pill and no check-mark chips, judges stopped calling the pack screens "Material on iOS". That label now goes to the baseline.

## Still open (and fixed after this run, not re-judged)

| Finding | Seen in | Status |
|---|---|---|
| Flutter overflow stripe at AX-XL: the `HeroMetric` delta row couldn't wrap | home (both orderings). The stats agent found the same bug while building and worked around it | **Fixed after the run**: the delta is now one `Text.rich` with an inline icon, so it wraps. The same fix went into React Native (`flexShrink`). These 0.3 numbers do **not** include it |
| Empty upper half on auth, stray divider | auth | Open: `screen-auth.md` should give the brand moment a defined size |
| Flat true-black dark mode, gap under the status bar | stats | Open |
| AX-XL chart labels clip | stats | Open |
