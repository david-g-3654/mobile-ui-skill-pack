# Changelog

## 0.4.1 — 2026-10-15

**Crash fix only.** Nothing else changed. The diff against the judged 0.4 is in `evals/pack-0.4-judged/0.4-to-0.4.1.diff`.

- **Fixed: React Native screens built with the pack could crash at launch.** The money rule ("one format per screen"), the smaller currency symbol on `QHeroMetric`, and lint MU117 (which flags a hand-typed `"$"` next to a formatter) pushed agents toward `Intl.NumberFormat#formatToParts`. That method typechecks, but Hermes on iOS doesn't have it. In the 0.4 eval this crashed the React Native transactions screen.
  - The React Native skill now has a "Money and numbers on Hermes" section: what's safe, what's missing and what's silently wrong. It was checked on device with Expo SDK 57. It includes a `format()`-and-split snippet that works for any symbol position.
  - `copy.md` and MU117's fix text point to that section.
- **New lint rule MU118 (React Native):**
  - **Error:** `Intl` APIs that don't exist in Hermes on iOS. These are `NumberFormat#formatToParts`, `formatRange` / `formatRangeToParts`, `PluralRules`, `RelativeTimeFormat`, `ListFormat`, `DisplayNames`, `Segmenter`, `Locale`, `DurationFormat` and `supportedValuesOf`.
  - **Error:** `style: 'unit'`, which converts to the device's units (21.6 km renders as "13.422mi").
  - **Warning:** `notation: 'compact'` and `signDisplay`, which Hermes ignores.
  - MU118 flags the line that crashed in the eval and nothing in the other 23 React Native eval screens. Tests added.
- **Follow-up check (one prompt, not a new eval):** the React Native list prompt was regenerated on 0.4.1. It renders on Hermes and went to the pack in 6 of 6 judgments across Claude, GPT-6.1 Sol and Grok 4.7 (`evals/results/2026-10-15-react-native-v0.4.1-list/`).

### Evals (published with 0.4.1)

- **0.4 judged blind, pre-registered** (`evals/PREREGISTRATION-0.4.md`, `evals/results/2026-10-15-*-v0.4/`). Claude Opus 5.5: SwiftUI 16/16, Flutter 15/16, React Native 14/16. React Native lost the list prompt because the pack-built screen calls `Intl.NumberFormat.formatToParts`, which Hermes doesn't implement, so it crashes at launch. The pack doesn't steer agents toward that API, but it doesn't catch it either. GPT-6.1 Sol gives 16/16, 14/16, 14/16 and Grok 4.7 15/16, 14/16, 11/16; Flutter is not significant under Grok. No pack files changed during the run.

## 0.4 — 2026-10-14

**Breaking: every public symbol now has a `Q` prefix**, on all three platforms. 0.3's new `Swatch` broke a SwiftUI app that already had its own `Swatch`, and the next generic name would have done the same. The pack's files are copied into your app, so their names share your namespace: the Swift module, Dart files that also import Material (`Chip`, `Badge`), and React Native files that also import React Navigation (`useTheme`, `Theme`). Everything is prefixed now, and a test (`PublicApiIsPrefixed`) fails if a new unprefixed symbol ships.

Migration is a mechanical rename. `python3 scripts/migrate_to_0_4.py swift|dart|rn <paths> [--write]` does it for your code; it turns the 0.3 templates into exactly the 0.4 ones. Unchanged: the Quiet skin's own names (`quietTheme`, the `Quiet` theme extension, `context.q`), React Native's lowercase token objects (`space`, `radius`, `type`…), and SwiftUI's `Font.ds…` styles.

| Platform | Renamed |
|---|---|
| SwiftUI | `Metrics` → `QMetrics`, `Motion` → `QMotion`, `Palette` → `QPalette`, `Radius` → `QRadius`, `Space` → `QSpace`, `Typeface` → `QTypeface`, `Avatar` → `QAvatar`, `Badge` → `QBadge`, `BottomActionBarModifier` → `QBottomActionBarModifier`, `Chip` → `QChip`, `EmptyState` → `QEmptyState`, `HeroMetric` → `QHeroMetric`, `HeroText` → `QHeroText`, `LargeTextFooter` → `QLargeTextFooter`, `ListRow` → `QListRow`, `MetricRow` → `QMetricRow`, `ObjectCard` → `QObjectCard`, `PlanCard` → `QPlanCard`, `PrimaryButton` → `QPrimaryButton`, `PrimaryButtonStyle` → `QPrimaryButtonStyle`, `ProgressRing` → `QProgressRing`, `SecondaryButtonStyle` → `QSecondaryButtonStyle`, `SectionHeader` → `QSectionHeader`, `Shimmer` → `QShimmer`, `Swatch` → `QSwatch`, `TertiaryButtonStyle` → `QTertiaryButtonStyle`, `Toast` → `QToast`; `.bottomActionBar` → `.qBottomActionBar`, `.canvasBackground` → `.qCanvasBackground`, `.surfaceRow` → `.qSurfaceRow`, `.overlineStyle` → `.qOverlineStyle`, `.shimmering` → `.qShimmering`, `.toast` → `.qToast`, `.buttonStyle(.primary/.secondary/.tertiary)` → `.buttonStyle(.qPrimary/.qSecondary/.qTertiary)`, `Color.adaptive` → `Color.qAdaptive` |
| Flutter | `Avatar` → `QAvatar`, `BottomActionBar` → `QBottomActionBar`, `Delta` → `QDelta`, `DisplayScale` → `QDisplayScale`, `EmptyState` → `QEmptyState`, `GroupedSection` → `QGroupedSection`, `HeroMetric` → `QHeroMetric`, `LargeTextFooter` → `QLargeTextFooter`, `ListRow` → `QListRow`, `MetricRow` → `QMetricRow`, `Metrics` → `QMetrics`, `Motion` → `QMotion`, `ObjectCard` → `QObjectCard`, `PlanCard` → `QPlanCard`, `PrimaryButton` → `QPrimaryButton`, `ProgressRing` → `QProgressRing`, `QuietBadge` → `QBadge`, `QuietChip` → `QChip`, `Radii` → `QRadii`, `RowKind` → `QRowKind`, `SecondaryButton` → `QSecondaryButton`, `SectionHeader` → `QSectionHeader`, `Skeleton` → `QSkeleton`, `SkeletonRow` → `QSkeletonRow`, `Space` → `QSpace`, `Swatch` → `QSwatch`, `TertiaryButton` → `QTertiaryButton`, `ToggleRow` → `QToggleRow`, `isLargeText` → `qIsLargeText`; `context.t` → `context.qText`, `showToast` → `showQToast` |
| React Native | `Palette` → `QPalette`, `Theme` → `QTheme`, `useTheme` → `useQTheme`, `useLargeText` → `useQLargeText`, `Txt` → `QText`, `Screen` → `QScreen`, `PrimaryButton` → `QPrimaryButton`, `SecondaryButton` → `QSecondaryButton`, `TertiaryButton` → `QTertiaryButton`, `IconButton` → `QIconButton`, `BottomActionBar` → `QBottomActionBar`, `LargeTextFooter` → `QLargeTextFooter`, `SectionHeader` → `QSectionHeader`, `GroupedSection` → `QGroupedSection`, `ListRow` → `QListRow`, `ToggleRow` → `QToggleRow`, `HeroMetric` → `QHeroMetric`, `MetricRow` → `QMetricRow`, `ObjectCard` → `QObjectCard`, `Segmented` → `QSegmented`, `TextField` → `QTextField`, `Swatch` → `QSwatch`, `Chip` → `QChip`, `Avatar` → `QAvatar`, `Badge` → `QBadge`, `ProgressBar` → `QProgressBar`, `PlanCard` → `QPlanCard`, `EmptyState` → `QEmptyState`, `Skeleton` → `QSkeleton`, `SkeletonRow` → `QSkeletonRow`, `Toast` → `QToast` |

Also in 0.4:
- The naming rule is written into each platform skill, so agents that extend the pack keep the prefix.
- **`QBarChart` on all three platforms:** a single-series bar chart for stats screens, with one highlighted bar, an optional dashed goal line and per-bar accessibility labels. Its axis labels never collide: full names when they fit, single letters at accessibility sizes, every other label as a last resort. SwiftUI uses Swift Charts' collision resolution; Flutter measures its labels; React Native estimates them from the font scale. Verified on the iOS 27 simulator at default and AX-XL sizes on all three. (Agents used to hand-roll charts, and Grok's re-judging found the Flutter 0.3 stats chart clipping at large text.)
- `screen-stats.md`: chart axis labels go to single letters, or every other label, at large text, and points to `QBarChart` (found in the new gallery images).
- Gallery rebuilt: the hero's with-pack screens are fresh 0.4 builds on all three platforms, React Native screenshots come from a release build (no Expo Go button), and status-bar breadcrumbs are gone. Sources are in `docs/gallery/sources/`; the release harness is in `evals/harness/react-native-release/` (it uses Expo's official `ios.enableSceneSupport` opt-in for iOS 27). The React Native template previews (`docs/previews/rn-*`, `overview-react-native.png`) are now release builds too.
- Evals: `METHOD.md` explains the 144 published prompt files (64 generator + 80 judge across five runs; each run's sample is still 8 requests × 2 orderings). `judge_external.py` takes `--all`, `--dry-run` and resumes; its request handling has been checked against a mock endpoint.

## 0.3 — 2026-10-14

Driven by the second SwiftUI eval (v0.2) and the first React Native and Flutter evals (`evals/results/`).

**Upgrading from 0.2 (SwiftUI):** 0.3 adds a public `Swatch` view to `Components.swift`. If your app already declares its own `Swatch`, Swift reports "invalid redeclaration of 'Swatch'". Rename yours or switch to the pack's (`Swatch(name:color:isSelected:size:action:)`). Found by re-rendering a 0.2-built screen against 0.3. React Native and Flutter are unaffected.

- **Works beyond Claude Code.** The skills follow the [Agent Skills](https://agentskills.io/specification) format, so `npx skills add` installs them into Codex, Cursor, Copilot, Gemini CLI and others. The linter moved into the core skill (`mobile-ui/scripts/mobile_ui_lint.py`) so it ships with every install; `scripts/mobile_ui_lint.py` remains as a shim.
- **Android checked.** `scripts/android_preview.sh` runs the React Native (Expo Go) and Flutter templates on an emulator in light, dark and font scale 2.0. It found one bug: React Native's off-state switch was nearly invisible on Android. That's fixed with a dark off-thumb on Android only.
- **`HeroMetric` delta wraps at large text** (Flutter: one `Text.rich` with an inline icon; React Native: shrinking label). It used to run off the screen. Found in the Flutter 0.3 eval and by a generating agent.
- Template copy: "Face ID" became "your face or fingerprint" in the cross-platform paywall templates.
- Eval tooling: `evals/METHOD.md` (models, counts, sign test, limits), every prompt verbatim in `evals/prompts/`, `tools/unblind.py` with a prompt-level sign test, `tools/judge_external.py` for non-Claude judges, `tools/tally_human.py` and `HUMAN_RATING.md` for blind human rating. Gallery: `scripts/gallery.py`, `docs/gallery/`.
- **Provider sign-in buttons keep their marks.** The 0.2 rule ("provider name + neutral glyph when the asset is missing") cost the pack both Flutter auth comparisons. Now: the provider SDK's button, the official asset, or the platform's Apple glyph.
- **Flutter buttons grow instead of truncating** at accessibility sizes (minimum height, centred wrapping label).
- **Flutter `DisplayScale`** caps display type at 1.5×, matching RN's `Txt`. Used in `HeroMetric` and the paywall template.
- **Flutter on iOS:** no Material selection pill in `NavigationBar`. Chip theme is capsule with no check mark, and the selected label color resolves correctly in light and dark.

- **`Swatch` component** on all three platforms: color swatch with a hairline ring, so black and white swatches survive both modes.
- **SwiftUI `HeroMetric` fix:** the delta label used a bare `.fixedSize()`, which widened the screen at accessibility sizes. It now fixes only the vertical axis.
- **React Native display cap:** `Txt` caps `hero`, `largeTitle` and `title` at 1.5× font scale; body text stays uncapped.
- **Content colors:** a `// mobile-ui: content-color` marker lets data colors (category, product, chart series) bypass the hard-coded-color rule without turning it off.
- New guidance from the RN eval: summary header for lists with a natural total; rows on `surface` in dark lists; bottom-pinned search/compose bars get a content inset; chip rows wrap at large text (`flexWrap` / `Wrap`); nothing renders below a detail screen's pinned bar; fixed-height stats chart with no dead band.
- Anti-patterns 44–46 (single-theme screens, truncated chips and links at large text, lists without a focal point).
- Lint: MU116 (bare `.fixedSize()`, SwiftUI), MU117 (hand-typed currency next to a formatter). 21 rules.

## 0.2 — 2026-10-14

Driven by the first blind eval (`evals/results/2026-10-14-swiftui/`) and simulator passes.

- **Bottom action bar unpins its footer at accessibility text sizes** (all platforms): `footer:` + `LargeTextFooter` (SwiftUI), `footer` prop + `<LargeTextFooter>` (RN), `footer:` + `LargeTextFooter` (Flutter). A pinned bar must stay ≤ 25% of the screen.
- **List rows stack at accessibility sizes** on all three platforms (value under title, leading element on top).
- **Dark palette lifted**: canvas `#111113`, surface `#1E1E21`, surface2 `#2A2A2E`; all text roles still ≥ 4.5:1.
- SwiftUI button labels center when they wrap.
- New rules: one money format per screen; compare like-for-like periods in stats deltas; hairline ring on color swatches; official provider logos only; templates are structure, not copy (template files now say so).
- Anti-patterns 37–43 (found in evals). Taste gate gained three checks.
- Lint: MU115 (bottom bar overlaid on content); MU004 no longer flags real labels like "Name".

## 0.1 — 2026-10-14

Initial pack: core skill, 14 screen archetypes, 23 components, SwiftUI / React Native / Flutter skills with tokens, components and templates, lint, eval harness. Verified on iOS 27 simulator (SwiftUI, Expo Go) and Flutter goldens.
