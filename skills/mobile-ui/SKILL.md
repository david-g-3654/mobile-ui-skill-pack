---
name: mobile-ui
description: Design and build mobile app screens that look properly designed instead of generic, for SwiftUI, React Native, and Flutter. Use whenever an agent creates, redesigns, reviews, or polishes a mobile screen or component — home/dashboard, feed/list, detail, settings, onboarding, paywall, sign-in, profile, stats, form/checkout, chat, search, sheets, empty/loading/error states — or sets up mobile design tokens, typography, spacing, color, dark mode, or a component library. Triggers on "mobile screen", "iOS screen", "Android screen", "app UI", "make this screen look better", "this looks generic", "design the settings page", SwiftUI, React Native, Expo, Flutter. Always pair with the platform skill (mobile-ui-swiftui, mobile-ui-react-native, mobile-ui-flutter) for code.
license: MIT
metadata:
  version: "0.4.1"
---

# Mobile UI

Design mobile screens with an editorial, opinionated system so they read as *designed*, not assembled.

This skill decides **what** the screen is and **how it should look**. The platform skills decide **how to build it**:

| Stack | Load next |
|---|---|
| SwiftUI | [`../mobile-ui-swiftui/SKILL.md`](../mobile-ui-swiftui/SKILL.md) |
| React Native / Expo | [`../mobile-ui-react-native/SKILL.md`](../mobile-ui-react-native/SKILL.md) |
| Flutter | [`../mobile-ui-flutter/SKILL.md`](../mobile-ui-flutter/SKILL.md) |

---

## 0. First-time setup — token gate

**Before building the first screen in a project, find out whose design system you are using.**

1. Look for existing tokens: a `DesignSystem.swift` / `Theme.swift`, `theme.ts` / `tokens.ts` / `tailwind.config.*` / a NativeWind or Tamagui config, `theme.dart` / `ThemeData(`. Look for an asset catalog with named colors (`*.xcassets/*.colorset`).
2. **If tokens exist, use them.** Never introduce a second palette or type scale. Map their names onto the roles in [`references/style-guide.md`](references/style-guide.md) and keep going.
3. **If none exist**, pause and ask once:

> *"There's no design system in this project yet. Options: (a) give me a brand color + font (or a website/Figma link), (b) use the pack's default 'Quiet' skin, (c) point me at an existing app you want this to feel like."*

Then follow [`references/onboarding.md`](references/onboarding.md) and copy the platform's token file from that platform skill's `assets/`. Only skip the question when the user has already said "just build it" — then use the default skin and say so in one line.

---

## 1. Philosophy

**The highest-quality move is usually deletion.**

Generic screens are not ugly because something is missing. They are ugly because *everything has equal weight*: every block is a shadowed card, every label is bold, every number is the same size, every row has an icon in a colored circle. Design is the act of deciding what matters and letting the rest recede.

- **One job per screen.** If you can't say it in five words ("see today's balance", "choose a plan"), the screen is two screens.
- **One focal element.** Every screen has exactly one thing the eye lands on first — a hero number, a title, a photo, a primary button. Make it unmistakably bigger, heavier, or brighter than everything else.
- **One primary action.** At most one filled primary button visible at a time. Everything else is secondary, tertiary, or a row.
- **Accent is editorial, not decoration.** The accent color marks ≤2 things per screen. If you're tempted to accent 5 things, you haven't decided what's focal.
- **Hierarchy comes from type and space first, color second, boxes last.** Reach for a card only after size, weight, and whitespace have failed.
- **Native beats novel.** A screen that behaves like the platform (navigation, sheets, back gestures, Dynamic Type, haptics) feels expensive. A custom header that breaks swipe-back feels cheap no matter how pretty it is.

**Target density: 4/10.** Comfortable, scannable, finished. Not a dashboard cockpit; not an empty art gallery.

---

## 2. Classify the screen first

Every request maps to one **screen archetype**. Load its reference *before* writing code — it holds the anatomy, the budget, and the failure modes observed across hundreds of shipped apps.

| If the screen's job is… | Archetype | Reference |
|---|---|---|
| Show "where things stand" and the next action | **Home / dashboard** | [screen-home.md](references/screen-home.md) |
| Browse many similar items | **Feed / list** | [screen-list.md](references/screen-list.md) |
| Show one thing in depth and act on it | **Detail** | [screen-detail.md](references/screen-detail.md) |
| Change preferences / account | **Settings** | [screen-settings.md](references/screen-settings.md) |
| First-run welcome, value props, permissions | **Onboarding** | [screen-onboarding.md](references/screen-onboarding.md) |
| Sell a subscription / unlock | **Paywall** | [screen-paywall.md](references/screen-paywall.md) |
| Sign in / sign up / verify | **Auth** | [screen-auth.md](references/screen-auth.md) |
| Show a person or account | **Profile** | [screen-profile.md](references/screen-profile.md) |
| Show a metric over time | **Stats** | [screen-stats.md](references/screen-stats.md) |
| Collect input / pay | **Form / checkout** | [screen-form.md](references/screen-form.md) |
| Conversation / AI chat | **Chat** | [screen-chat.md](references/screen-chat.md) |
| Find something | **Search** | [screen-search.md](references/screen-search.md) |
| A choice or quick task on top of context | **Sheet / dialog** | [screen-sheet.md](references/screen-sheet.md) |
| Nothing here yet / loading / failed | **States** | [screen-states.md](references/screen-states.md) |

Every archetype also needs its **states**. A screen isn't done until empty, loading, and error are designed — load `screen-states.md` alongside any list, home, search, or stats screen.

### Confirm before building

State in one or two lines: archetype, the screen's one job, the focal element, the primary action, and what you're cutting. Example:

> *Paywall. Job: pick a plan and start the trial. Focal: the headline + annual plan card. Primary: "Start free trial". Cutting: the feature comparison table (moving to a "See all features" link).*

Proceed unless the user objects. In autonomous runs, note assumptions and continue.

---

## 3. Universal anti-patterns — the "generic" tells

These are the specific moves that make agent-built screens look templated. Full list with fixes: [`references/anti-patterns.md`](references/anti-patterns.md). The top ten, which the taste gate checks:

1. **Card soup** — every section wrapped in a white rounded card with a drop shadow; cards inside cards. → Group with space and section headers; cards only for things that are *objects* (a payment card, a plan, a media tile).
2. **The 2×2 stat grid** — four identical tiles, each an icon in a pastel circle + number + label. → One hero metric, then a quiet row of 2–3 secondary metrics.
3. **Flat hierarchy** — 6+ font sizes, or everything bold, or every number the same size. → Max 4 text styles per screen (+ one hero), max 2 weights.
4. **Default-blue everything** — `#007AFF`, Material purple `#6750A4`/`#6200EE`, Tailwind indigo `#6366F1` as the only brand color, used on every icon. → Ink primary, one considered accent used ≤2×.
5. **Gradient garnish** — purple→blue gradient buttons, gradient headers, gradient text. → Solid fills. A gradient is allowed only as an *image-like* backdrop on onboarding/paywall heroes.
6. **Fake native chrome** — custom header `View` with a "<" text arrow, custom tab bar that ignores safe area, hamburger menu on iOS, FAB on iOS. → Use the platform navigator, tab bar, sheets.
7. **Icon confetti** — an icon (or emoji) on every row, every label, every button, often in a tinted circle. → Icons only where they speed recognition; monochrome glyphs from one icon family.
8. **Centered everything** — centered titles, centered paragraphs, centered list content. → Left-align content screens; center only short, ceremonial moments (empty state, success, onboarding hero).
9. **Placeholder content** — "Lorem ipsum", "John Doe", "Item 1", "$0.00" on every row, `Title`/`Subtitle`. → Write realistic, specific sample data. Real copy reveals real layout problems.
10. **Unpinned primary action** — the main button scrolls away or sits under the home indicator. → Pin the primary CTA in a bottom bar respecting the safe area on forms, paywalls, detail, onboarding.

---

## 4. Design system (default "Quiet" skin)

Full tokens, light + dark, per platform: [`references/style-guide.md`](references/style-guide.md). The rules that matter most:

**Color roles** — never use raw hex in screens; always a role.

| Role | Use |
|---|---|
| `canvas` | Screen background. Slightly off-white / near-black, never pure `#FFF` behind white cards. |
| `surface` | Grouped rows, sheets, inputs, cards that are *objects*. |
| `ink` / `ink2` / `ink3` | Primary text / secondary text / tertiary (placeholder, disabled only). |
| `hairline` | 0.5–1px separators. Never `#CCC` borders on everything. |
| `accent` | ≤2 elements per screen: selected state, the one focal highlight, progress. |
| `primaryFill` / `onPrimary` | The primary button. **Defaults to ink**, not accent. Black/white CTAs look intentional; generic blue CTAs don't. |
| `positive` / `negative` / `warning` | Status only. Never decorative. |

**Typography** — platform system font by default (SF Pro on iOS, Roboto/Google Sans-like on Android). One optional display face for personality (a serif, a rounded, or a mono — chosen once per app). Ramp:

| Style | iOS pt / Android sp | Weight | Use |
|---|---|---|---|
| `hero` | 48–72 | semibold, tabular, tight tracking | The one number/word that *is* the screen |
| `largeTitle` | 34 | bold | Top-level screen titles |
| `title` | 22–28 | semibold | Section-defining titles, sheet titles |
| `headline` | 17 | semibold | Row titles, card titles |
| `body` | 17 (iOS) / 16 (Android) | regular | Paragraphs, row values |
| `subhead` | 15 | regular | Secondary lines |
| `footnote` | 13 | regular | Metadata, legal, captions |
| `overline` | 12–13 | semibold, +0.5 tracking, uppercase *only here* | Group labels, eyebrows |

Rules: max **4 styles + hero** per screen; max **2 weights** (regular + semibold; bold only for `largeTitle`). Numbers that change use **tabular figures**. Units are smaller and lighter than their number (`7h 8m`, `$`**`0.00`**). Sentence case everywhere except `overline`.

**Spacing** — 4pt grid. Screen margin **16** (aligns with iOS large titles, inset-grouped lists and M3 compact margins; verified on an iOS 27 simulator). Between unrelated sections **32**. Within a group **12**. Row min height **52** (one line) / **64** (two lines). Touch targets ≥ **44pt** (iOS) / **48dp** (Android).

**Shape** — pick once per app and never mix: **capsule** buttons (default) *or* rounded-rect (radius 14). Cards/groups radius **20**, sheets **28** top corners, inputs **14**. Nested radii are **concentric**: inner = outer − padding. Use continuous corners where the platform supports it.

**Elevation** — light mode separates with `canvas` vs `surface`, not shadows. Shadows only on things that *float*: floating tab bar, FAB (Android), sheets, popovers — and never in dark mode (use a lighter surface instead).

**Motion & feedback** — springs, not linear; 200–350 ms; respect Reduce Motion. Haptic on commit actions (purchase, toggle, delete, success), never on scroll. See [`references/motion-and-feedback.md`](references/motion-and-feedback.md).

---

## 5. Components

The platform-neutral component reference — anatomy, measurements, states, when to use and when not to — lives in [`references/components.md`](references/components.md). Each platform skill maps every entry to native code in its own `references/components.md` and ships a ready file in `assets/`.

Core set (23): Primary button · Secondary/tertiary button · Navigation bar & large title · Tab bar (docked / floating) · List row · Grouped section · Section header · Hero metric · Metric row · Card (object) · Segmented control · Text field · Toggle row · Chip / filter · Bottom sheet · Empty state · Skeleton · Toast / banner · Avatar · Badge · Progress ring/bar · Plan card (paywall) · Bottom action bar.

**Prefer the native component.** Build a custom one only when the native one can't express the archetype (a hero metric, a plan card), and then build it from tokens.

---

## 6. Layout & budget

Per-screen complexity budget. If you exceed it, split the screen or push content behind a row/sheet.

| Limit | Default |
|---|---|
| Filled primary buttons visible | 1 |
| Accent-colored elements | 2 |
| Text styles (excluding hero) | 4 |
| Font weights | 2 |
| Cards (objects) visible above the fold | 3 |
| Rows in one grouped section | 7 (then split or "See all") |
| Tab bar items | 3–5 |
| Icons per row | 1 leading, 1 trailing |
| Distinct icon families | 1 |
| Shadows | only on floating elements |

Per-archetype budgets live in each screen reference. Full spacing tables: [`references/layout-budget.md`](references/layout-budget.md).

**Above the fold** on a 390×844 pt phone (iPhone 15/16) you have ~700pt of content height after bars. The focal element and the primary action must both be visible without scrolling on home, detail, onboarding, paywall, and auth.

---

## 7. Copy

Words are layout. Specific copy is half of what makes a screen look designed. See [`references/copy.md`](references/copy.md).

- Buttons say what happens: "Start 7-day trial", "Save address", not "Submit", "OK", "Continue" (unless it truly is a step in a sequence).
- Empty states say what will be here and how to get it: "Saved places show up here. Tap ♡ on any place to save it."
- Sentence case. No exclamation marks except celebrations. No "Oops!".
- Sample data must be realistic and varied: real-looking names, uneven lengths, real prices (`$12.40`, not `$10.00`), dates relative to today.

---

## 8. Taste gate (run before you hand off)

**Fit**
- [ ] Classified the archetype and loaded its reference? States (empty/loading/error) designed?
- [ ] Can I name the screen's one job, its focal element, and its one primary action?
- [ ] Used the project's tokens (or the default skin) — zero raw hex / raw font sizes in screen code?

**Remove test**
- [ ] Can I delete a card and let space do the grouping?
- [ ] Can I delete an icon, a divider, a subtitle, a badge?
- [ ] Is any information repeated (title in nav bar *and* in a header)?

**Hierarchy**
- [ ] One focal element, clearly dominant? (Squint: does one thing still stand out?)
- [ ] ≤4 text styles + hero, ≤2 weights, units smaller than numbers, tabular figures on changing numbers?
- [ ] Accent on ≤2 elements? Primary fill on ≤1 button?
- [ ] Content left-aligned (except ceremonial centered moments)?

**Native**
- [ ] Platform navigation, back gesture, tab bar, sheets — not hand-rolled imitations?
- [ ] Safe areas respected; primary action pinned above the home indicator where the archetype says so?
- [ ] Dynamic Type / font scaling works to at least XXL without truncating the primary action?
- [ ] At accessibility sizes, does any pinned bar take more than ~25% of the screen? Only the primary button stays pinned; terms/secondary links move into the scroll content.
- [ ] Dark mode designed (not inverted): no shadows, surfaces step lighter, accent re-checked for contrast?

**Accessibility** (see [`references/accessibility.md`](references/accessibility.md))
- [ ] Text contrast ≥ 4.5:1 (≥ 3:1 for ≥ 24pt/semibold ≥ 19pt); `ink3` never used for information?
- [ ] Touch targets ≥ 44pt / 48dp; icon-only buttons have labels?
- [ ] Reduce Motion respected; nothing conveyed by color alone?

**Content**
- [ ] Realistic sample data — no lorem, no "John Doe", no all-identical rows?
- [ ] Button labels are verbs that say what happens?
- [ ] One currency/number format per screen (no `$` next to `US$`)? Deltas compare like-for-like periods (no red "−43%" for a week that isn't over)?
- [ ] No headline or copy reused verbatim from the pack's templates or examples?

**Lint**
- [ ] Ran `python3 scripts/mobile_ui_lint.py <files>` (the script in this skill's directory; needs only Python 3) and fixed every `error`? (See [`references/lint.md`](references/lint.md).)

---

## 9. Output

- Write screens as real, compiling files in the project's structure and naming conventions — not snippets.
- **Templates are structure, not copy.** Reuse their layout and components; never reuse their headlines, sample data, or brand names — write copy for *this* product.
- Put tokens in one file; screens import tokens and components, never define colors/sizes inline.
- Every screen ships with a preview (SwiftUI `#Preview`, a Storybook/Expo route, or a Flutter widget preview / golden) in light **and** dark, and with large text.
- When reviewing an existing screen, report findings as: archetype → top 3 hierarchy problems → fixes in code. Don't restyle everything; fix the focal element and the budget breaches first.
