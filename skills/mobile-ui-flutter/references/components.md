# Flutter component reference

Each entry maps a component from [`../../mobile-ui/references/components.md`](../../mobile-ui/references/components.md) (spec, states, rules) to Flutter. **Native** = framework widget styled by `quietTheme`. **Pack** = provided in [`../assets/components.dart`](../assets/components.dart).

| # | Component | Flutter | Source |
|---|---|---|---|
| 1 | Primary button | `QPrimaryButton(label:, onPressed:, loading:)` | Pack |
| 2 | Secondary / tertiary | `QSecondaryButton(...)` / `QTertiaryButton(...)` / `IconButton(tooltip:)` | Pack / Native |
| 3 | Nav bar & large title | `SliverAppBar.large` / `AppBar` / `CupertinoSliverNavigationBar` | Native |
| 4 | Tab bar | `NavigationBar` (M3) / `CupertinoTabScaffold` (iOS-only apps) | Native |
| 5 | List row | `QListRow(title:, subtitle:, icon:, leading:, value:, kind:, onTap:)` | Pack |
| 6 | Grouped section | `QGroupedSection(header:, footer:, children:)` | Pack |
| 7 | Section header | `QSectionHeader(title:, actionLabel:, onAction:)` | Pack |
| 8 | Hero metric | `QHeroMetric(label:, value:, prefix:, suffix:, context:, delta:)` | Pack |
| 9 | Metric row | `QMetricRow(items: [(value, label)])` | Pack |
| 10 | Card (object) | `QObjectCard(onTap:, child:)` | Pack |
| 11 | Segmented control | `SegmentedButton` / `CupertinoSlidingSegmentedControl` | Native |
| 12 | Text field | `TextField` + label above (below) | Native |
| 13 | Toggle row | `QToggleRow(title:, subtitle:, value:, onChanged:)` (uses `Switch.adaptive`) | Pack |
| 14 | Chip | `QChip(label:, selected:, onTap:)` | Pack |
| 15 | Bottom sheet | `showModalBottomSheet` (themed) / `DraggableScrollableSheet` | Native |
| 16 | Empty state | `QEmptyState(icon:, title:, message:, actionLabel:, onAction:)` | Pack |
| 17 | Skeleton | `QSkeleton(width:, height:)` / `QSkeletonRow()` | Pack |
| 18 | Toast | `showQToast(context, 'Copied', undoLabel:, onUndo:)` | Pack |
| 19 | Avatar | `QAvatar(name:, image:, size:)` | Pack |
| 20 | Badge | `QBadge(text:, color:)` | Pack |
| 20b | Color swatch | `QSwatch(name:, color:, selected:, onTap:)` | Pack |
| 21 | Progress | `QProgressRing(progress:, child:)` / `LinearProgressIndicator` | Pack / Native |
| 22 | Plan card | `QPlanCard(name:, price:, period:, detail:, badge:, selected:, onTap:)` | Pack |
| 23 | Bottom action bar | `Scaffold(bottomNavigationBar: QBottomActionBar(children: [...]))` | Pack |
| 24 | Bar chart (stats) | `QBarChart(bars: [QBar(label:, shortLabel:, value:)], highlighted:, goal:, goalLabel:)`. Axis labels stay readable at every text size | Pack |

---

## 3. App bars

```dart
// Tab root / long content: collapsing large title
CustomScrollView(slivers: [
  SliverAppBar.large(
    title: const Text('Budgets'),
    actions: [IconButton(tooltip: 'New budget', icon: const Icon(Icons.add_rounded), onPressed: _add)],
  ),
  SliverPadding(
    padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl),
    sliver: SliverList.list(children: [...]),
  ),
]);

// Pushed detail / form
Scaffold(appBar: AppBar(title: const Text('Edit budget')), body: ...);
```

## 4. Navigation bar

```dart
Scaffold(
  body: pages[index],
  bottomNavigationBar: NavigationBar(
    selectedIndex: index,
    onDestinationSelected: (i) => setState(() => index = i),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'Activity'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
    ],
  ),
);
```

Use nested `Navigator`s (or `go_router` `StatefulShellRoute`) so each tab keeps its own stack.

## 5. Feed list

```dart
SliverList.separated(
  itemCount: loading ? 6 : items.length,
  separatorBuilder: (_, __) => const Divider(indent: 72),
  itemBuilder: (context, i) => loading
      ? const QSkeletonRow()
      : QListRow(
          leading: QAvatar(name: items[i].merchant),
          title: items[i].merchant,
          subtitle: items[i].when,
          value: items[i].amount,
          onTap: () => _open(items[i]),
        ),
);
```

Pull to refresh: `RefreshIndicator.adaptive`. Swipe actions: `Dismissible` (one destructive action) or `flutter_slidable` (≤2 per side) + a long-press menu.

## 8. Ring composition

```dart
QProgressRing(
  progress: 0.42,
  child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('4,228', style: context.qText.displayLarge),
    Text('of 10,000 steps', style: context.qText.bodyMedium),
  ]),
);
```

## 11. Segmented control

```dart
SegmentedButton<Period>(
  showSelectedIcon: false,
  segments: const [
    ButtonSegment(value: Period.week, label: Text('Week')),
    ButtonSegment(value: Period.month, label: Text('Month')),
    ButtonSegment(value: Period.year, label: Text('Year')),
  ],
  selected: {period},
  onSelectionChanged: (s) {
    HapticFeedback.selectionClick();
    setState(() => period = s.first);
  },
);
```

iOS-only apps: `CupertinoSlidingSegmentedControl<Period>(groupValue: period, children: {...}, onValueChanged: ...)`.

## 12. Text field (label above)

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: QSpace.xs,
  children: [
    Text('Email', style: context.qText.bodyMedium),
    TextField(
      controller: email,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      autocorrect: false,
      decoration: InputDecoration(hintText: 'name@example.com', errorText: emailError),
    ),
  ],
);
```

Wrap related fields in `AutofillGroup`. Decoration (fill, radius 14, focus/error borders) comes from `inputDecorationTheme`.

## 15. Bottom sheet

```dart
showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (context, scroll) => Scaffold(
      appBar: AppBar(title: const Text('Filters'), automaticallyImplyLeading: false,
          actions: [QTertiaryButton(label: 'Reset', onPressed: _reset)]),
      body: ListView(controller: scroll, padding: const EdgeInsets.all(QSpace.lg), children: [...]),
      bottomNavigationBar: QBottomActionBar(children: [
        QPrimaryButton(label: 'Show 48 places', onPressed: () => Navigator.pop(context)),
      ]),
    ),
  ),
);
```

Action menus: `showAdaptiveActionSheet`-style — on iOS `showCupertinoModalPopup` + `CupertinoActionSheet` (destructive with `isDestructiveAction: true`), on Android a bottom sheet of `QListRow`s.

## 16. Empty state inside a sliver list

```dart
if (items.isEmpty)
  const SliverFillRemaining(
    hasScrollBody: false,
    child: QEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No transactions yet',
      message: 'Purchases show up here a few minutes after you pay.',
    ),
  ),
```

## 18. Toast

```dart
showQToast(context, 'Saved to Favorites', undoLabel: 'Undo', onUndo: _unsave);
```
