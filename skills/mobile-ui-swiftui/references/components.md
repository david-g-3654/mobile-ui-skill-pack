# SwiftUI component reference

Each entry maps a component from [`../../mobile-ui/references/components.md`](../../mobile-ui/references/components.md) (spec, states, rules) to SwiftUI. **Native** = use the system control styled with tokens. **Pack** = provided in [`../assets/Components.swift`](../assets/Components.swift).

| # | Component | SwiftUI | Source |
|---|---|---|---|
| 1 | Primary button | `Button(…).buttonStyle(.qPrimary)` / `QPrimaryButton(title:isLoading:action:)` | Pack |
| 2 | Secondary / tertiary | `.buttonStyle(.qSecondary)` / `.buttonStyle(.qTertiary)` | Pack |
| 3 | Nav bar & large title | `NavigationStack` + `.navigationTitle` + `.toolbar` | Native |
| 4 | Tab bar | `TabView` + `.tabItem` (iOS 18: `Tab`) | Native |
| 5 | List row | `LabeledContent`, `NavigationLink`, `Toggle` in `List`; `QListRow` in stacks | Native / Pack |
| 6 | Grouped section | `List { Section {…} header: {…} footer: {…} }.listStyle(.insetGrouped)` | Native |
| 7 | Section header | `QSectionHeader(title:actionTitle:action:)` / `Text(…).qOverlineStyle()` | Pack |
| 8 | Hero metric | `QHeroMetric(label:value:prefix:suffix:context:delta:)` / `QHeroText` | Pack |
| 9 | Metric row | `QMetricRow(items:)` | Pack |
| 10 | Card (object) | `QObjectCard { … }` | Pack |
| 11 | Segmented control | `Picker(…).pickerStyle(.segmented)` | Native |
| 12 | Text field | `TextField` + label above (see below) | Native |
| 13 | Toggle row | `Toggle` in `List` | Native |
| 14 | Chip | `QChip(title:isSelected:action:)` | Pack |
| 15 | Bottom sheet | `.sheet` + `.presentationDetents` | Native |
| 16 | Empty state | `QEmptyState(title:message:systemImage:actions:)` (wraps `ContentUnavailableView`) | Pack |
| 17 | Skeleton | `.redacted(reason: .placeholder)` + `.qShimmering(isActive:)` | Native + Pack |
| 18 | Toast / banner | `.qToast(message)` | Pack |
| 19 | Avatar | `QAvatar(name:image:size:)` | Pack |
| 20 | Badge | `QBadge(text:tint:)` | Pack |
| 20b | Color swatch | `QSwatch(name:color:isSelected:action:)` | Pack |
| 21 | Progress | `QProgressRing(progress:) { label }` / `ProgressView(value:)` + `.tint` | Pack / Native |
| 22 | Plan card | `QPlanCard(name:price:period:detail:badge:isSelected:action:)` | Pack |
| 23 | Bottom action bar | `.qBottomActionBar { … }` | Pack |
| 24 | Bar chart (stats) | `QBarChart(bars: [QBar(label:shortLabel:value:)], highlighted:goal:goalLabel:)`. Axis labels stay readable at every text size | Pack (Swift Charts) |

---

## 1–2. Buttons

```swift
VStack(spacing: QSpace.sm) {
    QPrimaryButton(title: "Create account", isLoading: isSubmitting) { submit() }
    Button("Log in") { showLogin = true }.buttonStyle(.qSecondary)
    Button("Not now") { dismiss() }.buttonStyle(.qTertiary)
}
Button("Delete 3 photos", role: .destructive) { … }.buttonStyle(QSecondaryButtonStyle(role: .destructive))
```

## 3. Navigation bar

```swift
NavigationStack {
    content
        .navigationTitle("Budgets")                 // large on roots
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { add() } label: { Image(systemName: "plus") }
                    .accessibilityLabel("New budget")
            }
        }
}
.tint(QPalette.ink)

// Pushed detail / form
.navigationBarTitleDisplayMode(.inline)
// Image-led detail: content scrolls under a transparent bar
.toolbarBackground(.hidden, for: .navigationBar)
```

## 4. Tab bar

```swift
TabView {
    HomeScreen().tabItem { Label("Home", systemImage: "house") }
    ActivityScreen().tabItem { Label("Activity", systemImage: "chart.bar") }
    SettingsScreen().tabItem { Label("Settings", systemImage: "gearshape") }
}
.tint(QPalette.ink)
```

Floating island (personality option): hide the system bar (`.toolbar(.hidden, for: .tabBar)`) only if you rebuild selection, accessibility (`.accessibilityAddTraits(.isSelected)`), and `safeAreaInset(edge: .bottom)` spacing; a `Capsule()` with `.background(.ultraThinMaterial)` or `QPalette.surface` + `.shadow(color: .black.opacity(0.08), radius: 12, y: 8)` in light mode only.

## 5–6. Rows and grouped sections

```swift
List {
    Section {
        LabeledContent("Currency", value: "USD")          // value row
        NavigationLink("Notifications") { NotificationsScreen() }
        Toggle("Daily reminder", isOn: $daily)
    } header: {
        Text("Preferences").qOverlineStyle()
    } footer: {
        Text("Reminders arrive 10 minutes before your wake-up time.")
            .font(.dsFootnote).foregroundStyle(QPalette.ink2)
    }
    .qSurfaceRow()   // apply per row or per Section content
}
.listStyle(.insetGrouped)
.qCanvasBackground()
```

Custom row in a `ScrollView` stack (home, detail): `QListRow(title:subtitle:systemImage:) { trailing }` inside a `VStack(spacing: 0)` on `QPalette.surface` with `Divider().overlay(QPalette.hairline).padding(.leading, 56)` between rows.

Settings icon tiles (only if every row has one):

```swift
Label {
    Text("Notifications")
} icon: {
    Image(systemName: "bell.fill")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.white)
        .frame(width: 29, height: 29)
        .background(QPalette.negative, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
}
```

## 8–9. Hero metric & metric row

```swift
VStack(alignment: .leading, spacing: QSpace.xl) {
    QHeroMetric(label: "Balance", value: "1,240", prefix: "$", suffix: ".50",
               context: "this month",
               delta: .init(text: "3.2%", isUp: true))
    QMetricRow(items: [("$612", "income"), ("$418", "spent"), ("14", "transactions")])
}
```

Ring composition (daily goal, centered):

```swift
QProgressRing(progress: 0.42, lineWidth: 14) {
    VStack(spacing: 2) {
        QHeroText(text: "4,228", size: 48)
        Text("of 10,000 steps").font(.dsSubhead).foregroundStyle(QPalette.ink2)
    }
}
.frame(width: 240, height: 240)
```

## 10. Object card

```swift
QObjectCard {
    VStack(alignment: .leading, spacing: QSpace.xs) {
        Text("Lisbon · Oct 3–7").font(.dsHeadline)
        Text("Hotel Lumiares · 4 nights").font(.dsSubhead).foregroundStyle(QPalette.ink2)
    }
}
```

## 11. Segmented control

```swift
Picker("Period", selection: $period) {
    Text("Week").tag(Period.week)
    Text("Month").tag(Period.month)
    Text("Year").tag(Period.year)
}
.pickerStyle(.segmented)
.sensoryFeedback(.selection, trigger: period)
```

## 12. Text field (label above, never placeholder-as-label)

```swift
VStack(alignment: .leading, spacing: QSpace.xs) {
    Text("Email").font(.dsSubhead).foregroundStyle(QPalette.ink2)
    TextField("", text: $email, prompt: Text("name@example.com").foregroundStyle(QPalette.ink3))
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .submitLabel(.next)
        .focused($focus, equals: .email)
        .padding(.horizontal, QSpace.md)
        .frame(height: QMetrics.fieldHeight)
        .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.m, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: QRadius.m, style: .continuous)
                .strokeBorder(error != nil ? QPalette.negative : (focus == .email ? QPalette.ink : QPalette.hairline),
                              lineWidth: focus == .email || error != nil ? 1.5 : 1)
        }
    if let error {
        Text(error).font(.dsFootnote).foregroundStyle(QPalette.negative)
    }
}
```

## 14. Chips

```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: QSpace.xs) {
        ForEach(filters) { f in QChip(title: f.name, isSelected: f == selected) { selected = f } }
    }
    .padding(.horizontal, QSpace.margin)
}
.scrollClipDisabled()
```

## 15. Bottom sheet

```swift
.sheet(isPresented: $showFilters) {
    NavigationStack {
        FiltersView()
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Reset") { reset() } } }
            .qBottomActionBar { Button("Show 48 places") { showFilters = false }.buttonStyle(.qPrimary) }
    }
    .presentationDetents([.medium, .large])
    .presentationCornerRadius(QRadius.xl)
    .presentationBackground(QPalette.canvas)
}
```

Action menu on an item: `.contextMenu { Button("Share", systemImage: "square.and.arrow.up") {…}; Button("Delete", systemImage: "trash", role: .destructive) {…} }`.

## 16–17. Empty & skeleton

```swift
if items.isEmpty && !isLoading {
    QEmptyState(title: "No budgets yet",
               message: "Set a monthly limit for food, rent, or anything else.",
               systemImage: "chart.pie") {
        Button("Create a budget") { create() }.buttonStyle(.qSecondary).fixedSize()
    }
} else {
    ForEach(isLoading ? Budget.placeholders : items) { BudgetRow(budget: $0) }
        .redacted(reason: isLoading ? .placeholder : [])
        .qShimmering(isActive: isLoading)
}
```

## 18. Toast

```swift
@State private var toastMessage: String?
…
.qToast(toastMessage)
.task(id: toastMessage) {
    guard toastMessage != nil else { return }
    try? await Task.sleep(for: .seconds(2.5))
    toastMessage = nil
}
```

## 22–23. Plan card & bottom action bar

See [`../assets/templates/PaywallScreen.swift`](../assets/templates/PaywallScreen.swift) for the full composition: two `QPlanCard`s in an `HStack(spacing: QSpace.sm)`, `.qBottomActionBar { QPrimaryButton …; terms text; Terms · Privacy links }`.
