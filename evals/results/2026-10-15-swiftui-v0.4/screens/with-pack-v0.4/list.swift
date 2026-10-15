// Transactions — Feed / list archetype.
// Job: review recent account activity. Focal: 30-day spend summary. Primary action: none in content
// (rows open detail). Cutting: per-row category bubbles, red on every debit, a separate balance card.

import SwiftUI

// MARK: - Root

struct S_list: View {
    init() {}

    var body: some View {
        NavigationStack {
            TransactionsScreen(initialPhase: .loading)
        }
        .tint(QPalette.ink)
    }
}

// MARK: - Model

fileprivate enum TxCategory: String {
    case groceries, dining, transport, shopping, bills, income, transfer, subscriptions, travel

    var symbol: String {
        switch self {
        case .groceries: "cart"
        case .dining: "fork.knife"
        case .transport: "car"
        case .shopping: "bag"
        case .bills: "bolt"
        case .income: "arrow.down.left"
        case .transfer: "arrow.left.arrow.right"
        case .subscriptions: "repeat"
        case .travel: "airplane"
        }
    }

    var label: String {
        switch self {
        case .groceries: "Groceries"
        case .dining: "Dining"
        case .transport: "Transport"
        case .shopping: "Shopping"
        case .bills: "Bills & utilities"
        case .income: "Income"
        case .transfer: "Transfer"
        case .subscriptions: "Subscriptions"
        case .travel: "Travel"
        }
    }
}

fileprivate struct Transaction: Identifiable, Hashable {
    let id = UUID()
    let merchant: String
    let category: TxCategory
    /// Negative = money out.
    let amount: Decimal
    let date: Date
    var isPending = false
    var note: String? = nil

    var isIncoming: Bool { amount > 0 }
}

fileprivate enum TxFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case moneyIn = "Money in"
    case moneyOut = "Money out"
    case pending = "Pending"
    var id: String { rawValue }

    func matches(_ tx: Transaction) -> Bool {
        switch self {
        case .all: true
        case .moneyIn: tx.isIncoming
        case .moneyOut: !tx.isIncoming
        case .pending: tx.isPending
        }
    }
}

fileprivate enum LoadPhase { case loading, loaded, failed, empty }

// MARK: - Formatting (one formatter for every amount on the screen)

fileprivate enum Money {
    static let style = Decimal.FormatStyle.Currency(code: "USD")

    static func plain(_ value: Decimal) -> String {
        (value < 0 ? -value : value).formatted(style)
    }

    /// Signed with a true minus (−) for debits and + for credits.
    static func signed(_ value: Decimal) -> String {
        (value < 0 ? "\u{2212}" : "+") + plain(value)
    }
}

// MARK: - Sample data (relative to today)

fileprivate enum SampleData {
    static func make(now: Date = .now) -> [Transaction] {
        let cal = Calendar.current
        func at(_ daysAgo: Int, _ hour: Int, _ minute: Int) -> Date {
            let day = cal.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }
        return [
            Transaction(merchant: "Blue Bottle Coffee", category: .dining, amount: -6.75, date: at(0, 8, 12), isPending: true),
            Transaction(merchant: "Lyft", category: .transport, amount: -18.42, date: at(0, 7, 48), isPending: true),
            Transaction(merchant: "Trader Joe's", category: .groceries, amount: -64.18, date: at(1, 18, 30)),
            Transaction(merchant: "Spotify", category: .subscriptions, amount: -11.99, date: at(1, 4, 2)),
            Transaction(merchant: "Payroll · Northwind Analytics", category: .income, amount: 3_240.00, date: at(1, 2, 0), note: "Direct deposit"),
            Transaction(merchant: "Sofía Ramírez-Castillo", category: .transfer, amount: 42.50, date: at(2, 21, 15), note: "Dinner at Nopalito"),
            Transaction(merchant: "Nopalito", category: .dining, amount: -96.30, date: at(2, 20, 40)),
            Transaction(merchant: "Pacific Gas & Electric", category: .bills, amount: -128.64, date: at(3, 9, 5)),
            Transaction(merchant: "Uniqlo", category: .shopping, amount: -79.90, date: at(3, 13, 22)),
            Transaction(merchant: "BART Clipper reload", category: .transport, amount: -40.00, date: at(4, 8, 1)),
            Transaction(merchant: "Rainbow Grocery Cooperative", category: .groceries, amount: -38.99, date: at(5, 17, 44)),
            Transaction(merchant: "Alaska Airlines", category: .travel, amount: -412.20, date: at(6, 11, 10), note: "SFO → SEA, Nov 21"),
            Transaction(merchant: "Interest earned", category: .income, amount: 0.83, date: at(6, 0, 1)),
            Transaction(merchant: "Rent · Mission Dolores Apts", category: .bills, amount: -2_150.00, date: at(9, 9, 0)),
            Transaction(merchant: "Apple iCloud+", category: .subscriptions, amount: -2.99, date: at(11, 3, 30)),
        ]
    }
}

// MARK: - Screen

fileprivate struct TransactionsScreen: View {
    @State private var phase: LoadPhase
    @State private var transactions: [Transaction] = []
    @State private var filter: TxFilter = .all
    @State private var query = ""
    @State private var toast: String?

    init(initialPhase: LoadPhase) {
        _phase = State(initialValue: initialPhase)
    }

    private var visible: [Transaction] {
        transactions.filter { tx in
            filter.matches(tx) &&
            (query.isEmpty || tx.merchant.localizedCaseInsensitiveContains(query)
                || tx.category.label.localizedCaseInsensitiveContains(query))
        }
    }

    private var daySections: [(day: Date, items: [Transaction])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: visible) { cal.startOfDay(for: $0.date) }
        return grouped.keys.sorted(by: >).map { day in
            (day, grouped[day, default: []].sorted { $0.date > $1.date })
        }
    }

    private var spentLast30: Decimal {
        transactions.filter { !$0.isIncoming }.reduce(Decimal(0)) { $0 + $1.amount }
    }

    var body: some View {
        List {
            summarySection
            filterSection
            content
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(QSpace.md)
        .qCanvasBackground()
        .navigationTitle("Transactions")
        .searchable(text: $query, prompt: "Merchant or category")
        .refreshable { await load() }
        .task { if phase == .loading { await load() } }
        .navigationDestination(for: Transaction.self) { TransactionDetail(tx: $0) }
        .qToast(toast)
    }

    // MARK: Sections

    @ViewBuilder private var summarySection: some View {
        Section {
            QHeroMetric(
                label: "Spent · last 30 days",
                value: Money.plain(spentLast30),
                context: "Everyday Checking ··4821"
            )
            .redacted(reason: phase == .loading ? .placeholder : [])
            .qShimmering(isActive: phase == .loading)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: QSpace.xs, leading: QSpace.xxs, bottom: QSpace.xs, trailing: QSpace.xxs))
        }
    }

    @ViewBuilder private var filterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: QSpace.xs) {
                    ForEach(TxFilter.allCases) { f in
                        QChip(title: f.rawValue, isSelected: filter == f) {
                            withAnimation(QMotion.snappy) { filter = f }
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: QSpace.xxs, bottom: 0, trailing: QSpace.xxs))
        }
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            Section {
                ForEach(0..<6, id: \.self) { i in
                    TransactionRow(tx: SampleData.make()[i])
                        .redacted(reason: .placeholder)
                        .qShimmering(isActive: true)
                        .qSurfaceRow()
                }
            } header: {
                Text("Today").qOverlineStyle().redacted(reason: .placeholder)
            }
            .accessibilityLabel("Loading transactions")

        case .failed:
            Section {
                QEmptyState(
                    title: "Couldn't load activity",
                    message: "Check your connection and try again.",
                    systemImage: "wifi.exclamationmark"
                ) {
                    Button("Try again") { Task { await load() } }
                        .buttonStyle(.qSecondary)
                }
                .listRowBackground(Color.clear)
            }

        case .empty:
            Section {
                QEmptyState(
                    title: "No activity yet",
                    message: "Card payments, deposits and transfers on this account will show up here.",
                    systemImage: "list.bullet.rectangle"
                ) { EmptyView() }
                .listRowBackground(Color.clear)
            }

        case .loaded:
            if visible.isEmpty {
                Section {
                    QEmptyState(
                        title: query.isEmpty ? "Nothing in \(filter.rawValue.lowercased())" : "No matches for \u{201C}\(query)\u{201D}",
                        message: "Try a different merchant name or show all transactions.",
                        systemImage: "magnifyingglass"
                    ) {
                        Button("Clear filters") {
                            withAnimation(QMotion.snappy) { query = ""; filter = .all }
                        }
                        .buttonStyle(.qTertiary)
                    }
                    .listRowBackground(Color.clear)
                }
            } else {
                ForEach(daySections, id: \.day) { section in
                    Section {
                        ForEach(section.items) { tx in
                            NavigationLink(value: tx) {
                                TransactionRow(tx: tx)
                            }
                            .qSurfaceRow()
                            .swipeActions(edge: .trailing) {
                                Button {
                                    flash("Receipt request sent to \(tx.merchant)")
                                } label: {
                                    Label("Request receipt", systemImage: "doc.text")
                                }
                                .tint(QPalette.ink2)
                            }
                            .contextMenu {
                                Button { flash("Copied amount") } label: {
                                    Label("Copy amount", systemImage: "doc.on.doc")
                                }
                                Button { flash("We'll look into \(tx.merchant)") } label: {
                                    Label("Report a problem", systemImage: "exclamationmark.bubble")
                                }
                            }
                        }
                    } header: {
                        DayHeader(day: section.day, items: section.items)
                    }
                }
            }
        }
    }

    // MARK: Actions

    private func load() async {
        try? await Task.sleep(for: .milliseconds(700))
        withAnimation(QMotion.smooth) {
            transactions = SampleData.make()
            phase = transactions.isEmpty ? .empty : .loaded
        }
    }

    private func flash(_ message: String) {
        toast = message
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            toast = nil
        }
    }
}

// MARK: - Day header

fileprivate struct DayHeader: View {
    let day: Date
    let items: [Transaction]

    private var title: String {
        let cal = Calendar.current
        if cal.isDateInToday(day) { return "Today" }
        if cal.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    private var outflow: Decimal {
        items.filter { !$0.isIncoming }.reduce(Decimal(0)) { $0 + $1.amount }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).qOverlineStyle()
            Spacer(minLength: QSpace.xs)
            if outflow != 0 {
                Text(Money.signed(outflow))
                    .font(.dsFootnote)
                    .monospacedDigit()
                    .foregroundStyle(QPalette.ink2)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Row

fileprivate struct TransactionRow: View {
    let tx: Transaction
    @Environment(\.dynamicTypeSize) private var typeSize

    private var subtitle: String {
        var parts = [tx.category.label]
        if tx.isPending {
            parts.append("Pending")
        } else {
            parts.append(tx.date.formatted(date: .omitted, time: .shortened))
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        let stacked = typeSize.isAccessibilitySize
        HStack(spacing: QSpace.sm) {
            if !stacked {
                Image(systemName: tx.category.symbol)
                    .font(.body)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(QPalette.ink2)
                    .frame(width: 28)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.merchant)
                    .font(.dsBody)
                    .foregroundStyle(QPalette.ink)
                    .lineLimit(stacked ? nil : 1)
                Text(subtitle)
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                if stacked { amount }
            }
            Spacer(minLength: QSpace.xs)
            if !stacked { amount }
        }
        .padding(.vertical, QSpace.xxs)
        .frame(minHeight: QMetrics.rowMinHeight)
        .accessibilityElement(children: .combine)
    }

    private var amount: some View {
        Text(Money.signed(tx.amount))
            .font(.dsBody)
            .monospacedDigit()
            // Debits stay ink; credits are the unusual event, so they get color *and* a sign.
            .foregroundStyle(tx.isIncoming ? QPalette.positive : QPalette.ink)
            .opacity(tx.isPending ? 0.75 : 1)
    }
}

// MARK: - Detail

fileprivate struct TransactionDetail: View {
    let tx: Transaction

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: QSpace.xs) {
                    Text(tx.merchant)
                        .font(.dsHeadline)
                        .foregroundStyle(QPalette.ink)
                    QHeroText(text: Money.signed(tx.amount), size: 44)
                    Text(tx.isPending ? "Pending · usually posts in 1–2 days" : "Posted")
                        .font(.dsSubhead)
                        .foregroundStyle(QPalette.ink2)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: QSpace.xs, leading: QSpace.xxs, bottom: QSpace.xs, trailing: QSpace.xxs))
            }
            Section {
                LabeledContent("Date", value: tx.date.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Category", value: tx.category.label)
                LabeledContent("Account", value: "Everyday Checking ··4821")
                if let note = tx.note {
                    LabeledContent("Note", value: note)
                }
            }
            .qSurfaceRow()
            Section {
                Button("Report a problem") {}
                    .foregroundStyle(QPalette.ink)
            }
            .qSurfaceRow()
        }
        .listStyle(.insetGrouped)
        .qCanvasBackground()
        .navigationTitle(tx.category.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Light") {
    S_list()
}

#Preview("Dark") {
    S_list().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_list().dynamicTypeSize(.accessibility2)
}

#Preview("Error") {
    NavigationStack { TransactionsScreen(initialPhase: .failed) }
        .tint(QPalette.ink)
}
