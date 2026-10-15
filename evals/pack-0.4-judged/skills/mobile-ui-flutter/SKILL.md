---
name: mobile-ui-flutter
description: Build properly designed Flutter screens using the mobile-ui system — a Quiet ThemeExtension of color roles on Material 3, platform-adaptive behavior (Cupertino transitions, Switch.adaptive, adaptive dialogs, SF on iOS / Roboto on Android), large collapsing app bars on a canvas, inset-grouped sections, ink stadium primary buttons in a safe-area bottom bar, hero metrics, skeletons, and designed dark mode. Use when writing or restyling any Flutter widget, screen, or ThemeData, or when a Flutter app "looks like default Material", "looks generic", or needs tokens. Load mobile-ui first for the screen archetype and taste gate.
license: MIT
metadata:
  version: "0.4"
---

# Mobile UI — Flutter

The design decisions live in [`../mobile-ui/SKILL.md`](../mobile-ui/SKILL.md). **Load it first**, classify the screen, then come back here for how to build it in Flutter.

Target: **Flutter 3.35+ / Dart 3.9+** (uses `Column.spacing`, null-aware elements, `RoundedSuperellipseBorder`, `WidgetStateProperty`). Verified with `flutter analyze` on Flutter 3.47.

---

## 0. Setup

1. Token gate (`mobile-ui §0`). If the project has a `ThemeData` with a custom `ColorScheme`/`ThemeExtension`, map roles onto it instead of adding a second theme.
2. Otherwise copy:
   - [`assets/theme.dart`](assets/theme.dart) — `Quiet` `ThemeExtension` (color roles, light/dark), `QSpace`, `QRadii`, `QMetrics`, `QMotion`, platform-aware `TextTheme`, `quietTheme(Brightness)`.
   - [`assets/components.dart`](assets/components.dart) — `QPrimaryButton`, `QSecondaryButton`, `QTertiaryButton`, `QBottomActionBar`, `QSectionHeader`, `QGroupedSection`, `QListRow`, `QToggleRow`, `QHeroMetric`, `QMetricRow`, `QObjectCard`, `QChip`, `QAvatar`, `QBadge`, `QProgressRing`, `QPlanCard`, `QEmptyState`, `QSkeleton`/`QSkeletonRow`, `showQToast`, `QBarChart` (stats charts whose axis labels survive large text).
   - **Naming:** Every pack symbol is prefixed: `Q…` widgets and tokens (`QListRow`, `QSpace`, `QBadge`), `qIsLargeText`, `showQToast`, and `context.q` / `context.qText` for colors and type. They sit next to Material's names (`Chip`, `Badge`) and i18n extensions (`context.t`) in the same file, so keep the prefix on anything you add.
3. Wire the theme:

```dart
MaterialApp(
  theme: quietTheme(Brightness.light),
  darkTheme: quietTheme(Brightness.dark),
  themeMode: ThemeMode.system,
  home: const HomeScreen(),
);
```

4. Templates: [`assets/templates/`](assets/templates/) — `home_screen.dart`, `settings_screen.dart`, `paywall_screen.dart`.
5. Component-by-component code: [`references/components.md`](references/components.md).

Access tokens in widgets as `context.q.ink` (colors), `context.qText.titleLarge` (type), `QSpace.lg`, `QRadii.l`.

### Text role mapping

| mobile-ui role | `TextTheme` slot |
|---|---|
| hero | `displayLarge` |
| largeTitle | `headlineLarge` |
| title | `titleLarge` |
| headline | `titleMedium` |
| body | `bodyLarge` |
| subhead | `bodyMedium` (ink2) |
| footnote | `bodySmall` (ink2) |
| overline | `labelSmall` (+ `.toUpperCase()` on the string) |

---

## 1. Flutter opinions (the defaults that make it look designed)

1. **Kill the default-Material look first.** The shipped `quietTheme` sets: `surfaceTint` transparent (no pink/purple tinted surfaces), `scrolledUnderElevation: 0`, canvas scaffold, hairline dividers, no splash on iOS (`NoSplash`), Cupertino page transitions on iOS and predictive back on Android, stadium buttons. Never ship `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`.
2. **Platform-adaptive where users notice**: transitions and back gesture (theme), `Switch.adaptive`, `AlertDialog.adaptive` + `showAdaptiveDialog`, `CircularProgressIndicator.adaptive`, `centerTitle` on iOS, SF Pro on iOS via `Typography.material2021(platform:)`. Everything else is one neutral, token-driven design.
3. **Screens are `Scaffold` + `CustomScrollView` + `SliverAppBar.large`** for tab roots and long content (collapsing large title on both platforms), `AppBar` for pushed details and forms. For an iOS-only feel, swap in `CupertinoSliverNavigationBar`. Never a `Container` + `Row` fake header.
4. **Content padding** `EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl)`; sections separated by `SizedBox(height: QSpace.xxl)`; items by `QSpace.sm`. Use `Column(spacing:)`/`Row(spacing:)` instead of sprinkling `SizedBox`es within a group.
5. **Lists**: `QGroupedSection` + `QListRow`/`QToggleRow` for finite settings-like lists; `SliverList.separated` with `QListRow` and `Divider(indent: 72)` for feeds. Not `ListTile` defaults (wrong heights, wrong type, Material density).
6. **Type through `context.qText.*`**, never `TextStyle(fontSize: …)` in screens. Never `textScaler: TextScaler.noScaling` on content. Tabular numbers: `fontFeatures: [FontFeature.tabularFigures()]` (already on `displayLarge`).
7. **Personality font**: set `displayFamily` in `theme.dart` to one bundled or `google_fonts` family; it's applied to `displayLarge`, `headlineLarge`, `titleLarge` only.
8. **Primary in `Scaffold.bottomNavigationBar: QBottomActionBar(children: [button], footer: [terms])`** — safe-area and keyboard aware (with `resizeToAvoidBottomInset: true`). The footer unpins at accessibility sizes (`qIsLargeText(context)`) — repeat it at the end of the scroll content inside `QLargeTextFooter(children: …)`. Never `Stack` a bar over a scroll view. Display type (hero numbers, onboarding/paywall/auth headlines) goes inside `QDisplayScale(...)`, which caps it at 1.5×; body text stays uncapped. Buttons take a minimum height, never a fixed one, so labels wrap at large text. Inline option chips go in a `Wrap(spacing: 8, runSpacing: 8)`, never a fixed `Row`, so they don't clip at large text.
9. **Corners**: `RoundedSuperellipseBorder` (continuous corners) for cards/groups; `StadiumBorder` for buttons/chips.
10. **No elevation** on cards (`Card` defaults add tint + shadow → use `QObjectCard`). Shadows only for floating elements in light mode.
11. **Icons: one family.** Material Symbols *rounded/outlined* (`Icons.*_rounded` / `*_outlined`) — pick one suffix and stick with it; or `cupertino_icons` for an iOS-only app; or one of Phosphor/Lucide. No mixing.
12. **Haptics** via `HapticFeedback.selectionClick()` (toggles/selection) and `heavyImpact()`/`mediumImpact()` for commits. Not on every tap.
13. **Motion**: `AnimatedSwitcher`/`TweenAnimationBuilder` with `QMotion.medium` + `Curves.easeOutCubic`; respect `MediaQuery.disableAnimationsOf(context)`.
14. **Sheets**: `showModalBottomSheet(context: context, useSafeArea: true, isScrollControlled: true, showDragHandle: true, …)` themed by `bottomSheetTheme` (radius 28, canvas). Use `DraggableScrollableSheet` for medium/large detents.
15. **Semantics**: `Semantics(header: true)` on titles, `MergeSemantics` for composite rows, `tooltip:` on every `IconButton` (doubles as its label), `ExcludeSemantics` on decoration.

## 2. Flutter-specific anti-patterns

| Don't | Do |
|---|---|
| `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` | `quietTheme()` / mapped brand roles |
| `Colors.blue`, `Color(0xFF…)` in widgets | `context.q.*` |
| `TextStyle(fontSize: 18, fontWeight: FontWeight.bold)` | `context.qText.titleMedium` |
| `Card(elevation: 4, child: ListTile(...))` per row | `QGroupedSection` + `QListRow` |
| `ElevatedButton` with default purple + shadow | `QPrimaryButton` (ink, stadium, 52) |
| `AppBar(backgroundColor: Colors.blue, title: Text(..., style: white))` | Canvas `SliverAppBar.large` |
| `FloatingActionButton` on iOS | App bar `+` action |
| `Center(child: CircularProgressIndicator())` full screen | `QSkeletonRow`s in the final layout |
| `padding: EdgeInsets.all(10)` | `QSpace.*` tokens |
| `MediaQuery.of(context).padding.bottom + 34` | `SafeArea` / `QBottomActionBar` |
| `Drawer` hamburger as main nav | `NavigationBar` (3–5 destinations) |
| `LinearGradient` button decoration | Solid `primaryFill` |

## 3. Verify

1. **Analyze**: `flutter analyze` — the shipped assets report "No issues found".
2. **Run** on iOS simulator and Android emulator: light, dark, text scale 1.3+ (`MediaQuery(data: …copyWith(textScaler: TextScaler.linear(1.3)))` in a debug wrapper is fine for a quick check).
3. **Golden tests** (optional but recommended for a component library): render each template in light/dark at 393×852 with `matchesGoldenFile`.
4. **Lint** with the script bundled in the `mobile-ui` skill: `python3 <mobile-ui>/scripts/mobile_ui_lint.py lib/` (`<mobile-ui>` is the sibling skill directory, e.g. `../mobile-ui`).
5. **Taste gate**: `mobile-ui §8`.
