import SwiftUI

// MARK: - Model

fileprivate enum TxCategory: String, CaseIterable {
    case groceries = "Groceries"
    case dining = "Dining"
    case transport = "Transport"
    case shopping = "Shopping"
    case income = "Income"
    case transfer = "Transfer"
    case bills = "Bills & Utilities"
    case entertainment = "Entertainment"
    case health = "Health"
    case travel = "Travel"

    var symbol: String {
        switch self {
        case .groceries: return "cart.fill"
        case .dining: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .income: return "banknote.fill"
        case .transfer: return "arrow.left.arrow.right"
        case .bills: return "bolt.fill"
        case .entertainment: return "film.fill"
        case .health: return "cross.case.fill"
        case .travel: return "airplane"
        }
    }

    var tint: Color {
        switch self {
        case .groceries: return .green
        case .dining: return .orange
        case .transport: return .blue
        case .shopping: return .pink
        case .income: return .mint
        case .transfer: return .indigo
        case .bills: return .yellow
        case .entertainment: return .purple
        case .health: return .red
        case .travel: return .teal
        }
    }
}

fileprivate struct Transaction: Identifiable, Hashable {
    let id = UUID()
    let merchant: String
    let category: TxCategory
    let amount: Decimal          // negative = debit
    let date: Date
    let isPending: Bool
    let method: String

    var isIncome: Bool { amount > 0 }
}

fileprivate enum TxFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expenses = "Expenses"
    var id: String { rawValue }
}

fileprivate enum Fmt {
    static func currency(_ value: Decimal, showPlus: Bool = true) -> String {
        let formatted = abs(value).formatted(.currency(code: "USD"))
        if value > 0 { return showPlus ? "+\(formatted)" : formatted }
        if value < 0 { return "−\(formatted)" }
        return formatted
    }

    static func abs(_ d: Decimal) -> Decimal { d < 0 ? -d : d }

    static func sectionTitle(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}

fileprivate enum SampleData {
    static func make() -> [Transaction] {
        let cal = Calendar.current
        let now = Date()
        func d(_ daysAgo: Int, _ hour: Int, _ minute: Int) -> Date {
            let day = cal.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }
        return [
            Transaction(merchant: "Blue Bottle Coffee", category: .dining, amount: -6.75, date: d(0, 8, 42), isPending: true, method: "Visa •• 4821"),
            Transaction(merchant: "Uber", category: .transport, amount: -18.40, date: d(0, 9, 15), isPending: true, method: "Visa •• 4821"),
            Transaction(merchant: "Whole Foods Market", category: .groceries, amount: -84.12, date: d(0, 18, 5), isPending: false, method: "Visa •• 4821"),
            Transaction(merchant: "Acme Corp Payroll", category: .income, amount: 3250.00, date: d(1, 6, 0), isPending: false, method: "Direct Deposit"),
            Transaction(merchant: "Netflix", category: .entertainment, amount: -15.49, date: d(1, 11, 30), isPending: false, method: "Visa •• 4821"),
            Transaction(merchant: "Sweetgreen", category: .dining, amount: -14.95, date: d(1, 12, 48), isPending: false, method: "Apple Pay"),
            Transaction(merchant: "PG&E Electric", category: .bills, amount: -112.38, date: d(2, 9, 0), isPending: false, method: "Checking •• 0193"),
            Transaction(merchant: "Sarah Chen", category: .transfer, amount: 45.00, date: d(2, 20, 12), isPending: false, method: "Zelle"),
            Transaction(merchant: "Amazon", category: .shopping, amount: -62.99, date: d(3, 14, 22), isPending: false, method: "Visa •• 4821"),
            Transaction(merchant: "CVS Pharmacy", category: .health, amount: -23.17, date: d(3, 17, 40), isPending: false, method: "Apple Pay"),
            Transaction(merchant: "Shell", category: .transport, amount: -51.80, date: d(4, 8, 5), isPending: false, method: "Visa •• 4821"),
            Transaction(merchant: "Trader Joe's", category: .groceries, amount: -47.63, date: d(4, 19, 10), isPending: false, method: "Apple Pay"),
            Transaction(merchant: "Delta Air Lines", category: .travel, amount: -389.20, date: d(5, 10, 33), isPending: false, method: "Visa •• 4821"),
            Transaction(merchant: "Interest Payment", category: .income, amount: 4.12, date: d(5, 0, 1), isPending: false, method: "Savings •• 7710"),
            Transaction(merchant: "Spotify", category: .entertainment, amount: -11.99, date: d(6, 7, 0), isPending: false, method: "Visa •• 4821"),
            Transaction(merchant: "Rent – Oak Street Apts", category: .bills, amount: -2150.00, date: d(7, 9, 0), isPending: false, method: "Checking •• 0193"),
        ]
    }
}

// MARK: - Screen

struct S_list: View {
    @State private var transactions: [Transaction] = SampleData.make()
    @State private var filter: TxFilter = .all
    @State private var searchText: String = ""

    init() {}

    private var filtered: [Transaction] {
        transactions.filter { tx in
            switch filter {
            case .all: break
            case .income: if !tx.isIncome { return false }
            case .expenses: if tx.isIncome { return false }
            }
            guard !searchText.isEmpty else { return true }
            return tx.merchant.localizedCaseInsensitiveContains(searchText)
                || tx.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var sections: [(day: Date, items: [Transaction])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filtered) { cal.startOfDay(for: $0.date) }
        return grouped
            .map { (day: $0.key, items: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    BalanceSummary(transactions: transactions)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section {
                    Picker("Filter", selection: $filter) {
                        ForEach(TxFilter.allCases) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                if sections.isEmpty {
                    Section {
                        ContentUnavailableView.search(text: searchText)
                            .listRowBackground(Color.clear)
                    }
                } else {
                    ForEach(sections, id: \.day) { section in
                        Section {
                            ForEach(section.items) { tx in
                                NavigationLink(value: tx) {
                                    TransactionRow(tx: tx)
                                }
                            }
                        } header: {
                            DayHeader(day: section.day, items: section.items)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .navigationTitle("Transactions")
            .searchable(text: $searchText, prompt: "Search merchants or categories")
            .navigationDestination(for: Transaction.self) { tx in
                TransactionDetail(tx: tx)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Export Statement", systemImage: "square.and.arrow.up") {}
                        Button("Download CSV", systemImage: "tablecells") {}
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
                }
            }
            .refreshable {
                try? await Task.sleep(for: .milliseconds(800))
            }
            .animation(.default, value: filter)
        }
    }
}

// MARK: - Components

fileprivate struct BalanceSummary: View {
    let transactions: [Transaction]
    @Environment(\.dynamicTypeSize) private var dts

    private var moneyIn: Decimal { transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount } }
    private var moneyOut: Decimal { transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount } }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Everyday Checking •• 0193")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(Decimal(8_412.57).formatted(.currency(code: "USD")))
                    .font(.largeTitle.weight(.bold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(dts.isAccessibilitySize ? 2 : 1)
                Text("Available balance")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)

            Divider()

            let layout = dts.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 16))

            layout {
                FlowStat(title: "Money in", value: moneyIn, symbol: "arrow.down.left", tint: .green)
                FlowStat(title: "Money out", value: moneyOut, symbol: "arrow.up.right", tint: .primary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

fileprivate struct FlowStat: View {
    let title: String
    let value: Decimal
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint == .primary ? Color.secondary : tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(Fmt.abs(value).formatted(.currency(code: "USD")))
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(tint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(Fmt.abs(value).formatted(.currency(code: "USD"))), this period")
    }
}

fileprivate struct DayHeader: View {
    let day: Date
    let items: [Transaction]

    private var net: Decimal { items.reduce(0) { $0 + $1.amount } }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) {
                Text(Fmt.sectionTitle(for: day))
                Spacer(minLength: 8)
                Text(Fmt.currency(net))
                    .monospacedDigit()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(Fmt.sectionTitle(for: day))
                Text(Fmt.currency(net))
                    .monospacedDigit()
            }
        }
        .font(.subheadline.weight(.semibold))
        .textCase(nil)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

fileprivate struct CategoryIcon: View {
    let category: TxCategory
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 40

    var body: some View {
        Image(systemName: category.symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(category.tint)
            .frame(width: size, height: size)
            .background(category.tint.opacity(0.15), in: Circle())
            .accessibilityHidden(true)
    }
}

fileprivate struct TransactionRow: View {
    let tx: Transaction
    @Environment(\.dynamicTypeSize) private var dts

    private var amountText: some View {
        Text(Fmt.currency(tx.amount))
            .font(.body.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(tx.isIncome ? Color.green : Color.primary)
    }

    private var subtitle: some View {
        HStack(spacing: 6) {
            if tx.isPending {
                Text("Pending")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.15), in: Capsule())
            }
            Text(tx.category.rawValue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    var body: some View {
        Group {
            if dts.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 6) {
                    CategoryIcon(category: tx.category)
                    Text(tx.merchant)
                        .font(.body.weight(.medium))
                    subtitle
                    amountText
                }
            } else {
                HStack(spacing: 12) {
                    CategoryIcon(category: tx.category)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(tx.merchant)
                            .font(.body.weight(.medium))
                            .lineLimit(2)
                        subtitle
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 3) {
                        amountText
                        Text(tx.date, format: .dateTime.hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var parts = [tx.merchant, tx.category.rawValue]
        let amt = Fmt.abs(tx.amount).formatted(.currency(code: "USD"))
        parts.append(tx.isIncome ? "received \(amt)" : "spent \(amt)")
        if tx.isPending { parts.append("pending") }
        parts.append(tx.date.formatted(date: .omitted, time: .shortened))
        return parts.joined(separator: ", ")
    }
}

fileprivate struct TransactionDetail: View {
    let tx: Transaction

    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    CategoryIcon(category: tx.category)
                        .scaleEffect(1.4)
                        .padding(.bottom, 8)
                    Text(tx.merchant)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                    Text(Fmt.currency(tx.amount))
                        .font(.largeTitle.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(tx.isIncome ? Color.green : Color.primary)
                        .minimumScaleFactor(0.6)
                    if tx.isPending {
                        Label("Pending", systemImage: "clock")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.orange)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowBackground(Color.clear)
            }

            Section("Details") {
                LabeledContent("Status", value: tx.isPending ? "Pending" : "Completed")
                LabeledContent("Date", value: tx.date.formatted(date: .long, time: .shortened))
                LabeledContent("Category", value: tx.category.rawValue)
                LabeledContent("Account", value: tx.method)
            }

            Section {
                Button("Split This Transaction", systemImage: "person.2") {}
                Button("Report a Problem", systemImage: "exclamationmark.bubble", role: .destructive) {}
            }
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }
}
