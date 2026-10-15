// Screen.swift — Transactions (Feed / list archetype)
// Job: scan and find a transaction. Focal: the rows themselves, newest first.
// Primary action: none in content (export lives in the nav bar). Cut: per-row cards,
// colored category circles, red on every debit, a 2x2 stat grid.

import SwiftUI

// MARK: - Model

fileprivate enum TxCategory: String, CaseIterable {
    case groceries = "Groceries"
    case dining = "Food & drink"
    case transport = "Transport"
    case shopping = "Shopping"
    case bills = "Bills"
    case income = "Income"
    case transfer = "Transfer"
    case entertainment = "Entertainment"
    case health = "Health"

    var symbol: String {
        switch self {
        case .groceries: "cart"
        case .dining: "cup.and.saucer"
        case .transport: "tram"
        case .shopping: "bag"
        case .bills: "doc.text"
        case .income: "arrow.down.left"
        case .transfer: "arrow.left.arrow.right"
        case .entertainment: "film"
        case .health: "cross.case"
        }
    }
}

fileprivate struct Transaction: Identifiable, Hashable {
    let id = UUID()
    let merchant: String
    let category: TxCategory
    /// Positive = money in, negative = money out.
    let amount: Decimal
    let date: Date
    var isPending = false
    var note: String? = nil

    var isIncoming: Bool { amount > 0 }
}

fileprivate enum TxFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case moneyOut = "Money out"
    case moneyIn = "Money in"
    case pending = "Pending"
    var id: String { rawValue }

    func matches(_ tx: Transaction) -> Bool {
        switch self {
        case .all: true
        case .moneyOut: !tx.isIncoming
        case .moneyIn: tx.isIncoming
        case .pending: tx.isPending
        }
    }
}

fileprivate enum LoadPhase { case loaded, loading, failed }

// MARK: - Formatting

fileprivate enum Money {
    static let minus = "\u{2212}"

    static func plain(_ value: Decimal) -> String {
        value.formatted(.currency(code: "USD").sign(strategy: .never))
    }

    /// "−$38.99" for debits, "+$4,250.00" for credits.
    static func signed(_ value: Decimal) -> String {
        (value < 0 ? minus : "+") + plain(value)
    }

    static func spoken(_ value: Decimal) -> String {
        (value < 0 ? "Spent " : "Received ") + plain(value)
    }
}

fileprivate enum DayLabel {
    static func title(for day: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(day) { return "Today" }
        if cal.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}

// MARK: - Sample data (relative to today)

fileprivate enum SampleData {
    static func at(daysAgo: Int, _ hour: Int, _ minute: Int) -> Date {
        let cal = Calendar.current
        let day = cal.date(byAdding: .day, value: -daysAgo, to: cal.startOfDay(for: .now)) ?? .now
        return cal.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    static let transactions: [Transaction] = [
        Transaction(merchant: "Blue Bottle Coffee", category: .dining, amount: -6.75, date: at(daysAgo: 0, 8, 12), isPending: true),
        Transaction(merchant: "Whole Foods Market", category: .groceries, amount: -84.12, date: at(daysAgo: 0, 7, 48), isPending: true),
        Transaction(merchant: "Lyft", category: .transport, amount: -17.40, date: at(daysAgo: 1, 22, 31)),
        Transaction(merchant: "Amara Okafor", category: .transfer, amount: 42.50, date: at(daysAgo: 1, 19, 4), note: "Dinner at Lalibela"),
        Transaction(merchant: "Nopalito", category: .dining, amount: -63.28, date: at(daysAgo: 1, 18, 55)),
        Transaction(merchant: "Northwind Labs payroll", category: .income, amount: 4250.00, date: at(daysAgo: 2, 6, 0), note: "Salary, Oct 1–15"),
        Transaction(merchant: "PG&E", category: .bills, amount: -112.06, date: at(daysAgo: 2, 9, 30)),
        Transaction(merchant: "Spotify", category: .entertainment, amount: -11.99, date: at(daysAgo: 2, 3, 15)),
        Transaction(merchant: "Clipper Card reload", category: .transport, amount: -40.00, date: at(daysAgo: 3, 8, 2)),
        Transaction(merchant: "Rainbow Grocery Cooperative", category: .groceries, amount: -57.91, date: at(daysAgo: 3, 17, 40)),
        Transaction(merchant: "Walgreens", category: .health, amount: -0.89, date: at(daysAgo: 4, 12, 18)),
        Transaction(merchant: "REI Co-op", category: .shopping, amount: -189.95, date: at(daysAgo: 4, 14, 7)),
        Transaction(merchant: "Lucas Wei", category: .transfer, amount: -1284.06, date: at(daysAgo: 5, 10, 0), note: "October rent, your share"),
        Transaction(merchant: "Alamo Drafthouse", category: .entertainment, amount: -32.00, date: at(daysAgo: 6, 19, 45)),
        Transaction(merchant: "Tartine Bakery", category: .dining, amount: -14.25, date: at(daysAgo: 6, 9, 20)),
        Transaction(merchant: "Interest earned", category: .income, amount: 3.17, date: at(daysAgo: 7, 0, 5)),
    ]

    /// Skeleton stand-ins rendered with `.redacted(reason: .placeholder)`.
    static let placeholders: [Transaction] = (0..<7).map { i in
        Transaction(merchant: i.isMultiple(of: 2) ? "Merchant name here" : "Merchant name",
                    category: .shopping, amount: -24.99, date: at(daysAgo: 0, 9, 0))
    }
}

// MARK: - Screen

struct S_list: View {
    init() {}

    var body: some View {
        TransactionsScreen(phase: .loaded, transactions: SampleData.transactions)
    }
}

fileprivate struct TransactionsScreen: View {
    @State var phase: LoadPhase
    let transactions: [Transaction]

    @State private var filter: TxFilter = .all
    @State private var query = ""
    @State private var toast: String?

    private var visible: [Transaction] {
        transactions
            .filter { filter.matches($0) }
            .filter { query.isEmpty || $0.merchant.localizedCaseInsensitiveContains(query) || $0.category.rawValue.localizedCaseInsensitiveContains(query) }
            .sorted { $0.date > $1.date }
    }

    private var days: [(day: Date, items: [Transaction])] {
        let groups = Dictionary(grouping: visible) { Calendar.current.startOfDay(for: $0.date) }
        return groups.keys.sorted(by: >).map { ($0, groups[$0] ?? []) }
    }

    private var spentThisWeek: Decimal {
        transactions.filter { !$0.isIncoming }.reduce(0) { $0 - $1.amount }
    }

    var body: some View {
        NavigationStack {
            List {
                summaryAndFilters

                switch phase {
                case .loading:
                    skeletonSection
                case .failed:
                    errorRow
                case .loaded:
                    if visible.isEmpty {
                        noResultsRow
                    } else {
                        ForEach(days, id: \.day) { group in
                            Section {
                                ForEach(group.items) { tx in
                                    NavigationLink(value: tx) { TransactionRow(tx: tx) }
                                        .txRowStyle()
                                        .swipeActions(edge: .trailing) {
                                            Button { toast = "Marked \(tx.merchant) for review" } label: {
                                                Label("Flag", systemImage: "flag")
                                            }
                                            .tint(Palette.warning)
                                        }
                                        .contextMenu {
                                            Button { toast = "Receipt request sent" } label: { Label("Request receipt", systemImage: "doc.text.magnifyingglass") }
                                            Button { toast = "Marked \(tx.merchant) for review" } label: { Label("Report a problem", systemImage: "exclamationmark.bubble") }
                                        }
                                }
                            } header: {
                                DayHeader(day: group.day, items: group.items)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .canvasBackground()
            .navigationTitle("Transactions")
            .navigationDestination(for: Transaction.self) { TransactionDetail(tx: $0) }
            .searchable(text: $query, prompt: "Merchant or category")
            .refreshable {
                try? await Task.sleep(for: .milliseconds(700))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { toast = "October statement exported" } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Export statement")
                }
            }
            .toast(toast)
            .task(id: toast) {
                guard toast != nil else { return }
                try? await Task.sleep(for: .seconds(2.5))
                toast = nil
            }
        }
        .tint(Palette.ink)
        .sensoryFeedback(.selection, trigger: filter)
    }

    // Quiet summary line + filters. Not a hero: the rows are the focal content.
    private var summaryAndFilters: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            HStack(alignment: .firstTextBaseline, spacing: Space.xs) {
                Text("Spent in the last 7 days")
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
                Spacer(minLength: Space.xs)
                Text(Money.plain(spentThisWeek))
                    .font(.dsHeadline)
                    .monospacedDigit()
                    .foregroundStyle(Palette.ink)
                    .redacted(reason: phase == .loading ? .placeholder : [])
            }
            .padding(.horizontal, Space.margin)
            .accessibilityElement(children: .combine)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Space.xs) {
                    ForEach(TxFilter.allCases) { f in
                        Chip(title: f.rawValue, isSelected: f == filter) {
                            withAnimation(Motion.snappy) { filter = f }
                        }
                    }
                }
                .padding(.horizontal, Space.margin)
            }
            .scrollClipDisabled()
        }
        .padding(.top, Space.xxs)
        .padding(.bottom, Space.xs)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Palette.canvas)
        .listRowSeparator(.hidden)
    }

    private var skeletonSection: some View {
        Section {
            ForEach(SampleData.placeholders) { tx in
                TransactionRow(tx: tx)
                    .redacted(reason: .placeholder)
                    .shimmering(isActive: true)
                    .txRowStyle()
            }
        } header: {
            Text("Today").overlineStyle()
                .redacted(reason: .placeholder)
        }
        .accessibilityLabel("Loading transactions")
    }

    private var errorRow: some View {
        EmptyState(
            title: "Couldn't load transactions",
            message: "Check your connection and try again.",
            systemImage: "wifi.exclamationmark"
        ) {
            Button("Try again") { withAnimation(Motion.smooth) { phase = .loaded } }
                .buttonStyle(.tertiary)
        }
        .padding(.top, Space.xxl)
        .listRowBackground(Palette.canvas)
        .listRowSeparator(.hidden)
    }

    private var noResultsRow: some View {
        EmptyState(
            title: query.isEmpty ? "Nothing here yet" : "No results for \u{201C}\(query)\u{201D}",
            message: query.isEmpty
                ? "No \(filter.rawValue.lowercased()) transactions in the last 30 days."
                : "Try a merchant name like \u{201C}Lyft\u{201D} or a category like \u{201C}Groceries\u{201D}.",
            systemImage: "magnifyingglass"
        ) {
            Button("Clear filters") {
                withAnimation(Motion.snappy) { query = ""; filter = .all }
            }
            .buttonStyle(.tertiary)
        }
        .padding(.top, Space.xxl)
        .listRowBackground(Palette.canvas)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Row

fileprivate struct TransactionRow: View {
    let tx: Transaction

    var body: some View {
        HStack(spacing: Space.sm) {
            Image(systemName: tx.category.symbol)
                .font(.body)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Palette.ink2)
                .frame(width: Metrics.minTap - Space.xxs, height: Metrics.minTap - Space.xxs)
                .background(Palette.surface2, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(tx.merchant)
                    .font(.dsBody)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                Text(meta)
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
                    .lineLimit(1)
            }
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

            Spacer(minLength: Space.xs)

            Text(Money.signed(tx.amount))
                .font(.dsBody)
                .monospacedDigit()
                .foregroundStyle(tx.isIncoming ? Palette.positive : Palette.ink)
                .multilineTextAlignment(.trailing)
                .fixedSize()
        }
        .padding(.vertical, Space.xxs)
        .frame(minHeight: Metrics.rowMinHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(tx.merchant), \(Money.spoken(tx.amount)), \(tx.category.rawValue), \(tx.date.formatted(date: .omitted, time: .shortened))\(tx.isPending ? ", pending" : "")")
    }

    private var meta: String {
        let time = tx.date.formatted(date: .omitted, time: .shortened)
        return tx.isPending
            ? "Pending · \(tx.category.rawValue)"
            : "\(tx.category.rawValue) · \(time)"
    }
}

fileprivate struct DayHeader: View {
    let day: Date
    let items: [Transaction]

    private var net: Decimal { items.reduce(0) { $0 + $1.amount } }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(DayLabel.title(for: day)).overlineStyle()
            Spacer()
            Text(Money.signed(net))
                .font(.dsFootnote)
                .monospacedDigit()
                .foregroundStyle(Palette.ink2)
        }
        .padding(.top, Space.xs)
        .padding(.bottom, Space.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

fileprivate extension View {
    func txRowStyle() -> some View {
        self.listRowBackground(Palette.canvas)
            .listRowSeparatorTint(Palette.hairline)
            .listRowInsets(EdgeInsets(top: 0, leading: Space.margin, bottom: 0, trailing: Space.margin))
    }
}

// MARK: - Detail (pushed)

fileprivate struct TransactionDetail: View {
    let tx: Transaction

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text(tx.merchant)
                        .font(.dsHeadline)
                        .foregroundStyle(Palette.ink2)
                    HeroText(text: Money.signed(tx.amount), size: 48)
                    Text(tx.date.formatted(date: .complete, time: .shortened))
                        .font(.dsSubhead)
                        .foregroundStyle(Palette.ink2)
                }
                .padding(.vertical, Space.xs)
                .listRowBackground(Palette.canvas)
                .listRowInsets(EdgeInsets(top: 0, leading: Space.xxs, bottom: 0, trailing: Space.xxs))
            }

            Section {
                LabeledContent("Status", value: tx.isPending ? "Pending" : "Completed")
                LabeledContent("Category", value: tx.category.rawValue)
                LabeledContent("Account", value: "Everyday checking ··4821")
                if let note = tx.note { LabeledContent("Note", value: note) }
            }
            .surfaceRow()

            Section {
                Button { } label: { Label("Request receipt", systemImage: "doc.text.magnifyingglass") }
                Button { } label: { Label("Report a problem", systemImage: "exclamationmark.bubble") }
            }
            .surfaceRow()
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle(tx.category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Light") { S_list() }
#Preview("Dark") { S_list().preferredColorScheme(.dark) }
#Preview("Large text") { S_list().dynamicTypeSize(.accessibility2) }
#Preview("Loading") { TransactionsScreen(phase: .loading, transactions: SampleData.transactions) }
#Preview("Error") { TransactionsScreen(phase: .failed, transactions: []) }
