---
name: mobile-ui-react-native
description: Build properly designed React Native / Expo screens using the mobile-ui system — native-stack headers with large titles, inset-grouped sections on a canvas, ink capsule primary buttons pinned in a safe-area bottom bar, hero metrics, platform-correct typography, haptics, skeletons, and designed dark mode. Use when writing or restyling any React Native, Expo, or Expo Router screen or component, when an RN app "looks generic", "looks like a web page", or needs a theme/tokens file. Load mobile-ui first for the screen archetype and taste gate.
license: MIT
metadata:
  version: "0.4.1"
---

# Mobile UI — React Native / Expo

The design decisions live in [`../mobile-ui/SKILL.md`](../mobile-ui/SKILL.md). **Load it first**, classify the screen, then come back here for how to build it in React Native.

Target: **Expo SDK 52+ / React Native 0.76+** (New Architecture), Expo Router or React Navigation 7 native-stack. Verified running in Expo Go on an iPhone 17 / iOS 27 simulator with **Expo SDK 57 / RN 0.86** (light, dark, accessibility-XL text).

---

## 0. Setup

1. Token gate (`mobile-ui §0`). Check for existing `theme.ts`, `tokens.ts`, `tailwind.config.js` (NativeWind), Tamagui/Unistyles/Restyle config. If one exists, map roles onto it and **don't** add `theme.ts`.
2. Otherwise copy:
   - [`assets/theme.ts`](assets/theme.ts) — palettes (light/dark), `space`, `radius`, `metrics`, `type`, `useQTheme()`.
   - [`assets/components.tsx`](assets/components.tsx) — `QText`, `QScreen`, buttons, `QBottomActionBar`, `QGroupedSection`, `QListRow`, `QToggleRow`, `QHeroMetric`, `QMetricRow`, `QObjectCard`, `QSegmented`, `QTextField`, `QChip`, `QAvatar`, `QBadge`, `QProgressBar`, `QPlanCard`, `QEmptyState`, `QSkeleton`, `QToast`, `QBarChart` (stats charts whose axis labels survive large text).
   - **Naming:** Every pack export is prefixed: `Q…` components and types (`QText`, `QScreen`, `QListRow`, `QTheme`) and `useQTheme` / `useQLargeText`. They're imported next to React Navigation's `useTheme` / `Theme` and your own components, so keep the prefix on anything you add. Token objects (`space`, `radius`, `type`) stay lowercase.
   - Deps (all Expo defaults): `npx expo install react-native-safe-area-context expo-haptics @expo/vector-icons`.
3. Template screens: [`assets/templates/`](assets/templates/) — `_layout.tsx` (root Stack), `HomeScreen`, `SettingsScreen`, `PaywallScreen` (Expo Router; notes inside for React Navigation).
4. Component-by-component code: [`references/components.md`](references/components.md).

If the project uses **NativeWind**, keep using it: add the roles as CSS variables in `global.css` (`--canvas`, `--ink` … with a `.dark` block) and map them in `tailwind.config.js` `theme.extend.colors`; spacing tokens map to Tailwind's 4px scale (`p-5` = 20, `gap-8` = 32). The rules are identical; only the syntax changes.

---

## 1. React Native opinions (the defaults that make it look designed)

1. **Native headers, always.** Expo Router `<Stack>` / React Navigation `createNativeStackNavigator` with `headerLargeTitle: true` on roots, `headerShadowVisible: false`, `headerTintColor: c.ink`, and `contentStyle: { backgroundColor: c.canvas }`. Never a custom `<View>` header with a "‹" `Text` — you lose swipe-back, large-title collapse, and platform behavior. JS-stack headers (`@react-navigation/stack`) feel non-native; prefer native-stack. Start from [`assets/templates/_layout.tsx`](assets/templates/_layout.tsx).
   - **iOS 26+ gotcha (verified):** `headerStyle: { backgroundColor }` on a large-title screen *hides the large title*. On iOS leave `headerStyle` unset — `contentStyle` paints the canvas behind the translucent header. Set it on Android only.
   - **Declare static header options in the layout** (`<Stack.Screen name="settings" options={{ title, headerLargeTitle }} />`). Titles set from inside a *pushed* screen's component may never appear. Keep only dynamic options (`headerRight`, counts) in the screen.
   - **Paywalls, onboarding, camera:** `presentation: 'fullScreenModal'`. A page-sheet `modal` already sits below the status bar, so adding `insets.top` doubles the gap.
2. **Content screens use `<QScreen>`** (ScrollView with `contentInsetAdjustmentBehavior="automatic"` so large titles collapse correctly, canvas background, 16 margin (aligned with the native large title), 32 section gap via `gap`).
3. **Long lists use `FlatList`/`FlashList`**, not `.map` in a ScrollView — with `contentInsetAdjustmentBehavior="automatic"`, `ItemSeparatorComponent` for hairlines, `ListEmptyComponent` → `QEmptyState`, and skeleton rows while loading.
4. **System font.** Leave `fontFamily` undefined (SF Pro / Roboto). Personality: load **one** display font with `expo-font` and set `DISPLAY_FAMILY` in `theme.ts` — it's applied to `hero`, `largeTitle`, `title` only. Never set Inter/Poppins as the global body font.
5. **Typography through `<QText variant color>`** only. `type` uses platform-correct sizes (17 body on iOS, 16 on Android). Numbers that change get `tabular` (`fontVariant: ['tabular-nums']`).
6. **Respect font scaling.** Don't set `allowFontScaling={false}` on content; for space-critical chrome only, `maxFontSizeMultiplier={1.6}` (decorative avatar initials: `1`). `<QText>` caps display variants (`hero`, `largeTitle`, `title`) at 1.5× — iOS large titles grow far less than body text, and an 80pt headline orphans words; body text stays uncapped. At accessibility sizes (`useQLargeText()`, fontScale ≥ 1.6) switch side-by-side layouts to stacked: `QListRow` moves its value under the title and its avatar above it, `QMetricRow` wraps, hero numbers shrink-to-fit (`<QText fit>`) instead of truncating to "2,1…". Inline option chips sit in `flexDirection: 'row', flexWrap: 'wrap'`, never a fixed row; tertiary links (Restore purchases) get no `numberOfLines`.
7. **`Pressable` with a pressed style for everything tappable** (rows → `surface2` bg, buttons → scale 0.98/opacity). No `TouchableOpacity` fading everything to 0.2. `hitSlop` to reach 44/48.
8. **Primary in `<QBottomActionBar footer={terms}>`** (safe-area aware) as a sibling *after* the scroll view, not at the end of the content and never absolutely positioned over it. The footer unpins at accessibility sizes — repeat it at the end of the scroll content inside `<QLargeTextFooter>`.
9. **Safe areas from `react-native-safe-area-context`** (`useSafeAreaInsets`), never hard-coded 34/44/47 paddings, never the deprecated core `SafeAreaView`.
10. **Sheets & dialogs native**: Expo Router `presentation: 'formSheet'` with `sheetAllowedDetents: [0.5, 1]` (or `@gorhom/bottom-sheet` when you need custom content on both platforms); `Alert.alert` / `ActionSheetIOS` for confirmations. Never an absolutely-positioned `View` + semi-transparent overlay "modal".
11. **Icons: one family.** `@expo/vector-icons` Ionicons *outline* set by default (or Lucide / Phosphor — pick one, never mix). On iOS-only projects, `expo-symbols` gives real SF Symbols.
12. **Haptics** via `expo-haptics`: `selectionAsync()` on toggles/selection, `notificationAsync(Success)` on outcomes. Not on every press.
13. **Shadows only on floating elements**, light mode only, via `floatingShadow`. No `elevation: 8` on every card.
14. **Dark mode** from `useQTheme()` (`useColorScheme`); set `userInterfaceStyle: "automatic"` in `app.json`. StatusBar via `expo-status-bar` `style="auto"`.
15. **Platform adaptivity where it matters**: confirmations (ActionSheetIOS vs Alert), date pickers (`@react-native-community/datetimepicker` native), back behavior. Otherwise one neutral design that respects both platforms' navigation.

## 2. RN-specific anti-patterns

| Don't | Do |
|---|---|
| `style={{ color: '#333', fontSize: 15 }}` | `<QText variant="subhead" color="ink2">` |
| `backgroundColor: 'white'` on screens and cards | `c.canvas` / `c.surface` |
| Every section in `<View style={styles.card}>` with `shadowOpacity: 0.1, elevation: 4` | `QGroupedSection` / space; `QObjectCard` only for objects |
| Custom header `<View>` with back arrow `Text` | Native stack header |
| `TouchableOpacity activeOpacity={0.2}` | `Pressable` + pressed style |
| `<ActivityIndicator size="large" />` centered full-screen | Skeleton rows in final layout |
| `paddingTop: 44` / `paddingBottom: 34` | `useSafeAreaInsets()` |
| `fontWeight: 'bold'` everywhere, 7 font sizes | 2 weights, `type` variants |
| Placeholder as the only label in `TextInput` | `QTextField label=…` |
| `react-native-linear-gradient` on buttons | Solid `primaryFill` |
| Emoji in `Text` as icons ("⚙️ Settings") | Ionicons glyph or none |
| `Dimensions.get('window')` for layout | Flexbox; `useWindowDimensions` only when necessary |
| `Intl.NumberFormat(...).formatToParts()`, `formatRange`, `Intl.RelativeTimeFormat` / `PluralRules` / `ListFormat` | `format()` + string ops (below). These typecheck but **don't exist in Hermes on iOS: the screen crashes** (lint MU118) |

### Money and numbers on Hermes

Hermes (React Native's engine) has only part of `Intl` on iOS. Checked on device with Expo SDK 57:

- **Safe:** `new Intl.NumberFormat(locale, { style: 'currency' | 'decimal' | 'percent' }).format(n)`, `toLocaleString`, `Intl.DateTimeFormat#format` and `#formatToParts`, `toLocaleDateString`, `localeCompare`.
- **Missing (throws):** `NumberFormat#formatToParts`, `formatRange`, `formatRangeToParts`, `Intl.PluralRules`, `RelativeTimeFormat`, `ListFormat`, `DisplayNames`, `Segmenter`, `Locale`, `DurationFormat`, `supportedValuesOf`.
- **Silently wrong:** `style: 'unit'` converts to the device's units (21.6 km renders as "13.422mi"). `notation: 'compact'` and `signDisplay` are ignored.

To give `QHeroMetric` a smaller currency symbol from the same formatter as every other amount (copy.md: one format per screen), split the formatted string instead of calling `formatToParts`. This works for symbols before or after the number (`$1,284.06`, `1.284,06 €`, `RM 1,284.06`):

```tsx
const money = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

function moneyParts(n: number) {
  const s = money.format(n);
  const first = s.search(/\d/);
  let last = s.length;
  while (last > first && !/\d/.test(s[last - 1])) last--;
  return { prefix: s.slice(0, first), value: s.slice(first, last), suffix: s.slice(last) };
}

const spent = moneyParts(2184.37);
<QHeroMetric label="Spent in October" prefix={spent.prefix} value={spent.value} suffix={spent.suffix} />
```

Units: format the number, then add the unit yourself (`${km.toFixed(1)} km`).

## 3. Verify

1. **Typecheck**: `npx tsc --noEmit` (the shipped assets pass `strict`).
2. **Run** on an iOS simulator *and* an Android emulator (Expo Go or a dev build) in light, dark, and the largest font size (iOS Settings → Accessibility → Larger Text; Android font scale 1.3+).
3. **Lint** with the script bundled in the `mobile-ui` skill: `python3 <mobile-ui>/scripts/mobile_ui_lint.py app/ components/` (`<mobile-ui>` is the sibling skill directory, e.g. `../mobile-ui`).
4. **Taste gate**: `mobile-ui §8`.
