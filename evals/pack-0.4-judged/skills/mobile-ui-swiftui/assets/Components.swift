// Components.swift — mobile-ui core components for SwiftUI (iOS 17+).
// Prefer native controls (List, Toggle, Picker(.segmented), .sheet, .searchable,
// ContentUnavailableView, .redacted) and use these only where native can't express the pattern.

import SwiftUI
import Charts

// MARK: - Buttons

/// Filled primary button: one per screen. Ink fill by default.
struct QPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dsHeadline)
            .multilineTextAlignment(.center)
            .padding(.vertical, QSpace.xs)
            .frame(maxWidth: .infinity, minHeight: QMetrics.buttonHeight)
            .padding(.horizontal, QSpace.margin)
            .foregroundStyle(isEnabled ? QPalette.onPrimary : QPalette.ink3)
            .background(isEnabled ? QPalette.primaryFill : QPalette.surface2, in: Capsule())
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(QMotion.snappy, value: configuration.isPressed)
            .contentShape(Capsule())
    }
}

/// Alternative action: same shape as primary, tonal fill.
struct QSecondaryButtonStyle: ButtonStyle {
    var role: ButtonRole? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dsHeadline)
            .multilineTextAlignment(.center)
            .padding(.vertical, QSpace.xs)
            .frame(maxWidth: .infinity, minHeight: QMetrics.buttonHeight)
            .padding(.horizontal, QSpace.margin)
            .foregroundStyle(role == .destructive ? QPalette.negative : QPalette.ink)
            .background(QPalette.surface2, in: Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(QMotion.snappy, value: configuration.isPressed)
            .contentShape(Capsule())
    }
}

/// Escape hatches: "Not now", "Restore purchases", "Skip".
struct QTertiaryButtonStyle: ButtonStyle {
    var tint: Color = QPalette.ink2

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dsSubhead.weight(.semibold))
            .foregroundStyle(tint)
            .frame(minHeight: QMetrics.minTap)
            .padding(.horizontal, QSpace.xs)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

extension ButtonStyle where Self == QPrimaryButtonStyle {
    static var qPrimary: QPrimaryButtonStyle { QPrimaryButtonStyle() }
}
extension ButtonStyle where Self == QSecondaryButtonStyle {
    static var qSecondary: QSecondaryButtonStyle { QSecondaryButtonStyle() }
}
extension ButtonStyle where Self == QTertiaryButtonStyle {
    static var qTertiary: QTertiaryButtonStyle { QTertiaryButtonStyle() }
}

/// Primary button with a loading state that keeps its width stable.
struct QPrimaryButton: View {
    let title: String
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title).opacity(isLoading ? 0 : 1)
                if isLoading { ProgressView().tint(QPalette.onPrimary) }
            }
        }
        .buttonStyle(.qPrimary)
        .disabled(isLoading)
        .accessibilityLabel(isLoading ? "\(title), loading" : title)
    }
}

// MARK: - Bottom action bar

extension View {
    /// Pins the primary action above the home indicator on a solid canvas bar (content insets itself
    /// automatically — never overlay a bar on top of scroll content).
    ///
    /// `footer` (terms, legal line, secondary links) is pinned at normal text sizes. At accessibility
    /// sizes it is NOT pinned — a tall pinned bar would cover the screen — so also place the same
    /// footer at the end of your scroll content inside `QLargeTextFooter { … }`.
    func qBottomActionBar<Bar: View, Footer: View>(
        @ViewBuilder _ bar: () -> Bar,
        @ViewBuilder footer: () -> Footer
    ) -> some View {
        modifier(QBottomActionBarModifier(bar: bar(), footer: footer()))
    }

    func qBottomActionBar<Bar: View>(@ViewBuilder _ bar: () -> Bar) -> some View {
        qBottomActionBar(bar, footer: { EmptyView() })
    }
}

struct QBottomActionBarModifier<Bar: View, Footer: View>: ViewModifier {
    let bar: Bar
    let footer: Footer
    @Environment(\.dynamicTypeSize) private var typeSize

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: QSpace.xs) {
                bar
                if !typeSize.isAccessibilitySize { footer }
            }
            .padding(.horizontal, QSpace.margin)
            .padding(.top, QSpace.sm)
            .padding(.bottom, QSpace.xs)
            .background {
                QPalette.canvas
                    .overlay(alignment: .top) { Rectangle().fill(QPalette.hairline).frame(height: 0.5) }
                    .ignoresSafeArea()
            }
        }
    }
}

/// Renders its content only at accessibility text sizes. Put it at the end of the scroll content
/// with the same footer you passed to `qBottomActionBar(_:footer:)`.
struct QLargeTextFooter<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    @ViewBuilder var content: Content

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(spacing: QSpace.xs) { content }
                .frame(maxWidth: .infinity)
                .padding(.top, QSpace.xl)
        }
    }
}

// MARK: - Section header

struct QSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.dsTitle)
                .foregroundStyle(QPalette.ink)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action).buttonStyle(.qTertiary)
            }
        }
    }
}

// MARK: - Hero metric & metric row

/// The single focal number. `prefix`/`suffix` render smaller and in ink2 ("$", "mi").
struct QHeroMetric: View {
    let label: String
    let value: String
    var prefix: String? = nil
    var suffix: String? = nil
    var context: String? = nil
    var delta: Delta? = nil

    struct Delta {
        let text: String     // "12% vs last week"
        let isUp: Bool
        var upIsGood = true
        var color: Color { (isUp == upIsGood) ? QPalette.positive : QPalette.negative }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            Text(label).qOverlineStyle()
            HStack(alignment: .firstTextBaseline, spacing: QSpace.xxs) {
                if let prefix { Text(prefix).font(.dsTitle).foregroundStyle(QPalette.ink2) }
                QHeroText(text: value)
                    .contentTransition(.numericText())
                if let suffix { Text(suffix).font(.dsTitle).foregroundStyle(QPalette.ink2) }
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: QSpace.xs) { contextLine }
                VStack(alignment: .leading, spacing: QSpace.xxs) { contextLine }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var contextLine: some View {
                if let delta {
                    Label(delta.text, systemImage: delta.isUp ? "arrow.up.right" : "arrow.down.right")
                        .font(.dsSubhead.weight(.semibold))
                        .foregroundStyle(delta.color)
                        // Wrap, never force one line: a horizontally fixed label widens the whole screen at AX sizes.
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let context {
                    Text(context).font(.dsSubhead).foregroundStyle(QPalette.ink2)
                }
    }
}

/// 2–3 secondary metrics in a quiet row. No icons, no tiles.
struct QMetricRow: View {
    let items: [(value: String, label: String)]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: QSpace.xl) { cells }
            VStack(alignment: .leading, spacing: QSpace.sm) { cells }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var cells: some View {
        ForEach(items.indices, id: \.self) { i in
            VStack(alignment: .leading, spacing: 2) {
                Text(items[i].value)
                    .font(.dsTitle)
                    .monospacedDigit()
                    .foregroundStyle(QPalette.ink)
                Text(items[i].label)
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
            }
            .accessibilityElement(children: .combine)
        }
    }
}

// MARK: - Object card

/// Cards are for objects (a plan, a booking, a media tile) — not for wrapping sections.
struct QObjectCard<Content: View>: View {
    var padding: CGFloat = QSpace.lg
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
    }
}

// MARK: - List row (for custom stacks; inside `List` prefer LabeledContent / NavigationLink)

struct QListRow<Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    @ViewBuilder var trailing: Trailing
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // At accessibility sizes the trailing value moves under the title (no mid-word squeezing).
        let stacked = typeSize.isAccessibilitySize
        HStack(spacing: QSpace.sm) {
            if let systemImage, !stacked {
                Image(systemName: systemImage)
                    .font(.body)
                    .foregroundStyle(QPalette.ink2)
                    .frame(width: 28)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.dsBody).foregroundStyle(QPalette.ink)
                if let subtitle {
                    Text(subtitle).font(.dsSubhead).foregroundStyle(QPalette.ink2).lineLimit(stacked ? nil : 2)
                }
                if stacked { trailing }
            }
            Spacer(minLength: QSpace.xs)
            if !stacked { trailing }
        }
        .padding(.vertical, QSpace.xs)
        .frame(minHeight: QMetrics.rowMinHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

extension QListRow where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, systemImage: String? = nil) {
        self.init(title: title, subtitle: subtitle, systemImage: systemImage) { EmptyView() }
    }
}

// MARK: - QChip

struct QChip: View {
    let title: String
    var isSelected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.dsSubhead.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, QSpace.sm)
                .frame(minHeight: 36)
                .foregroundStyle(isSelected ? QPalette.onPrimary : QPalette.ink)
                .background(isSelected ? QPalette.primaryFill : QPalette.surface2, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Color swatch (product variants)

/// A product color (content, not UI — define it with `// mobile-ui: content-color`). Always ringed with a
/// hairline so a black swatch survives dark mode and a white one survives light mode.
struct QSwatch: View {
    let name: String
    let color: Color
    var isSelected = false
    var size: CGFloat = 32
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .overlay(Circle().strokeBorder(QPalette.hairline, lineWidth: 1))
                .frame(width: size, height: size)
                .padding(QSpace.xxs)
                .overlay(Circle().strokeBorder(isSelected ? QPalette.ink : Color.clear, lineWidth: 2))
                .frame(minWidth: QMetrics.minTap, minHeight: QMetrics.minTap)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - QAvatar & badge

struct QAvatar: View {
    let name: String
    var image: Image? = nil
    var size: CGFloat = 40

    private var initials: String {
        name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
    }

    var body: some View {
        Group {
            if let image {
                image.resizable().scaledToFill()
            } else {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(QPalette.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(QPalette.accentSoft)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityLabel(name)
    }
}

struct QBadge: View {
    let text: String
    var tint: Color = QPalette.accent

    var body: some View {
        Text(text)
            .font(.dsFootnote.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, QSpace.xs)
            .padding(.vertical, QSpace.xxs)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

// MARK: - Progress ring

struct QProgressRing<Label: View>: View {
    let progress: Double            // 0...1
    var lineWidth: CGFloat = 12
    var tint: Color = QPalette.accent
    @ViewBuilder var label: Label

    var body: some View {
        ZStack {
            Circle().stroke(QPalette.surface2, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(QMotion.smooth, value: progress)
            label
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

// MARK: - Plan card (paywall)

struct QPlanCard: View {
    let name: String
    let price: String          // "$49.99"
    let period: String         // "/year"
    var detail: String? = nil  // "$4.17/mo"
    var badge: String? = nil   // "Save 48%"
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: QSpace.xs) {
                HStack {
                    Text(name).font(.dsHeadline).foregroundStyle(QPalette.ink)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? QPalette.ink : QPalette.ink3)
                        .accessibilityHidden(true)
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price).font(.dsTitle).monospacedDigit().foregroundStyle(QPalette.ink)
                    Text(period).font(.dsSubhead).foregroundStyle(QPalette.ink2)
                }
                if let detail { Text(detail).font(.dsFootnote).foregroundStyle(QPalette.ink2) }
                if let badge { QBadge(text: badge) }
            }
            .padding(QSpace.md)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: QRadius.l, style: .continuous)
                    .strokeBorder(isSelected ? QPalette.ink : QPalette.hairline, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Empty state
// Prefer the native ContentUnavailableView; this wrapper only fixes typography and colors.

struct QEmptyState<Actions: View>: View {
    let title: String
    let message: String
    var systemImage: String? = nil
    @ViewBuilder var actions: Actions

    var body: some View {
        ContentUnavailableView {
            if let systemImage {
                Label { Text(title).font(.dsTitle) } icon: {
                    Image(systemName: systemImage).foregroundStyle(QPalette.ink3)
                }
            } else {
                Text(title).font(.dsTitle)
            }
        } description: {
            Text(message).foregroundStyle(QPalette.ink2)
        } actions: {
            actions
        }
    }
}

// MARK: - QToast

struct QToast: View {
    let message: String
    var systemImage: String? = "checkmark"

    var body: some View {
        HStack(spacing: QSpace.xs) {
            if let systemImage { Image(systemName: systemImage).accessibilityHidden(true) }
            Text(message)
        }
        .font(.dsSubhead.weight(.semibold))
        .foregroundStyle(QPalette.onPrimary)
        .padding(.horizontal, QSpace.md)
        .frame(minHeight: 44)
        .background(QPalette.primaryFill, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}

extension View {
    /// Shows a transient toast at the top; hide it by setting `message` to nil (e.g. after 2.5s).
    func qToast(_ message: String?) -> some View {
        overlay(alignment: .top) {
            if let message {
                QToast(message: message)
                    .padding(.top, QSpace.xs)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(QMotion.smooth, value: message)
    }
}

// MARK: - Skeleton
// Use native redaction on the real layout with placeholder data:
//   RowView(item: .placeholder).redacted(reason: .placeholder).qShimmering(isActive: isLoading)

struct QShimmer: ViewModifier {
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dim = false

    func body(content: Content) -> some View {
        content
            .opacity(isActive && !reduceMotion ? (dim ? 0.45 : 1) : 1)
            .onAppear {
                guard isActive, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { dim = true }
            }
    }
}

extension View {
    func qShimmering(isActive: Bool) -> some View { modifier(QShimmer(isActive: isActive)) }
}

// MARK: - Grouped list styling

extension View {
    /// Apply to rows inside `List { Section { … } }` so groups sit on `surface` over `canvas`.
    func qSurfaceRow() -> some View {
        self.listRowBackground(QPalette.surface)
            .listRowSeparatorTint(QPalette.hairline)
    }
}

// MARK: - Bar chart

/// One bar in a `QBarChart`. `shortLabel` is what the axis shows at accessibility text sizes ("M" for "Mon").
struct QBar {
    var label: String
    var shortLabel: String
    var value: Double
    /// Spoken value, e.g. "6.2 kilometres". Defaults to the number.
    var spokenValue: String? = nil
}

/// Single-series bar chart for stats screens (screen-stats.md): one highlighted bar in `accent`, the rest
/// in ink, an optional dashed goal line, minimal axes.
///
/// Axis labels never collide, at any text size: full labels ("Mon") when they fit, single letters at
/// accessibility sizes, and Swift Charts' greedy collision resolution drops any label that would still
/// overlap (eval finding: seven day names under a phone-width chart ran together at AX-XL).
struct QBarChart: View {
    let bars: [QBar]
    var highlighted: Int? = nil
    var goal: Double? = nil
    var goalLabel: String? = nil
    var height: CGFloat = 180

    @Environment(\.dynamicTypeSize) private var typeSize

    private func axisLabel(_ i: Int) -> String {
        typeSize.isAccessibilitySize ? bars[i].shortLabel : bars[i].label
    }

    var body: some View {
        Chart {
            ForEach(bars.indices, id: \.self) { i in
                // Keyed by index, not label: "T" (Tue) and "T" (Thu) must stay separate bars.
                BarMark(x: .value("Day", String(i)), y: .value("Value", bars[i].value), width: .ratio(0.55))
                    .foregroundStyle(i == highlighted ? QPalette.accent : QPalette.ink.opacity(0.85))
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))
                    .accessibilityLabel(bars[i].label)
                    .accessibilityValue(bars[i].spokenValue ?? bars[i].value.formatted())
            }
            if let goal {
                RuleMark(y: .value("Goal", goal))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(QPalette.ink3)
                    .annotation(position: .top, alignment: .trailing) {
                        if let goalLabel {
                            Text(goalLabel).font(.dsFootnote).foregroundStyle(QPalette.ink2)
                        }
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: bars.indices.map(String.init)) { value in
                AxisValueLabel(collisionResolution: .greedy) {
                    if let i = value.as(String.self).flatMap(Int.init) {
                        Text(axisLabel(i)).font(.dsFootnote).foregroundStyle(i == highlighted ? QPalette.ink : QPalette.ink2)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine().foregroundStyle(QPalette.hairline)
                AxisValueLabel().font(.dsFootnote).foregroundStyle(QPalette.ink3)
            }
        }
        .frame(height: height)
    }
}
