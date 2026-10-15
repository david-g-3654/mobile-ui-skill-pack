# Roadmap: v0.1 → v1.0 launch in 3–4 weeks

v0.1 (this repo) is feature-complete in *content*: the core skill, 14 archetypes, 23 components, three platform skills with compiling tokens, components and templates, a lint, and an eval harness. The launch window is for **proving** the pack works and closing the gaps that the proof exposes.

## Week 1: baseline and visual truth

- [x] First eval run (SwiftUI, 8 prompts, both arms, blind LLM judges): with-pack won 16/16, mean 4.01 vs 3.01. See `evals/results/2026-10-14-swiftui/`. Its backlog (AX-XL bottom bars, delta semantics, template copy leakage…) feeds week 2.
- [x] Extend the eval to RN and Flutter: RN 16/16 (4.05 vs 3.11), Flutter 14/16 (3.95 vs 3.27, lost auth). See `evals/results/README.md`.
- [ ] The remaining 4 prompts (profile, form, chat, states).
- [ ] 2–3 blind human raters (page and tally ready: `evals/HUMAN_RATING.md`).
- [x] Cross-family judging: GPT-6.1 Sol agrees on 78/80 judgments.
- [x] Second cross-family judge: Grok 4.7, 71/80 (Gemini was restricted on the OpenRouter account).
- [x] Re-judge all three platforms on 0.4, pre-registered (Claude: 16/16, 15/16, 14/16).
- [x] GPT-6.1 Sol and Grok 4.7 on the 0.4 images (44/48 and 40/48).
- [ ] Flutter at large text and in dark mode: auth's dark secondary buttons, content hidden under pinned footers at AX-XL (Grok's 0.4 reasons).
- [x] Catch Intl APIs that Hermes lacks: lint MU118 and the React Native skill (0.4.1).
- [ ] Judge React Native again on the next version.
- [ ] Non-text contrast. The style guide verifies text only. In dark mode a `surface2` button on `canvas` is 1.32:1, and in light mode 1.07:1; hairlines are 1.24–1.30:1. Grok saw dark secondary buttons "nearly vanish". `QSecondaryButton` uses this fill. Target ≥ 3:1 for edges that identify a control (WCAG 1.4.11): a stronger fill or a border. Add these pairs to the verified table and to a test.
- [x] API prefix (`Q…`) on all platforms, with a test that blocks unprefixed symbols and a migration script (0.4).
- [x] Gallery from release builds, with the hero rebuilt fresh on 0.4.
- [x] Agent Skills packaging: `npx skills add` installs all 4 skills for Codex, Cursor and other agents, with the linter bundled.
- [x] Render SwiftUI templates on an iOS simulator: `scripts/ios_preview.sh`. The first pass caught 4 real issues: margin misaligned with native titles, tint bleed, and layouts breaking at accessibility text sizes. The Flutter golden pass caught 4 more.
- [x] Render RN templates in Expo Go on iOS: `scripts/rn_preview.sh`. This caught 6 issues: on iOS 26+ a header background colour hides large titles; titles set from a pushed screen's component don't render; a page-sheet paywall doubled the top inset; and at accessibility sizes, titles broke mid-word, the avatar got clipped, and the hero truncated to "2,1…".
- [x] Android emulator pass for RN and Flutter (`scripts/android_preview.sh`, Pixel 8 / Android 15). It found one bug: React Native's off switch was invisible on Android. Fixed.
- [x] Render arbitrary generated screens for evals: SwiftUI host app per arm, one Expo app with a route per screen, and a Flutter host built per screen (`--dart-define`). Harnesses are kept next to each run's results.

## Week 2: with-pack arm and iteration

- [x] Run the with-pack arm. Score blind. (Done on all three platforms; SwiftUI re-run on v0.2: 16/16, 4.04, accessibility 3.19 → 3.50.)
- [x] (first pass, v0.2 and v0.3) For every loss or score < 4, find the missing or unclear rule and fix that reference. Expect the most edits in `screen-*.md` budgets and the platform SKILL opinions.
- [ ] Add templates for the next most-requested archetypes on all three platforms: **onboarding, detail, list (with states), stats, auth**.
- [ ] Extend the lint with the failure modes the evals surface. Each new rule gets a fixture. (MU115–MU117 done; next: pinned footer covering the last section in Flutter, AX overflow in Flutter hero rows.)
- [x] Re-run the Flutter pack arm on 0.3: 15/16, mean 4.07 (from 14/16, 3.95).

## Week 3: breadth and brand

- [ ] Brand onboarding test: run 3 real brand inputs (a URL, a hex + font, "feel like Things/Revolut/Airbnb") through `onboarding.md` and check the token files they produce.
- [ ] NativeWind variant of the RN tokens (`global.css` + `tailwind.config.js`), since many RN agents default to it.
- [ ] Android pass: Material 3 adaptations reviewed on a Pixel emulator (Flutter and RN).
- [x] Gallery: `docs/gallery/` (hero, per platform with dark and large text, all 8 prompts per platform). The hero image is at the top of the README.

## Week 4: launch

- [ ] Re-run the full eval. Ship bar: ≥ 80% blind pairwise wins, mean ≥ 4.0/5, median lint errors 0, compile rate not lower than baseline.
- [ ] Publish: plugin marketplace entry, README gallery, a short write-up with the before/after numbers.
- [ ] Tag v1.0. Freeze the rule IDs (MU0xx) so downstream CI can depend on them.

## After launch: "something bigger"

The pack is the foundation for heavier tooling. Candidates, in order of leverage:

1. **Screenshot critique loop.** The agent renders its own screen, scores it against `rubric.md`, and fixes the top 3 issues before hand-off. This turns the taste gate from a checklist into a feedback loop.
2. **Reference retrieval.** Connect a screen-reference library (Refero / Mobbin MCP) so the agent pulls 3–5 real examples of the archetype before building, instead of relying on the static reference alone.
3. **Design-system ingestion.** Read Figma variables or an existing app's theme and generate the token file automatically (`onboarding.md` branch a, automated).
4. **CI integration.** `mobile_ui_lint` as a GitHub Action with PR annotations, plus visual regression on the golden renders.
5. **More surfaces.** Tablet/iPad layouts, widgets, watchOS, Compose (Android-native), and web-mobile (PWA).
