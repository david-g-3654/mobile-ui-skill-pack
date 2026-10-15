// Screen.swift — Personal budgeting app, home tab.
// Archetype: Home / dashboard (mobile-ui/references/screen-home.md), default "Quiet" skin.
// Job: "see what's left to spend this month". Focal: the left-to-spend hero.
// Primary action: none on screen — "Add expense" lives in the nav bar (+).
// Cut: charts (belong on a Stats screen), account balances grid, promo card.

import SwiftUI

// MARK: - Model

fileprivate enum HomePhase {
    case loaded, loading, empty, refreshFailed
}

fileprivate struct BudgetCategory: Identifiable {
    let id = UUID()
    let name: String
    let systemImage: String
    let spent: Double
    let limit: Double

    var progress: Double { spent / limit }
    var remaining: Double { limit - spent }
    var isOver: Bool { spent > limit }
    var isClose: Bool { !isOver && progress >= 0.85 }
}

fileprivate struct UpcomingBill: Identifiable {
    let id = UUID()
    let name: String
    let due: String
    let amount: Double
    let systemImage: String
}

fileprivate struct Transaction: Identifiable {
    let id = UUID()
    let merchant: String
    let detail: String
    let amount: Double          // negative = money out
    let systemImage: String
}

fileprivate enum Money {
    static func string(_ value: Double, signed: Bool = false) -> String {
        let formatted = abs(value).formatted(.currency(code: "USD"))
        guard signed else { return formatted }
        return value < 0 ? "−\(formatted)" : "+\(formatted)"
    }
}

fileprivate enum Sample {
    static let monthBudget: Double = 4_200.00
    static let spent: Double = 2_337.60
    static let saved: Double = 640.00
    static let daysLeft = 17

    static let categories: [BudgetCategory] = [
        .init(name: "Dining out", systemImage: "fork.knife", spent: 412.85, limit: 400),
        .init(name: "Groceries", systemImage: "cart", spent: 486.12, limit: 560),
        .init(name: "Transport & rideshare", systemImage: "car", spent: 118.40, limit: 220),
    ]

    static let bills: [UpcomingBill] = [
        .init(name: "Geico car insurance", due: "Due Saturday", amount: -142.37, systemImage: "car.side"),
        .init(name: "Spotify Family", due: "Oct 21", amount: -16.99, systemImage: "music.note"),
        .init(name: "Rent", due: "Nov 1", amount: -1_450.00, systemImage: "house"),
    ]

    static let transactions: [Transaction] = [
        .init(merchant: "Trader Joe's", detail: "Today, 9:41 AM · Groceries", amount: -64.18, systemImage: "cart"),
        .init(merchant: "Blue Bottle Coffee", detail: "Today, 8:12 AM · Dining out", amount: -6.75, systemImage: "cup.and.saucer"),
        .init(merchant: "Lyft", detail: "Yesterday · Transport", amount: -14.32, systemImage: "car"),
        .init(merchant: "Northwind Labs payroll", detail: "Fri, Oct 10 · Income", amount: 2_840.00, systemImage: "arrow.down.left"),
    ]
}

// MARK: - Root (tab bar)

struct S_home: View {
    @State private var phase: HomePhase
    @State private var selectedTab = 0

    init() {
        _phase = State(initialValue: .loaded)
    }

    fileprivate init(phase: HomePhase) {
        _phase = State(initialValue: phase)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab(phase: $phase)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
            ActivityTab()
                .tabItem { Label("Activity", systemImage: "list.bullet.rectangle") }
                .tag(1)
            BudgetsTab()
                .tabItem { Label("Budgets", systemImage: "chart.pie") }
                .tag(2)
        }
        .tint(Palette.ink)
    }
}

// MARK: - Home tab

fileprivate struct HomeTab: View {
    @Binding var phase: HomePhase
    @State private var showingAddExpense = false

    private var isLoading: Bool { phase == .loading }
    private var isEmpty: Bool { phase == .empty }

    private var leftToSpend: Double { Sample.monthBudget - Sample.spent }
    private var perDay: Double { leftToSpend / Double(Sample.daysLeft) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xxl) {
                    if phase == .refreshFailed { refreshBanner }
                    status
                    if isEmpty {
                        firstUseState
                    } else {
                        categoriesSection
                        billsSection
                        recentSection
                    }
                }
                .padding(.horizontal, Space.margin)
                .padding(.top, Space.xs)
                .padding(.bottom, Space.xxl)
                .redacted(reason: isLoading ? .placeholder : [])
                .shimmering(isActive: isLoading)
            }
            .canvasBackground()
            .refreshable { }
            .navigationTitle("October")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add expense")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseSheet()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(Radius.xl)
            }
        }
    }

    // Hero + pace bar + metric row
    private var status: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.sm) {
                HeroMetric(
                    label: "Left to spend",
                    value: isEmpty ? "4,200" : "1,862",
                    prefix: "$",
                    suffix: isEmpty ? ".00" : ".40",
                    context: isEmpty
                        ? "\(Sample.daysLeft) days to go"
                        : "\(Sample.daysLeft) days to go · \(Money.string(perDay)) a day",
                    delta: isEmpty ? nil : .init(text: "$64 under pace", isUp: false, upIsGood: false)
                )
                PaceBar(spentFraction: isEmpty ? 0 : Sample.spent / Sample.monthBudget,
                        monthFraction: 14.0 / 31.0)
            }
            MetricRow(items: [
                (isEmpty ? "$0" : "$2,337.60", "spent"),
                ("$4,200", "budget"),
                (isEmpty ? "$0" : Money.string(Sample.saved), "saved"),
            ])
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHeader(title: "Watch closely", actionTitle: "All budgets") {}
            GroupedRows(items: Sample.categories) { category in
                CategoryRow(category: category)
            }
        }
    }

    private var billsSection: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHeader(title: "Coming up")
            GroupedRows(items: Sample.bills) { bill in
                ListRow(title: bill.name, subtitle: bill.due, systemImage: bill.systemImage) {
                    Text(Money.string(bill.amount, signed: true))
                        .font(.dsBody)
                        .monospacedDigit()
                        .foregroundStyle(Palette.ink)
                }
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHeader(title: "Recent", actionTitle: "See all") {}
            GroupedRows(items: Sample.transactions) { tx in
                ListRow(title: tx.merchant, subtitle: tx.detail, systemImage: tx.systemImage) {
                    Text(Money.string(tx.amount, signed: true))
                        .font(.dsBody)
                        .monospacedDigit()
                        .foregroundStyle(tx.amount > 0 ? Palette.positive : Palette.ink)
                }
            }
        }
    }

    private var firstUseState: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text("No spending yet")
                .font(.dsTitle)
                .foregroundStyle(Palette.ink)
            Text("Add your first expense or connect a bank account, and you'll see where your money goes here.")
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink2)
            Button("Add an expense") { showingAddExpense = true }
                .buttonStyle(.secondary)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.top, Space.xs)
        }
        .padding(.top, Space.xl)
    }

    private var refreshBanner: some View {
        HStack(spacing: Space.sm) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(Palette.warning)
                .accessibilityHidden(true)
            Text("Couldn't refresh · Showing data from 9:41 AM")
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink)
            Spacer(minLength: Space.xs)
            Button("Retry") { phase = .loaded }
                .buttonStyle(.tertiary)
        }
        .padding(.horizontal, Space.md)
        .padding(.vertical, Space.xxs)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.m, style: .continuous))
    }
}

// MARK: - Pieces

/// Thin month-to-date bar: fill = share of budget spent, tick = share of the month elapsed.
fileprivate struct PaceBar: View {
    let spentFraction: Double
    let monthFraction: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.surface2)
                Capsule()
                    .fill(Palette.accent)
                    .frame(width: geo.size.width * min(max(spentFraction, 0), 1))
                Rectangle()
                    .fill(Palette.ink)
                    .frame(width: 2, height: 16)
                    .offset(x: geo.size.width * monthFraction - 1)
            }
        }
        .frame(height: 8)
        .padding(.vertical, Space.xxs)
        .accessibilityElement()
        .accessibilityLabel("Budget used")
        .accessibilityValue("\(Int(spentFraction * 100)) percent spent, \(Int(monthFraction * 100)) percent of the month gone")
    }
}

/// Rows on one surface group, separated by inset hairlines (home uses a scroll view, not List).
fileprivate struct GroupedRows<Item: Identifiable, Row: View>: View {
    let items: [Item]
    @ViewBuilder let row: (Item) -> Row

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                row(item).padding(.horizontal, Space.md)
                if item.id != items.last?.id {
                    Divider().overlay(Palette.hairline).padding(.leading, 56)
                }
            }
        }
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
    }
}

fileprivate struct CategoryRow: View {
    let category: BudgetCategory

    private var statusText: String {
        if category.isOver { return "\(Money.string(-category.remaining)) over" }
        return "\(Money.string(category.remaining)) left"
    }

    private var statusColor: Color {
        if category.isOver { return Palette.negative }
        if category.isClose { return Palette.warning }
        return Palette.ink2
    }

    var body: some View {
        HStack(spacing: Space.sm) {
            Image(systemName: category.systemImage)
                .font(.body)
                .foregroundStyle(Palette.ink2)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Space.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(category.name)
                        .font(.dsBody)
                        .foregroundStyle(Palette.ink)
                    Spacer(minLength: Space.xs)
                    Text(statusText)
                        .font(.dsSubhead)
                        .monospacedDigit()
                        .foregroundStyle(statusColor)
                }
                ProgressView(value: min(category.progress, 1))
                    .tint(category.isOver ? Palette.negative : Palette.ink)
                Text("\(Money.string(category.spent)) of \(Money.string(category.limit))")
                    .font(.dsSubhead)
                    .monospacedDigit()
                    .foregroundStyle(Palette.ink2)
            }
        }
        .padding(.vertical, Space.sm)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var merchant = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Where", text: $merchant)
                        .textContentType(.organizationName)
                }
                .surfaceRow()
            }
            .canvasBackground()
            .navigationTitle("Add expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                        .fontWeight(.semibold)
                        .disabled(amount.isEmpty)
                }
            }
        }
    }
}

// MARK: - Other tabs (kept minimal; their own archetypes live elsewhere)

fileprivate struct ActivityTab: View {
    var body: some View {
        NavigationStack {
            List {
                Section("This week") {
                    ForEach(Sample.transactions) { tx in
                        LabeledContent {
                            Text(Money.string(tx.amount, signed: true))
                                .monospacedDigit()
                                .foregroundStyle(tx.amount > 0 ? Palette.positive : Palette.ink)
                        } label: {
                            Text(tx.merchant).foregroundStyle(Palette.ink)
                            Text(tx.detail).foregroundStyle(Palette.ink2)
                        }
                        .surfaceRow()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .canvasBackground()
            .navigationTitle("Activity")
        }
    }
}

fileprivate struct BudgetsTab: View {
    var body: some View {
        NavigationStack {
            List {
                Section("October") {
                    ForEach(Sample.categories) { category in
                        LabeledContent(category.name) {
                            Text("\(Money.string(category.spent)) of \(Money.string(category.limit))")
                                .monospacedDigit()
                        }
                        .surfaceRow()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .canvasBackground()
            .navigationTitle("Budgets")
        }
    }
}

// MARK: - Previews

#Preview("Light") { S_home() }
#Preview("Dark") { S_home().preferredColorScheme(.dark) }
#Preview("Large text") { S_home().dynamicTypeSize(.accessibility2) }
#Preview("Loading") { S_home(phase: .loading) }
#Preview("First use") { S_home(phase: .empty) }
#Preview("Refresh failed") { S_home(phase: .refreshFailed) }
