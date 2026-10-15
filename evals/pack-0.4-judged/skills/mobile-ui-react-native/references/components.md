# React Native component reference

Each entry maps a component from [`../../mobile-ui/references/components.md`](../../mobile-ui/references/components.md) (spec, states, rules) to React Native. **Native** = platform/navigation library primitive styled with tokens. **Pack** = provided in [`../assets/components.tsx`](../assets/components.tsx).

| # | Component | React Native | Source |
|---|---|---|---|
| 1 | Primary button | `<QPrimaryButton title onPress loading disabled />` | Pack |
| 2 | Secondary / tertiary | `<QSecondaryButton />` / `<QTertiaryButton />` / `<QIconButton icon label />` | Pack |
| 3 | Nav bar & large title | Expo Router `<Stack.Screen options>` / native-stack | Native |
| 4 | Tab bar | Expo Router `<Tabs>` / `createBottomTabNavigator` (or `expo-router/unstable-native-tabs`) | Native |
| 5 | List row | `<QListRow title subtitle icon leading value kind onPress />` | Pack |
| 6 | Grouped section | `<QGroupedSection header footer>` | Pack |
| 7 | Section header | `<QSectionHeader title action />` / `<QText variant="overline">` | Pack |
| 8 | Hero metric | `<QHeroMetric label value prefix suffix context delta />` | Pack |
| 9 | Metric row | `<QMetricRow items />` | Pack |
| 10 | Card (object) | `<QObjectCard onPress>` | Pack |
| 11 | Segmented control | `@react-native-segmented-control/segmented-control` (native) or `<QSegmented />` | Native / Pack |
| 12 | Text field | `<QTextField label error helper {...TextInputProps} />` | Pack |
| 13 | Toggle row | `<QToggleRow title subtitle value onValueChange />` | Pack |
| 14 | Chip | `<QChip title selected onPress />` | Pack |
| 15 | Bottom sheet | Expo Router `presentation: 'formSheet'` / `@gorhom/bottom-sheet` | Native |
| 16 | Empty state | `<QEmptyState icon title message action />` | Pack |
| 17 | Skeleton | `<QSkeleton width height />` / `<QSkeletonRow />` | Pack |
| 18 | Toast / banner | `<QToast message />` | Pack |
| 19 | Avatar | `<QAvatar name size />` (wrap `expo-image` for photos) | Pack |
| 20 | Badge | `<QBadge text color />` | Pack |
| 20b | Color swatch | `<QSwatch name color selected onPress />` | Pack |
| 21 | Progress | `<QProgressBar progress label />`; rings via `react-native-svg` (below) | Pack |
| 22 | Plan card | `<QPlanCard name price period detail badge selected onPress />` | Pack |
| 23 | Bottom action bar | `<QBottomActionBar>` | Pack |
| 24 | Bar chart (stats) | `<QBarChart bars={[{ label, shortLabel, value }]} highlighted goal goalLabel />`. Axis labels stay readable at every text size | Pack |

---

## 3. Native header (Expo Router)

```tsx
// app/_layout.tsx
import { Platform } from 'react-native';
import { Stack } from 'expo-router';
import { useQTheme } from '../theme';

export default function Layout() {
  const { c } = useQTheme();
  return (
    <Stack
      screenOptions={{
        headerShadowVisible: false,
        // iOS 26+: a header backgroundColor hides large titles — Android only.
        headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
        headerTintColor: c.ink,
        headerTitleStyle: { fontWeight: '600' },
        contentStyle: { backgroundColor: c.canvas },
        headerBackButtonDisplayMode: 'minimal',
      }}
    >
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      {/* Static options live here, not in the screen component (pushed-screen titles can fail to show). */}
      <Stack.Screen name="index" options={{ title: 'Budgets', headerLargeTitle: true }} />
      <Stack.Screen name="paywall" options={{ presentation: 'fullScreenModal', headerShown: false }} />
      <Stack.Screen name="filters" options={{ presentation: 'formSheet', sheetAllowedDetents: [0.5, 1], sheetGrabberVisible: true, title: 'Filters' }} />
    </Stack>
  );
}
```

Header buttons (dynamic, so set in the screen with `<Stack.Screen options>`): `headerRight: () => <QIconButton icon="add" label="New budget" onPress={…} />`. Search: `headerSearchBarOptions: { placeholder: 'Search places, people' }`.

## 4. Tab bar

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useQTheme } from '../../theme';

export default function TabsLayout() {
  const { c } = useQTheme();
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: c.ink,
        tabBarInactiveTintColor: c.ink3,
        tabBarStyle: { backgroundColor: c.canvas, borderTopColor: c.hairline },
        tabBarLabelStyle: { fontSize: 11, fontWeight: '600' },
        headerShown: false,
      }}
    >
      <Tabs.Screen name="index" options={{ title: 'Home', tabBarIcon: ({ color, focused }) => <Ionicons name={focused ? 'home' : 'home-outline'} size={24} color={color} /> }} />
      <Tabs.Screen name="activity" options={{ title: 'Activity', tabBarIcon: ({ color, focused }) => <Ionicons name={focused ? 'stats-chart' : 'stats-chart-outline'} size={24} color={color} /> }} />
      <Tabs.Screen name="settings" options={{ title: 'Settings', tabBarIcon: ({ color, focused }) => <Ionicons name={focused ? 'settings' : 'settings-outline'} size={24} color={color} /> }} />
    </Tabs>
  );
}
```

Each tab hosts its own `<Stack>` (`app/(tabs)/index/_layout.tsx`) so large titles work per tab.

## 5–6. Lists

Finite, categorized (settings, account): `QGroupedSection` + `QListRow` / `QToggleRow` (see `SettingsScreen.tsx`).

Long / dynamic (feeds, transactions, inbox):

```tsx
<FlatList
  data={loading ? [] : items}
  keyExtractor={(t) => t.id}
  contentInsetAdjustmentBehavior="automatic"
  style={{ backgroundColor: c.canvas }}
  renderItem={({ item }) => (
    <QListRow leading={<QAvatar name={item.merchant} />} title={item.merchant} subtitle={item.when} value={item.amount} onPress={() => open(item)} />
  )}
  ItemSeparatorComponent={() => <View style={{ height: StyleSheet.hairlineWidth, backgroundColor: c.hairline, marginLeft: 72 }} />}
  ListEmptyComponent={
    loading ? (
      <View>{Array.from({ length: 6 }, (_, i) => <QSkeletonRow key={i} />)}</View>
    ) : (
      <QEmptyState icon="receipt-outline" title="No transactions yet" message="Purchases show up here a few minutes after you pay." />
    )
  }
  refreshControl={<RefreshControl refreshing={refreshing} onRefresh={refresh} tintColor={c.ink2} />}
/>
```

Swipe actions: `react-native-gesture-handler` `ReanimatedSwipeable` (≤2 actions per side, destructive in `c.negative`), plus a long-press context menu (`react-native-ios-context-menu` / `zeego`) so the action isn't gesture-only.

## 8. Hero metric + ring

```tsx
<QHeroMetric label="Balance" prefix="$" value="1,240" suffix=".50" context="this month" delta={{ text: '3.2%', up: true }} />
```

Ring (requires `react-native-svg`):

```tsx
import Svg, { Circle } from 'react-native-svg';

export function ProgressRing({ progress, size = 240, stroke = 14, children }: { progress: number; size?: number; stroke?: number; children?: React.ReactNode }) {
  const { c } = useQTheme();
  const r = (size - stroke) / 2;
  const circ = 2 * Math.PI * r;
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }} accessibilityRole="progressbar" accessibilityValue={{ min: 0, max: 100, now: Math.round(progress * 100) }}>
      <Svg width={size} height={size} style={{ position: 'absolute', transform: [{ rotate: '-90deg' }] }}>
        <Circle cx={size / 2} cy={size / 2} r={r} stroke={c.surface2} strokeWidth={stroke} fill="none" />
        <Circle cx={size / 2} cy={size / 2} r={r} stroke={c.accent} strokeWidth={stroke} fill="none" strokeLinecap="round" strokeDasharray={`${circ} ${circ}`} strokeDashoffset={circ * (1 - Math.min(Math.max(progress, 0), 1))} />
      </Svg>
      {children}
    </View>
  );
}
```

## 11. Segmented control (native on iOS)

```tsx
import SegmentedControl from '@react-native-segmented-control/segmented-control';

<SegmentedControl
  values={['Week', 'Month', 'Year']}
  selectedIndex={index}
  onChange={(e) => setIndex(e.nativeEvent.selectedSegmentIndex)}
  appearance={dark ? 'dark' : 'light'}
/>
```

## 12. Text field

```tsx
<QTextField
  label="Email"
  value={email}
  onChangeText={setEmail}
  placeholder="name@example.com"
  keyboardType="email-address"
  autoCapitalize="none"
  autoComplete="email"
  textContentType="emailAddress"
  returnKeyType="next"
  onSubmitEditing={() => passwordRef.current?.focus()}
  error={emailError}
/>
```

Keyboard-aware bottom bar: wrap the screen in `KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined}` (or `react-native-keyboard-controller`'s `KeyboardStickyView`) with `<QBottomActionBar>` inside.

## 15. Sheet with custom content

```tsx
// app/filters.tsx — presented as formSheet by the root Stack
export default function Filters() {
  return (
    <View style={{ flex: 1, backgroundColor: c.canvas }}>
      <ScrollView contentContainerStyle={{ padding: space.lg, gap: space.xl }}>
        <QText variant="overline" color="ink2">Sort by</QText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: space.xs }}>
          {sorts.map((s) => <QChip key={s} title={s} selected={s === sort} onPress={() => setSort(s)} />)}
        </View>
        <QGroupedSection><QToggleRow title="Open now" value={openNow} onValueChange={setOpenNow} /></QGroupedSection>
      </ScrollView>
      <QBottomActionBar><QPrimaryButton title={`Show ${count} places`} onPress={() => router.back()} /></QBottomActionBar>
    </View>
  );
}
```

## 18. Toast

```tsx
const [toast, setToast] = useState<string | null>(null);
useEffect(() => {
  if (!toast) return;
  const t = setTimeout(() => setToast(null), 2500);
  return () => clearTimeout(t);
}, [toast]);
…
{toast && <QToast message={toast} />}
```

## 19. Avatar with photo

```tsx
import { Image } from 'expo-image';
{uri ? <Image source={{ uri }} style={{ width: 40, height: 40, borderRadius: 20 }} accessibilityLabel={name} /> : <QAvatar name={name} />}
```
