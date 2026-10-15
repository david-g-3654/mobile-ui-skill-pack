---
name: mobile-ui-swiftui
description: Build properly designed iOS screens in SwiftUI using the mobile-ui system — native NavigationStack, inset-grouped Lists on a canvas, ink primary buttons, hero metrics, Dynamic Type, SF Symbols, sheets with detents, haptics, and dark mode. Use when writing or restyling any SwiftUI view, screen, or component, or when an iOS app "looks generic", "looks like a default template", or needs a design system (DesignSystem.swift, tokens, ButtonStyles). Load mobile-ui first for the screen archetype and taste gate.
license: MIT
metadata:
  version: "0.4"
---

# Mobile UI — SwiftUI

The design decisions live in [`../mobile-ui/SKILL.md`](../mobile-ui/SKILL.md). **Load it first**, classify the screen, then come back here for how to build it in SwiftUI.

Target: **iOS 17+**, Swift 6. (If the project targets iOS 16, replace `sensoryFeedback`, `ContentUnavailableView`, and `.snappy`/`.smooth` with UIKit haptics, a custom empty view, and `.spring`.)

---

## 0. Setup

1. Token gate (`mobile-ui §0`). If the project has no tokens, copy:
   - [`assets/DesignSystem.swift`](assets/DesignSystem.swift) — color roles, type, spacing, radius, motion.
   - [`assets/Components.swift`](assets/Components.swift) — button styles, hero metric, metric row, bar chart (`QBarChart`, Swift Charts), cards, chips, plan card, avatar, badge, ring, toast, empty state, skeleton.
   - **Naming:** Every pack symbol is prefixed: types `Q…` (`QListRow`, `QSpace`, `QPalette`), View modifiers and styles `q…` (`.qSurfaceRow()`, `.qBottomActionBar`, `.buttonStyle(.qPrimary)`). They live in your app's module namespace, so the prefix keeps them from colliding with your own types or a future SwiftUI name. Keep the prefix on anything you add to these files.
2. Template screens to start from (copy, rename, replace content): [`assets/templates/`](assets/templates/) — `HomeScreen`, `SettingsScreen`, `PaywallScreen`. Each compiles standalone with the two files above and ships light/dark/large-text previews.
3. Component-by-component code: [`references/components.md`](references/components.md).

---

## 1. SwiftUI opinions (the defaults that make it look designed)

1. **`NavigationStack` + system bars, always.** Large titles on tab roots (`.navigationTitle`, default display mode), `.inline` on pushed detail/forms/sheets. Never hand-draw a header `HStack` with a back chevron — you lose swipe-back, large-title collapse, and accessibility.
2. **Lists are `List` with `.listStyle(.insetGrouped)` on a canvas.** Apply `.qCanvasBackground()` to the list and `.qSurfaceRow()` to rows. Native rows: `LabeledContent`, `Toggle`, `Picker` (menu), `DatePicker` (compact), `NavigationLink`. This alone fixes most "generic settings" screens.
3. **Content screens are `ScrollView { VStack(alignment: .leading, spacing: QSpace.xxl) }`** with `.padding(.horizontal, QSpace.margin)` (16 — aligns with the large title and inset-grouped lists). Sections separated by `QSpace.xxl`, items within by `QSpace.sm`. Not `List` (List fights custom hero layouts).
4. **Type via text styles.** `.font(.dsHeadline)` etc. are text styles → Dynamic Type for free. For the hero, use `QHeroText` (scales with `@ScaledMetric`). Never `.font(.system(size: 15))` in screens.
5. **Personality via `Font.Design`.** Change `QTypeface.display` to `.serif` (editorial, journaling), `.rounded` (playful, health), or `.monospaced` (data, weather) — it's applied to `largeTitle`, `title`, and `hero` only. Don't import Inter/Poppins on iOS.
6. **Primary = `.buttonStyle(.qPrimary)`**, capsule, ink. Pin it with `.qBottomActionBar { button } footer: { terms }` (a `safeAreaInset`), not by placing it at the end of the scroll content. The footer unpins at accessibility sizes — repeat it at the end of the scroll content inside `QLargeTextFooter { … }`.
7. **Continuous corners**: `RoundedRectangle(cornerRadius: QRadius.l, style: .continuous)`. `Capsule()` for buttons, chips, toasts.
8. **SF Symbols only**, `.font(.body)`-sized in rows, rendered in `QPalette.ink`/`ink2`. Use `.symbolRenderingMode(.hierarchical)` for depth, not multicolor (except for status like `checkmark.seal.fill`). Icon-only buttons always get `.accessibilityLabel("Verb object")`.
9. **Sheets**: `.sheet(isPresented:) { … .presentationDetents([.medium, .large]).presentationCornerRadius(QRadius.xl) }`. Confirmations: `.confirmationDialog` with a specific destructive verb. Never a custom overlay "modal".
10. **Search**: `.searchable(text:prompt:)` with `.searchSuggestions` for the idle state.
11. **Empty/loading**: `ContentUnavailableView` (via `QEmptyState`) and `.redacted(reason: .placeholder)` on the real layout with placeholder data + `.qShimmering(isActive:)`. Never a centered `ProgressView()` filling the screen.
12. **Haptics**: `.sensoryFeedback(.selection, trigger:)` on toggles/selection, `.success`/`.error` on outcomes. Not on every tap.
13. **Motion**: `withAnimation(QMotion.snappy)` for state toggles; `.contentTransition(.numericText())` on changing numbers; `matchedGeometryEffect`/`navigationTransition(.zoom)` (iOS 18) only for hero media.
14. **Tint**: set `.tint(QPalette.ink)` at the root (nav glyphs, links) and `.tint(QPalette.positive)` or `QPalette.accent` on toggles — pick one switch color per app.
15. **Materials** (`.ultraThinMaterial`) only on floating chrome over content (floating tab island, media overlay buttons), never on content cards.

## 2. Platform conventions to respect

- Tab bar: `TabView` with `.tabItem { Label("Home", systemImage: "house") }` (or iOS 18 `Tab` API), 3–5 tabs, SF Symbol outline/fill pairs handled by the system.
- Nav bar actions: ≤2 trailing `ToolbarItem`s; "+" for create on list roots; "Done" (semibold) to dismiss modals, "Cancel" on the leading side of forms in sheets.
- Swipe actions: `.swipeActions` (destructive with `role: .destructive`), context menus `.contextMenu` with `Label`s.
- Pull to refresh: `.refreshable`.
- Keyboard: `.scrollDismissesKeyboard(.interactively)`, `.submitLabel(.next/.go)`, `.textContentType(...)`, `.keyboardType(...)`, `@FocusState` to move between fields.
- Safe area: `safeAreaInset(edge: .bottom)` for pinned bars; never hard-code 34pt home-indicator padding.

## 3. SwiftUI-specific anti-patterns

| Don't | Do |
|---|---|
| `Color.blue`, `Color(red:…)`, `Color("#…")` in a screen | `QPalette.*` |
| `.font(.system(size: 22, weight: .bold))` | `.font(.dsTitle)` |
| `.shadow(radius: 10)` on cards | No shadow; `surface` on `canvas` |
| `VStack { HStack { Button("<") … Text("Title") } … }` header | `NavigationStack` + `.navigationTitle` |
| `Rectangle().frame(height: 1).foregroundColor(.gray)` | `Divider().overlay(QPalette.hairline)` or List separators |
| `.padding()` (defaults to 16) everywhere | Explicit `QSpace` tokens |
| `Image(systemName:)` buttons without labels | `.accessibilityLabel` |
| `.frame(height: 40)` buttons | `QMetrics.buttonHeight` (52), min tap 44 |
| `LinearGradient` button backgrounds | Solid `primaryFill` |
| `.foregroundColor(.gray)` | `.foregroundStyle(QPalette.ink2)` |
| `ZStack { Color.black.opacity(0.4); VStack {…} }` custom modal | `.sheet` / `.confirmationDialog` |
| `.tint(QPalette.positive)` on a whole `List` (turns picker values and row text green) | `.tint(QPalette.ink)` at the root; `.tint(QPalette.positive)` on each `Toggle` |
| Fixed `HStack` avatar + name that wraps word-by-word at accessibility sizes | `AnyLayout(typeSize.isAccessibilitySize ? VStackLayout : HStackLayout)` or `ViewThatFits` |

## 4. Verify

1. **Compile**: build the target (or `xcrun swiftc -typecheck -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) -target arm64-apple-ios17.0-simulator <files>`).
2. **Previews**: every screen file has `#Preview` for Light, Dark, and `.dynamicTypeSize(.accessibility2)`; check all three.
3. **Lint** with the script bundled in the `mobile-ui` skill: `python3 <mobile-ui>/scripts/mobile_ui_lint.py path/to/Screens` (`<mobile-ui>` is the sibling skill directory, e.g. `../mobile-ui`).
4. **Run the taste gate** in `mobile-ui §8`.
