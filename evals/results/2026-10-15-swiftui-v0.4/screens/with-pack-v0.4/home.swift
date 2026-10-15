// Screen.swift — Personal budgeting app, Home (archetype: home/dashboard).
// Job: "see what's left this month". Focal: hero amount left. Primary: none on screen —
// "Add transaction" lives in the nav bar. Cut: charts (belong on a Stats tab), account list, promo card.
// Skin: default "Quiet" (no project tokens; user said "just build it").

import SwiftUI

// MARK: - Root

struct S_home: View {
    init() {}

    var body: some View {
        TabView {
            BudgetHomeView(phase: .loaded)
                .tabItem { Label("Home", systemImage: "house") }
            TabPlaceholder(title: "Activity", message: "Every card and account transaction, searchable.", systemImage: "list.bullet.rectangle")
                .tabItem { Label("Activity", systemImage: "list.bullet.rectangle") }
            TabPlaceholder(title: "Budgets", message: "Set and adjust monthly limits by category.", systemImage: "chart.pie")
                .tabItem { Label("Budgets", systemImage: "chart.pie") }
            TabPlaceholder(title: "Settings", message: "Accounts, currency and notifications.", systemImage: "gearshape")
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(QPalette.ink)
    }
}

// MARK: - Money formatting (one formatter for the whole screen)

fileprivate enum Money {
    static let style = Decimal.FormatStyle.Currency(code: "USD", locale: Locale(identifier: "en_US"))

    static func text(_ value: Decimal) -> String { value.formatted(style) }

    /// Whole dollars for secondary metrics ("$2,348").
    static func whole(_ value: Decimal) -> String { value.formatted(style.precision(.fractionLength(0))) }

    /// Signed for transaction rows: "−$38.40" / "+$2,105.00".
    static func signed(_ value: Decimal) -> String {
        let magnitude = text(value < 0 ? -value : value)
        return value < 0 ? "−" + magnitude : "+" + magnitude
    }

    /// Splits "$1,862.37" into ("$", "1,862", ".37") for the hero.
    static func heroParts(_ value: Decimal) -> (prefix: String, whole: String, cents: String) {
        let full = text(value)
        let symbolEnd = full.firstIndex(where: { $0.isNumber }) ?? full.startIndex
        let prefix = String(full[..<symbolEnd])
        let number = String(full[symbolEnd...])
        if let dot = number.lastIndex(of: ".") {
            return (prefix, String(number[..<dot]), String(number[dot...]))
        }
        return (prefix, number, "")
    }
}

// MARK: - Sample data

fileprivate struct CategoryBudget: Identifiable {
    let id = UUID()
    let name: String
    let systemImage: String
    let spent: Decimal
    let limit: Decimal

    var progress: Double {
        let ratio = (spent / limit) as NSDecimalNumber
        return ratio.doubleValue
    }
    var isOverPace: Bool { progress > 0.85 }
    var remaining: Decimal { limit - spent }
}

fileprivate struct UpcomingBill: Identifiable {
    let id = UUID()
    let name: String
    let due: String
    let amount: Decimal
    let systemImage: String
}

fileprivate struct Transaction: Identifiable {
    let id = UUID()
    let merchant: String
    let detail: String
    let amount: Decimal
    let systemImage: String
}

fileprivate struct MonthSnapshot {
    let month: String
    let left: Decimal
    let daysLeft: Int
    let paceDelta: Decimal          // positive = under pace
    let spent: Decimal
    let income: Decimal
    let saved: Decimal
    let categories: [CategoryBudget]
    let bills: [UpcomingBill]
    let recent: [Transaction]

    var perDay: Decimal { daysLeft > 0 ? left / Decimal(daysLeft) : left }

    static let sample = MonthSnapshot(
        month: "October",
        left: 1862.37,
        daysLeft: 16,
        paceDelta: 42.15,
        spent: 2347.63,
        income: 4210.00,
        saved: 600.00,
        categories: [
            .init(name: "Dining out", systemImage: "fork.knife", spent: 371.84, limit: 400),
            .init(name: "Groceries", systemImage: "cart", spent: 288.12, limit: 550),
            .init(name: "Rides & transit", systemImage: "tram", spent: 64.50, limit: 180),
        ],
        bills: [
            .init(name: "Car insurance — Geico", due: "Due Friday", amount: -143.22, systemImage: "car"),
            .init(name: "Comcast internet", due: "Oct 22", amount: -79.99, systemImage: "wifi"),
            .init(name: "iCloud+", due: "Oct 27", amount: -2.99, systemImage: "icloud"),
        ],
        recent: [
            .init(merchant: "Trader Joe's", detail: "Today · Groceries", amount: -64.18, systemImage: "cart"),
            .init(merchant: "Payroll — Northwind Labs", detail: "Yesterday · Income", amount: 2105.00, systemImage: "building.columns"),
            .init(merchant: "Tartine Bakery", detail: "Yesterday · Dining out", amount: -18.75, systemImage: "fork.knife"),
            .init(merchant: "BART", detail: "Mon", amount: -6.40, systemImage: "tram"),
        ]
    )

    static let firstRun = MonthSnapshot(
        month: "October", left: 0, daysLeft: 16, paceDelta: 0,
        spent: 0, income: 0, saved: 0, categories: [], bills: [], recent: []
    )
}

// MARK: - Home

fileprivate enum LoadPhase { case loading, loaded, refreshFailed, empty }

fileprivate struct BudgetHomeView: View {
    var phase: LoadPhase
    var snapshot: MonthSnapshot = .sample

    @State private var showingAdd = false
    @State private var bannerDismissed = false

    private var data: MonthSnapshot { phase == .empty ? .firstRun : snapshot }
    private var isLoading: Bool { phase == .loading }

    var body: some View {
        NavigationStack {
            Group {
                if phase == .empty {
                    QEmptyState(
                        title: "Set up your first budget",
                        message: "Connect an account or add a monthly limit, and what's left to spend shows up here.",
                        systemImage: "chart.pie"
                    ) {
                        Button("Connect an account") {}
                            .buttonStyle(.qSecondary)
                    }
                    .qCanvasBackground()
                } else {
                    content
                }
            }
            .navigationTitle(data.month)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add transaction")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTransactionSheet()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(QRadius.xl)
            }
        }
        .tint(QPalette.ink)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xxl) {
                if phase == .refreshFailed && !bannerDismissed {
                    refreshBanner
                }
                hero
                categorySection
                billsSection
                recentSection
            }
            .padding(.horizontal, QSpace.margin)
            .padding(.top, QSpace.xs)
            .padding(.bottom, QSpace.xxl)
            .redacted(reason: isLoading ? .placeholder : [])
            .qShimmering(isActive: isLoading)
        }
        .qCanvasBackground()
        .refreshable {}
    }

    // Focal: amount left this month.
    private var hero: some View {
        let parts = Money.heroParts(data.left)
        return VStack(alignment: .leading, spacing: QSpace.xl) {
            QHeroMetric(
                label: "Left this month",
                value: parts.whole,
                prefix: parts.prefix,
                suffix: parts.cents,
                context: "\(data.daysLeft) days left · about \(Money.whole(data.perDay)) a day",
                delta: .init(text: "\(Money.text(data.paceDelta)) under pace", isUp: true, upIsGood: true)
            )
            QMetricRow(items: [
                (Money.whole(data.spent), "spent"),
                (Money.whole(data.income), "came in"),
                (Money.whole(data.saved), "to savings"),
            ])
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            QSectionHeader(title: "Budgets", actionTitle: "See all") {}
            VStack(spacing: 0) {
                ForEach(data.categories) { category in
                    CategoryRow(category: category)
                        .padding(.horizontal, QSpace.md)
                    if category.id != data.categories.last?.id {
                        Divider().overlay(QPalette.hairline).padding(.leading, QSpace.md)
                    }
                }
            }
            .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
        }
    }

    private var billsSection: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            QSectionHeader(title: "Coming up")
            if data.bills.isEmpty {
                Text("No bills due before the 31st.")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                    .frame(maxWidth: .infinity, minHeight: QMetrics.rowMinHeight, alignment: .leading)
            } else {
                groupedRows(data.bills) { bill in
                    QListRow(title: bill.name, subtitle: bill.due, systemImage: bill.systemImage) {
                        amountText(bill.amount)
                    }
                }
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            QSectionHeader(title: "Recent", actionTitle: "All activity") {}
            groupedRows(data.recent) { tx in
                QListRow(title: tx.merchant, subtitle: tx.detail, systemImage: tx.systemImage) {
                    amountText(tx.amount)
                }
            }
        }
    }

    private var refreshBanner: some View {
        HStack(spacing: QSpace.sm) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(QPalette.warning)
                .accessibilityHidden(true)
            Text("Couldn't refresh · Showing balances from 9:41 AM")
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Retry") { bannerDismissed = true }
                .buttonStyle(.qTertiary)
                .frame(minHeight: QMetrics.minTap)
        }
        .padding(.horizontal, QSpace.md)
        .padding(.vertical, QSpace.xs)
        .background(QPalette.surface2, in: RoundedRectangle(cornerRadius: QRadius.m, style: .continuous))
    }

    private func amountText(_ amount: Decimal) -> some View {
        Text(Money.signed(amount))
            .font(.dsBody)
            .monospacedDigit()
            .foregroundStyle(amount > 0 ? QPalette.positive : QPalette.ink)
    }

    private func groupedRows<Item: Identifiable, Row: View>(_ items: [Item], @ViewBuilder row: @escaping (Item) -> Row) -> some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                row(item)
                    .padding(.horizontal, QSpace.md)
                if item.id != items.last?.id {
                    Divider().overlay(QPalette.hairline).padding(.leading, 56)
                }
            }
        }
        .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
    }
}

// MARK: - Category row (name, remaining, progress)

fileprivate struct CategoryRow: View {
    let category: CategoryBudget

    var body: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    title
                    Spacer(minLength: QSpace.xs)
                    remaining
                }
                VStack(alignment: .leading, spacing: QSpace.xxs) {
                    title
                    remaining
                }
            }
            ProgressView(value: min(category.progress, 1))
                .tint(category.isOverPace ? QPalette.warning : QPalette.ink)
                .accessibilityHidden(true)
        }
        .padding(.vertical, QSpace.sm)
        .frame(minHeight: QMetrics.rowMinHeight)
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(Int(category.progress * 100)) percent used")
    }

    private var title: some View {
        Text(category.name).font(.dsBody).foregroundStyle(QPalette.ink)
    }

    private var remaining: some View {
        Text("\(Money.text(category.remaining)) left of \(Money.text(category.limit))")
            .font(.dsSubhead)
            .monospacedDigit()
            .foregroundStyle(category.isOverPace ? QPalette.warning : QPalette.ink2)
    }
}

// MARK: - Add transaction sheet

fileprivate struct AddTransactionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var merchant = ""
    @State private var amount = ""
    @State private var category = "Groceries"
    private let categories = ["Groceries", "Dining out", "Rides & transit", "Bills", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Merchant", text: $merchant)
                    .textContentType(.organizationName)
                    .qSurfaceRow()
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .qSurfaceRow()
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
                .qSurfaceRow()
            }
            .qCanvasBackground()
            .navigationTitle("New transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { dismiss() }
                        .fontWeight(.semibold)
                        .disabled(merchant.isEmpty || amount.isEmpty)
                }
            }
        }
        .tint(QPalette.ink)
    }
}

// MARK: - Other tabs (out of scope for this screen)

fileprivate struct TabPlaceholder: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        NavigationStack {
            QEmptyState(title: title, message: message, systemImage: systemImage) { EmptyView() }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .qCanvasBackground()
                .navigationTitle(title)
        }
    }
}

// MARK: - Previews

#Preview("Light") { S_home() }
#Preview("Dark") { S_home().preferredColorScheme(.dark) }
#Preview("Large text") { S_home().dynamicTypeSize(.accessibility2) }
#Preview("Loading") { BudgetHomeView(phase: .loading) }
#Preview("Refresh failed") { BudgetHomeView(phase: .refreshFailed) }
#Preview("First run") { BudgetHomeView(phase: .empty) }
