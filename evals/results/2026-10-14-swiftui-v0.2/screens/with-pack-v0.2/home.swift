// Screen.swift — Personal budgeting home (mobile-ui archetype: Home / dashboard).
// Job: "how is October tracking?" Focal: hero "Safe to spend" amount.
// Primary action: none on canvas — "Add transaction" lives in the nav bar (+).
// Cutting: charts (belong on a Stats tab), account cards, tips carousel.
// Skin: default "Quiet" (no project tokens; user said "just build it").

import SwiftUI

// MARK: - Model

fileprivate enum Money {
    static func text(_ value: Decimal) -> String {
        value.formatted(.currency(code: "USD"))
    }
    /// Whole part + cents, for the hero ("1,326" and ".48").
    static func heroParts(_ value: Decimal) -> (whole: String, cents: String) {
        let full = value.formatted(.number.precision(.fractionLength(2)))
        guard let dot = full.lastIndex(of: ".") else { return (full, "") }
        return (String(full[..<dot]), String(full[dot...]))
    }
}

fileprivate struct CategoryBudget: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let spent: Decimal
    let limit: Decimal

    var progress: Double {
        let ratio = NSDecimalNumber(decimal: spent / limit).doubleValue
        return min(max(ratio, 0), 1)
    }
    var isOver: Bool { spent > limit }
    var statusLine: String {
        if isOver { return "\(Money.text(spent - limit)) over" }
        return "\(Money.text(limit - spent)) left of \(Money.text(limit))"
    }
}

fileprivate struct Transaction: Identifiable {
    let id = UUID()
    let merchant: String
    let detail: String
    let symbol: String
    let amount: Decimal   // negative = spent, positive = income
}

fileprivate struct MonthSnapshot {
    let monthName: String
    let budget: Decimal
    let spent: Decimal
    let daysLeft: Int
    let categories: [CategoryBudget]
    let recent: [Transaction]

    var remaining: Decimal { budget - spent }
    var perDay: Decimal {
        guard daysLeft > 0 else { return remaining }
        var raw = remaining / Decimal(daysLeft)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &raw, 2, .down)
        return rounded
    }
    var usedPercent: Int {
        Int((NSDecimalNumber(decimal: spent / budget).doubleValue * 100).rounded())
    }
    /// Categories that need attention first, capped for the home budget.
    var watchList: [CategoryBudget] {
        Array(categories.sorted { $0.progress > $1.progress }.prefix(3))
    }

    static let october = MonthSnapshot(
        monthName: "October",
        budget: 3_500,
        spent: 2_173.52,
        daysLeft: 17,
        categories: [
            .init(name: "Groceries", symbol: "cart", spent: 512.87, limit: 480),
            .init(name: "Eating out", symbol: "fork.knife", spent: 241.30, limit: 300),
            .init(name: "Transport", symbol: "tram", spent: 96.15, limit: 180),
            .init(name: "Shopping", symbol: "bag", spent: 88.40, limit: 250),
        ],
        recent: [
            .init(merchant: "Trader Joe's", detail: "Today, 8:12 AM · Groceries", symbol: "cart", amount: -64.18),
            .init(merchant: "Clipper card reload", detail: "Yesterday · Transport", symbol: "tram", amount: -40),
            .init(merchant: "Paycheck — Northwind Studio", detail: "Mon · Income", symbol: "arrow.down.left", amount: 2_846.21),
            .init(merchant: "Tartine Bakery", detail: "Sun · Eating out", symbol: "fork.knife", amount: -18.75),
        ]
    )

    static let placeholder = MonthSnapshot(
        monthName: "October", budget: 3_000, spent: 1_500, daysLeft: 15,
        categories: (0..<3).map { _ in .init(name: "Category name", symbol: "circle", spent: 100, limit: 200) },
        recent: (0..<4).map { _ in .init(merchant: "Merchant name", detail: "Date · Category", symbol: "circle", amount: -10) }
    )
}

// MARK: - Screen

struct S_home: View {
    @State private var tab = 0

    init() {}

    var body: some View {
        TabView(selection: $tab) {
            BudgetHome()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
            TabPlaceholder(title: "Activity", message: "Every transaction, searchable by merchant or category.", symbol: "list.bullet.rectangle")
                .tabItem { Label("Activity", systemImage: "list.bullet.rectangle") }
                .tag(1)
            TabPlaceholder(title: "Budgets", message: "Set and adjust monthly limits for each category.", symbol: "chart.pie")
                .tabItem { Label("Budgets", systemImage: "chart.pie") }
                .tag(2)
            TabPlaceholder(title: "Settings", message: "Accounts, currency, and notifications.", symbol: "gearshape")
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
        }
        .tint(Palette.ink)
    }
}

// MARK: - Home

fileprivate enum LoadState { case loading, loaded, failed }

fileprivate struct BudgetHome: View {
    var initialState: LoadState = .loaded
    var snapshot: MonthSnapshot = .october

    @State private var state: LoadState = .loaded
    @State private var showingAdd = false
    @State private var addedToast: String?

    var body: some View {
        NavigationStack {
            Group {
                if state == .failed {
                    EmptyState(
                        title: "Couldn't load October",
                        message: "Check your connection and try again.",
                        systemImage: "wifi.exclamationmark"
                    ) {
                        Button("Try again") { withAnimation(Motion.snappy) { state = .loaded } }
                            .buttonStyle(.secondary)
                            .fixedSize()
                    }
                    .canvasBackground()
                } else {
                    content(state == .loading ? .placeholder : snapshot)
                }
            }
            .navigationTitle(snapshot.monthName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add transaction")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTransactionSheet { merchant in
                    addedToast = "Added \(merchant)"
                    Task {
                        try? await Task.sleep(for: .seconds(2.5))
                        addedToast = nil
                    }
                }
            }
            .toast(addedToast)
            .sensoryFeedback(.success, trigger: addedToast != nil)
        }
        .onAppear { state = initialState }
    }

    private func content(_ month: MonthSnapshot) -> some View {
        let isLoading = state == .loading
        let hero = Money.heroParts(month.remaining)
        return ScrollView {
            VStack(alignment: .leading, spacing: Space.xxl) {
                VStack(alignment: .leading, spacing: Space.xl) {
                    HeroMetric(
                        label: "Safe to spend",
                        value: hero.whole,
                        prefix: "$",
                        suffix: hero.cents,
                        context: "\(month.daysLeft) days left in \(month.monthName)"
                    )
                    MetricRow(items: [
                        (Money.text(month.perDay), "a day"),
                        (Money.text(month.spent), "spent"),
                        ("\(month.usedPercent)%", "of \(Money.text(month.budget))"),
                    ])
                }

                WatchSection(categories: month.watchList)
                RecentSection(transactions: month.recent)
            }
            .padding(.horizontal, Space.margin)
            .padding(.top, Space.xs)
            .padding(.bottom, Space.xxl)
            .redacted(reason: isLoading ? .placeholder : [])
            .shimmering(isActive: isLoading)
            .allowsHitTesting(!isLoading)
        }
        .canvasBackground()
        .refreshable { try? await Task.sleep(for: .seconds(1)) }
    }
}

// MARK: - Sections

fileprivate struct WatchSection: View {
    let categories: [CategoryBudget]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHeader(title: "Budgets to watch", actionTitle: "All budgets") {}
            VStack(spacing: 0) {
                ForEach(categories) { category in
                    CategoryRow(category: category)
                        .padding(.horizontal, Space.md)
                    if category.id != categories.last?.id {
                        Divider().overlay(Palette.hairline).padding(.leading, 56)
                    }
                }
            }
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
        }
    }
}

fileprivate struct CategoryRow: View {
    let category: CategoryBudget

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            ListRow(title: category.name, subtitle: category.statusLine, systemImage: category.symbol) {
                Text("\(Int((category.progress * 100).rounded()))%")
                    .font(.dsBody)
                    .monospacedDigit()
                    .foregroundStyle(category.isOver ? Palette.negative : Palette.ink2)
            }
            ProgressView(value: category.progress)
                .tint(category.isOver ? Palette.negative : Palette.ink)
                .padding(.leading, 40)
                .padding(.bottom, Space.sm)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(category.isOver ? "Over budget" : "")
    }
}

fileprivate struct RecentSection: View {
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHeader(title: "Recent", actionTitle: "See all") {}
            if transactions.isEmpty {
                Text("No transactions yet this month. Tap + to add one.")
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
                    .frame(maxWidth: .infinity, minHeight: Metrics.rowMinHeight, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(transactions) { tx in
                        ListRow(title: tx.merchant, subtitle: tx.detail, systemImage: tx.symbol) {
                            Text(tx.amount > 0 ? "+" + Money.text(tx.amount) : Money.text(tx.amount))
                                .font(.dsBody)
                                .monospacedDigit()
                                .foregroundStyle(tx.amount > 0 ? Palette.positive : Palette.ink)
                        }
                        .padding(.horizontal, Space.md)
                        if tx.id != transactions.last?.id {
                            Divider().overlay(Palette.hairline).padding(.leading, 56)
                        }
                    }
                }
                .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
            }
        }
    }
}

// MARK: - Add transaction sheet

fileprivate struct AddTransactionSheet: View {
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var merchant = ""
    @State private var amount = ""
    @State private var category = "Groceries"
    @FocusState private var focused: Bool

    private let categories = ["Groceries", "Eating out", "Transport", "Shopping", "Bills"]
    private var canSave: Bool { !merchant.isEmpty && Decimal(string: amount) != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($focused)
                    TextField("Merchant", text: $merchant)
                        .textContentType(.organizationName)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                }
                .surfaceRow()
            }
            .canvasBackground()
            .navigationTitle("New transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(merchant)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .onAppear { focused = true }
        }
        .tint(Palette.ink)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(Radius.xl)
    }
}

// MARK: - Other tabs (out of scope for this screen)

fileprivate struct TabPlaceholder: View {
    let title: String
    let message: String
    let symbol: String

    var body: some View {
        NavigationStack {
            EmptyState(title: title, message: message, systemImage: symbol) { EmptyView() }
                .canvasBackground()
                .navigationTitle(title)
        }
    }
}

// MARK: - Previews

#Preview("Light") { S_home() }
#Preview("Dark") { S_home().preferredColorScheme(.dark) }
#Preview("Large text") { S_home().dynamicTypeSize(.accessibility2) }
#Preview("Loading") { BudgetHome(initialState: .loading) }
#Preview("Error") { BudgetHome(initialState: .failed) }
