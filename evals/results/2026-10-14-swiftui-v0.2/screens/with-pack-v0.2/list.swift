// Transactions — Feed / list archetype.
// Job: browse and find account activity. Focal: the newest rows. Primary action: none in content
// (search + filters live in the bar). Cut: per-row cards, category color circles, red on every debit.

import SwiftUI

// MARK: - Model

fileprivate enum TxCategory: String, CaseIterable {
    case groceries = "Groceries"
    case dining = "Dining"
    case transport = "Transport"
    case shopping = "Shopping"
    case housing = "Housing"
    case utilities = "Utilities"
    case subscriptions = "Subscriptions"
    case health = "Health"
    case travel = "Travel"
    case income = "Income"
    case transfer = "Transfer"

    var symbol: String {
        switch self {
        case .groceries: "cart"
        case .dining: "fork.knife"
        case .transport: "tram"
        case .shopping: "bag"
        case .housing: "house"
        case .utilities: "bolt"
        case .subscriptions: "play.rectangle"
        case .health: "cross.case"
        case .travel: "airplane"
        case .income: "arrow.down.left"
        case .transfer: "arrow.left.arrow.right"
        }
    }
}

fileprivate enum TxStatus {
    case posted, pending, declined
}

fileprivate struct Transaction: Identifiable, Hashable {
    let id = UUID()
    let merchant: String
    let category: TxCategory
    /// Signed: negative = money out.
    let amount: Decimal
    let date: Date
    var status: TxStatus = .posted
    var method: String = "Debit card ·· 4821"
    var note: String? = nil

    var isIncoming: Bool { amount > 0 }
}

fileprivate enum TxFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case moneyIn = "Money in"
    case moneyOut = "Money out"
    case pending = "Pending"
    var id: String { rawValue }

    func matches(_ t: Transaction) -> Bool {
        switch self {
        case .all: true
        case .moneyIn: t.isIncoming
        case .moneyOut: !t.isIncoming
        case .pending: t.status == .pending
        }
    }
}

// MARK: - Formatting (one formatter for every amount on screen)

fileprivate enum Money {
    static let style = Decimal.FormatStyle.Currency(code: "USD")

    /// "−$12.40" / "+$2,450.00" — true minus sign, explicit plus for money in.
    static func signed(_ amount: Decimal) -> String {
        let magnitude = (amount < 0 ? -amount : amount).formatted(style)
        return amount < 0 ? "\u{2212}\(magnitude)" : "+\(magnitude)"
    }

    static func plain(_ amount: Decimal) -> String { amount.formatted(style) }
}

fileprivate enum DayLabel {
    static func text(for day: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        if let days = calendar.dateComponents([.day], from: day, to: calendar.startOfDay(for: .now)).day, days < 7 {
            return day.formatted(.dateTime.weekday(.wide))
        }
        return day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}

// MARK: - Sample data (relative to today)

fileprivate enum SampleData {
    static func at(_ daysAgo: Int, _ hour: Int, _ minute: Int) -> Date {
        let cal = Calendar.current
        let day = cal.date(byAdding: .day, value: -daysAgo, to: cal.startOfDay(for: .now)) ?? .now
        return cal.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    static let transactions: [Transaction] = [
        Transaction(merchant: "Trader Joe's", category: .groceries, amount: -64.18, date: at(0, 8, 52), status: .pending),
        Transaction(merchant: "Ritual Coffee Roasters", category: .dining, amount: -5.75, date: at(0, 7, 31), status: .pending, method: "Apple Pay ·· 4821"),
        Transaction(merchant: "Northwind Labs payroll", category: .income, amount: 2450.00, date: at(1, 6, 0), method: "Direct deposit", note: "Salary · Oct 1–15"),
        Transaction(merchant: "Lyft", category: .transport, amount: -18.42, date: at(1, 22, 14), method: "Apple Pay ·· 4821"),
        Transaction(merchant: "Nopalito", category: .dining, amount: -47.90, date: at(1, 20, 3)),
        Transaction(merchant: "Spotify", category: .subscriptions, amount: -11.99, date: at(2, 9, 0), method: "Credit card ·· 0937"),
        Transaction(merchant: "Clipper card reload", category: .transport, amount: -40.00, date: at(2, 8, 12)),
        Transaction(merchant: "Maya Castellanos", category: .transfer, amount: 36.50, date: at(3, 19, 45), method: "Zelle", note: "Dinner split at Nopalito"),
        Transaction(merchant: "Walgreens", category: .health, amount: -23.07, date: at(3, 17, 20)),
        Transaction(merchant: "Uniqlo Union Square", category: .shopping, amount: -129.80, date: at(4, 14, 36), status: .declined, method: "Credit card ·· 0937", note: "Declined: card temporarily locked"),
        Transaction(merchant: "PG&E", category: .utilities, amount: -86.31, date: at(5, 10, 0), method: "Autopay · Checking"),
        Transaction(merchant: "Rent — 1428 Valencia St, Apt 3", category: .housing, amount: -2185.00, date: at(6, 9, 0), method: "Transfer · Checking"),
        Transaction(merchant: "Alaska Airlines", category: .travel, amount: -312.46, date: at(8, 21, 11), method: "Credit card ·· 0937", note: "SFO → SEA · Nov 21"),
        Transaction(merchant: "Rainbow Grocery", category: .groceries, amount: -52.63, date: at(9, 18, 40)),
        Transaction(merchant: "Interest earned", category: .income, amount: 0.84, date: at(10, 0, 5), method: "Savings ·· 2210"),
        Transaction(merchant: "To savings", category: .transfer, amount: -500.00, date: at(10, 7, 30), method: "Transfer · Savings ·· 2210"),
    ]

    static let placeholders: [Transaction] = (0..<7).map { i in
        Transaction(merchant: "Merchant name here", category: .shopping, amount: -42.00, date: at(0, 9, i))
    }
}

// MARK: - Screen

struct S_list: View {
    @State private var transactions = SampleData.transactions
    @State private var filter: TxFilter = .all
    @State private var query = ""
    @State private var isLoading = true
    @State private var selected: Transaction?
    @State private var toastMessage: String?

    init() {}

    private var visible: [Transaction] {
        let q = query.trimmingCharacters(in: .whitespaces)
        return transactions
            .filter { filter.matches($0) }
            .filter { q.isEmpty || $0.merchant.localizedCaseInsensitiveContains(q) || $0.category.rawValue.localizedCaseInsensitiveContains(q) }
            .sorted { $0.date > $1.date }
    }

    private var sections: [(day: Date, items: [Transaction])] {
        let grouped = Dictionary(grouping: visible) { Calendar.current.startOfDay(for: $0.date) }
        return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
    }

    var body: some View {
        NavigationStack {
            List {
                filterRow
                if isLoading {
                    Section {
                        ForEach(SampleData.placeholders) { tx in
                            TransactionRow(transaction: tx)
                                .listRowBackground(Palette.canvas)
                        }
                    } header: {
                        Text("Today").overlineStyle()
                    }
                    .redacted(reason: .placeholder)
                    .shimmering(isActive: true)
                    .accessibilityLabel("Loading transactions")
                } else {
                    ForEach(sections, id: \.day) { section in
                        Section {
                            ForEach(section.items) { tx in
                                row(tx)
                            }
                        } header: {
                            DayHeader(day: section.day, items: section.items)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .canvasBackground()
            .overlay {
                if !isLoading && visible.isEmpty { emptyState }
            }
            .navigationTitle("Transactions")
            .searchable(text: $query, prompt: "Merchant or category")
            .refreshable { try? await Task.sleep(for: .milliseconds(900)) }
            .navigationDestination(item: $selected) { tx in
                TransactionDetail(transaction: tx)
            }
            .toast(toastMessage)
            .task {
                try? await Task.sleep(for: .milliseconds(700))
                withAnimation(Motion.smooth) { isLoading = false }
            }
        }
        .tint(Palette.ink)
    }

    // MARK: Pieces

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Space.xs) {
                ForEach(TxFilter.allCases) { f in
                    Chip(title: f.rawValue, isSelected: filter == f) {
                        withAnimation(Motion.snappy) { filter = f }
                    }
                }
            }
            .padding(.horizontal, Space.margin)
        }
        .listRowInsets(EdgeInsets(top: Space.xs, leading: 0, bottom: Space.xs, trailing: 0))
        .listRowBackground(Palette.canvas)
        .listRowSeparator(.hidden)
    }

    private func row(_ tx: Transaction) -> some View {
        Button { selected = tx } label: {
            TransactionRow(transaction: tx)
        }
        .buttonStyle(.plain)
        .listRowBackground(Palette.canvas)
        .listRowSeparatorTint(Palette.hairline)
        .alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] + 40 + Space.sm }
        .swipeActions(edge: .trailing) {
            Button { flash("Split request drafted") } label: {
                Label("Split", systemImage: "person.2")
            }
            .tint(Palette.ink2)
        }
        .contextMenu {
            Button { flash("Amount copied") } label: {
                Label("Copy amount", systemImage: "doc.on.doc")
            }
            Button { flash("Split request drafted") } label: {
                Label("Split with someone", systemImage: "person.2")
            }
            Button { flash("We'll look into it") } label: {
                Label("Report a problem", systemImage: "exclamationmark.bubble")
            }
        }
    }

    @ViewBuilder private var emptyState: some View {
        let q = query.trimmingCharacters(in: .whitespaces)
        EmptyState(
            title: q.isEmpty ? "Nothing \(filter.rawValue.lowercased())" : "No matches for \u{201C}\(q)\u{201D}",
            message: q.isEmpty
                ? "Transactions that fit this filter will show up here."
                : "Try a merchant name like \u{201C}Lyft\u{201D} or a category like \u{201C}Dining\u{201D}.",
            systemImage: "magnifyingglass"
        ) {
            Button("Clear filters") {
                withAnimation(Motion.snappy) {
                    filter = .all
                    query = ""
                }
            }
            .buttonStyle(.tertiary)
        }
    }

    private func flash(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            if toastMessage == message { toastMessage = nil }
        }
    }
}

// MARK: - Day header

fileprivate struct DayHeader: View {
    let day: Date
    let items: [Transaction]

    private var net: Decimal {
        items.filter { $0.status != .declined }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(DayLabel.text(for: day)).overlineStyle()
            Spacer(minLength: Space.xs)
            Text(Money.signed(net))
                .font(.dsFootnote)
                .monospacedDigit()
                .foregroundStyle(Palette.ink2)
                .accessibilityLabel("Net \(Money.signed(net))")
        }
        .padding(.vertical, Space.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Row

fileprivate struct TransactionRow: View {
    let transaction: Transaction
    @Environment(\.dynamicTypeSize) private var typeSize

    private var meta: String {
        let time = transaction.date.formatted(date: .omitted, time: .shortened)
        switch transaction.status {
        case .posted: return "\(transaction.category.rawValue) · \(time)"
        case .pending: return "Pending · \(time)"
        case .declined: return "Declined · \(time)"
        }
    }

    private var amountColor: Color {
        switch transaction.status {
        case .declined: Palette.ink3
        case .pending, .posted: transaction.isIncoming ? Palette.positive : Palette.ink
        }
    }

    var body: some View {
        let stacked = typeSize.isAccessibilitySize
        HStack(alignment: stacked ? .top : .center, spacing: Space.sm) {
            Image(systemName: transaction.category.symbol)
                .font(.body)
                .foregroundStyle(Palette.ink2)
                .frame(width: 40, height: 40)
                .background(Palette.surface2, in: Circle())
                .accessibilityHidden(true)

            let layout = stacked ? AnyLayout(VStackLayout(alignment: .leading, spacing: Space.xxs))
                                 : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: Space.xs))
            layout {
                VStack(alignment: .leading, spacing: 2) {
                    Text(transaction.merchant)
                        .font(.dsBody)
                        .foregroundStyle(Palette.ink)
                        .lineLimit(stacked ? nil : 1)
                    Text(meta)
                        .font(.dsSubhead)
                        .foregroundStyle(transaction.status == .declined ? Palette.negative : Palette.ink2)
                }
                if !stacked { Spacer(minLength: Space.xs) }
                Text(Money.signed(transaction.amount))
                    .font(.dsBody)
                    .monospacedDigit()
                    .foregroundStyle(amountColor)
                    .strikethrough(transaction.status == .declined, color: Palette.ink3)
                    .layoutPriority(1)
            }
        }
        .padding(.vertical, Space.xxs)
        .frame(minHeight: 64)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows transaction details")
    }
}

// MARK: - Detail (pushed)

fileprivate struct TransactionDetail: View {
    let transaction: Transaction
    @State private var showReport = false
    @State private var reported = false

    private var statusText: String {
        switch transaction.status {
        case .posted: "Posted"
        case .pending: "Pending — usually posts in 1–2 business days"
        case .declined: "Declined"
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text(transaction.merchant)
                        .font(.dsHeadline)
                        .foregroundStyle(Palette.ink2)
                    HeroText(text: Money.signed(transaction.amount))
                    Text(transaction.date.formatted(date: .complete, time: .shortened))
                        .font(.dsSubhead)
                        .foregroundStyle(Palette.ink2)
                }
                .padding(.vertical, Space.md)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .accessibilityElement(children: .combine)
            }

            Section {
                LabeledContent("Status", value: statusText)
                LabeledContent("Category", value: transaction.category.rawValue)
                LabeledContent("Paid with", value: transaction.method)
                if let note = transaction.note {
                    LabeledContent("Note", value: note)
                }
            }
            .surfaceRow()

            Section {
                Button(reported ? "Report sent" : "Report a problem") { showReport = true }
                    .disabled(reported)
                    .foregroundStyle(reported ? Palette.ink3 : Palette.negative)
            }
            .surfaceRow()
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle(transaction.category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Something wrong with this charge?", isPresented: $showReport, titleVisibility: .visible) {
            Button("I don't recognize it") { reported = true }
            Button("Wrong amount") { reported = true }
            Button("Dispute this charge", role: .destructive) { reported = true }
        }
        .sensoryFeedback(.success, trigger: reported)
    }
}

// MARK: - Previews

#Preview("Light") { S_list() }
#Preview("Dark") { S_list().preferredColorScheme(.dark) }
#Preview("Large text") { S_list().dynamicTypeSize(.accessibility2) }
