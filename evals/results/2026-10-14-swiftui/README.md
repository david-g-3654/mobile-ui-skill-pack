# Eval run: 2026-10-14, SwiftUI, 8 prompts

**Question:** does the pack make agent-built screens look more designed?
**Answer for this run:** yes. The with-pack screen won **16 of 16** blind pairwise judgments, and won both orderings of every prompt.

## Setup

| | |
|---|---|
| Prompts | 8 from `evals/README.md`: home, settings, paywall, onboarding, detail, list, stats, auth (profile, form, chat and states not run) |
| Platform | SwiftUI, iOS 17 target, rendered on an iPhone 17 / iOS 27 simulator |
| Generators | 16 independent agents (Claude Opus 5.5), one per prompt × arm. Identical user prompt and identical technical constraints in both arms. Each had to make its own file compile. **Without pack:** told not to use skills or other files. **With pack:** told to read `mobile-ui` + `mobile-ui-swiftui` and follow them, using the default Quiet skin. |
| Rendering | `render.sh`: one app per arm; each screen captured in light, dark and accessibility-XL text; blank frames detected and retried |
| Judging | 16 judge agents (Claude Opus), one per image. Each prompt was judged twice with A/B positions swapped, and A/B assignment was random (`ab-key.json`). Judges saw only the image, the original user prompt and `rubric.md`; they were never told a skill pack existed. |

## Results

| | Without pack | With pack |
|---|---|---|
| Compiles | 8 / 8 | 8 / 8 |
| Blind pairwise wins | 0 / 16 | **16 / 16** |
| Mean rubric score (1–5) | 3.01 | **4.01** |
| Lint errors per file (median) | 5 | 0 |
| Lines of code (total) | 4,296 | 3,259 |

Position-bias check: judges chose "A" 8/16 times.

Per criterion (with / without): restraint **4.75 / 2.25** · content **4.44 / 3.44** · focal **4.12 / 3.38** · typography **4.00 / 3.00** · spacing 3.94 / 3.44 · platform fit 3.88 / 3.25 · dark mode 3.75 / 3.44 · accessibility **3.19 / 1.88**.

The biggest gains were in restraint (gradient cards, tiles of coloured icons and card soup all disappeared), accessibility at large text (two baseline screens ignored Dynamic Type entirely), and copy. The smallest gains were in dark mode and spacing.

The ship bar in `evals/README.md` (≥ 80% wins, mean ≥ 4.0, median lint errors 0, no compile regression) is met, but only just on the mean.

## Caveats (read before quoting the numbers)

1. **Small sample:** 8 prompts, one generation per arm, one platform. React Native and Flutter are not measured.
2. **Same model family generates and judges.** The judges are LLMs, not human designers. The plan says to add a human rater before v1.0.
3. **The rubric and the pack share a philosophy.** Both were written together, and "restraint" is the criterion with the biggest gap. A rubric that rewards the pack's own values flatters it. The plain pairwise question ("which looks like a designer worked on it?") is less exposed to this, and it was also 16/16.
4. **Lint counts favour the pack by construction.** Pack agents were told to run the linter and fix what it found.
5. **Harness effects:** each screen is shown as the app's root, so "no back button" on detail screens is partly an artifact.

## Weaknesses the judges found in the pack's output (these are the backlog)

| Finding | Seen in | Likely fix in the pack |
|---|---|---|
| At accessibility-XL, the pinned bottom bar grows and covers content: headline clipped, timeline cut off, last value prop hidden | auth, onboarding, paywall | `bottomActionBar` guidance: at accessibility sizes, unpin, or move legal text into the scroll view; add to taste gate |
| Lost side margins / clipped text at AX-XL | stats | Hero row must use `ViewThatFits`; check AX-XL in previews |
| Currency shown inconsistently (`$` vs `US$`) | home | `copy.md`: one currency format per screen; prefer `.formatted(.currency(code:))` throughout |
| Red "down 43%" mid-week reads as an alarm | stats | `screen-stats.md`: compare like-for-like periods ("vs. same point last week"); colour deltas only on complete periods |
| Template copy reused verbatim ("Write it down. See the pattern.") | paywall | Tell agents templates are structure, not copy; rename template headlines to obvious placeholders |
| Dark mode reads flat on pure-black lists | list | Dark `canvas` vs `surface` contrast; consider `#111113` canvas |
| Product-colour swatch (black) vanishes in dark mode | detail | Swatches get a 1px `hairline` ring |
| Plain "G" in place of Google's mark | auth | `screen-auth.md`: use Google's official button asset; never fake the logo |
| Pinned footer can hide the last scroll item at default size | onboarding, paywall | Add bottom content inset = bar height |
