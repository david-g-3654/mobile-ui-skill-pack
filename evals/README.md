# Evals — does the pack actually make screens look designed?

A skill pack is only as good as the before/after difference it produces. This folder is the harness for measuring that: the same prompts, run with and without the pack, scored blind against one rubric.

## Protocol

1. **Arms.** For each prompt × platform, generate one screen **without** the pack (baseline) and one **with** the pack installed. Same model, same project scaffold, same prompt text. 12 prompts × 3 platforms × 2 arms = 72 screens.
2. **Render.** Screenshot each on a simulator (iPhone 17, 402×874) in light *and* dark, plus one at accessibility-XL text. SwiftUI: one host app per arm. RN: one Expo app, one route per screen. Flutter: real iOS simulator build, one `--dart-define=EVAL_SCREEN=<arm>-<id>` build per screen. Headless golden tests are not good enough for judging: they render text in a box font.
   **Check the captures before judging:** no blank frames, and every screen's image differs from the others. In the first Flutter run the host ignored its screen key and all 48 captures showed the same screen; only a look at an overview grid caught it.
3. **Lint.** Run `python3 scripts/mobile_ui_lint.py --json` on every generated file; record error/warning counts.
4. **Score blind.** Shuffle screenshots, hide the arm, score with [`rubric.md`](rubric.md) (two raters, or one human + one model judge with the rubric verbatim). Record in [`scores.csv`](scores.csv).
5. **Ship bar** for v1.0: with-pack arm wins ≥ 80% of blind pairwise comparisons, mean rubric score ≥ 4.0/5 (baseline is usually 2–2.5), median lint errors = 0, and no regression on compile success rate.

## Prompts

Write each prompt exactly as a user would — short and underspecified, which is where generic output comes from.

| # | Archetype | Prompt |
|---|---|---|
| 1 | Home | "Build the home screen for a personal budgeting app." |
| 2 | Settings | "Add a settings screen with notifications, appearance, subscription and account options." |
| 3 | Paywall | "Create a paywall for our journaling app with monthly and yearly plans." |
| 4 | Onboarding | "Make a welcome/onboarding screen for an AI voice notes app." |
| 5 | Detail | "Product detail page for a sneaker store." |
| 6 | List | "Transactions list for a banking app." |
| 7 | Stats | "Weekly running stats screen." |
| 8 | Profile | "User profile screen for a climbing community app." |
| 9 | Auth | "Sign-in screen with Apple, Google and email." |
| 10 | Form | "Checkout screen for a coffee ordering app." |
| 11 | Chat | "Chat screen for an AI assistant." |
| 12 | States | "The empty, loading and error states for a saved-places list." |

## What to watch for (qualitative notes column)

- Did the agent classify the archetype and state the focal element / primary action?
- Did it run the token gate (ask, or use project tokens) rather than inventing colors?
- Did it reach for native navigation, lists, sheets?
- Did it design dark mode and large text, or only light at default size?
- Did it write realistic sample data?
- Where it failed: which rule was missing or unclear in the skill? → file an issue against that reference.
