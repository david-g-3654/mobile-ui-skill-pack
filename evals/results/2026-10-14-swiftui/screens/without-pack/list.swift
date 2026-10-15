import SwiftUI

// MARK: - Model

fileprivate enum TxCategory: String, CaseIterable {
    case groceries = "Groceries"
    case dining = "Dining"
    case transport = "Transport"
    case shopping = "Shopping"
    case salary = "Salary"
    case transfer = "Transfer"
    case bills = "Bills"
    case entertainment = "Entertainment"
    case health = "Health"
    case travel = "Travel"

    var symbol: String {
        switch self {
        case .groceries: return "cart.fill"
        case .dining: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .salary: return "briefcase.fill"
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
        case .salary: return .teal
        case .transfer: return .indigo
        case .bills: return .yellow
        case .entertainment: return .purple
        case .health: return .red
        case .travel: return .cyan
        }
    }
}

fileprivate enum TxStatus {
    case completed, pending, declined
}

fileprivate struct Transaction: Identifiable, Hashable {
    let id = UUID()
    let merchant: String
    let category: TxCategory
    let amount: Decimal          // negative = debit
    let date: Date
    let status: TxStatus
    let method: String
    let reference: String

    var isIncome: Bool { amount > 0 }
}

fileprivate enum TxFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expenses = "Expenses"
    case pending = "Pending"
    var id: String { rawValue }
}

// MARK: - Formatting

fileprivate enum Fmt {
    static func money(_ value: Decimal, signed: Bool = false) -> String {
        let style = Decimal.FormatStyle.Currency(code: "USD")
        let absValue = value < 0 ? -value : value
        let text = absValue.formatted(style)
        guard signed else { return value < 0 ? "-" + text : text }
        return (value < 0 ? "−" : "+") + text
    }

    static func sectionTitle(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
}

// MARK: - Sample data

fileprivate enum SampleData {
    static func make() -> [Transaction] {
        let now = Date()
        func ago(_ days: Int, _ hour: Int, _ minute: Int) -> Date {
            let cal = Calendar.current
            let day = cal.date(byAdding: .day, value: -days, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }
        return [
            Transaction(merchant: "Blue Bottle Coffee", category: .dining, amount: -6.75, date: ago(0, 8, 42), status: .pending, method: "Visa •• 4821", reference: "POS 88213"),
            Transaction(merchant: "Uber", category: .transport, amount: -18.40, date: ago(0, 8, 5), status: .pending, method: "Visa •• 4821", reference: "UBR 1F2A9"),
            Transaction(merchant: "Whole Foods Market", category: .groceries, amount: -84.19, date: ago(1, 18, 27), status: .completed, method: "Visa •• 4821", reference: "POS 77120"),
            Transaction(merchant: "Sarah Chen", category: .transfer, amount: 45.00, date: ago(1, 13, 10), status: .completed, method: "Instant transfer", reference: "P2P 55021"),
            Transaction(merchant: "Netflix", category: .entertainment, amount: -15.49, date: ago(1, 6, 0), status: .completed, method: "Visa •• 4821", reference: "SUB 99341"),
            Transaction(merchant: "Acme Corp Payroll", category: .salary, amount: 3842.16, date: ago(2, 9, 0), status: .completed, method: "Direct deposit", reference: "ACH 20391"),
            Transaction(merchant: "Con Edison", category: .bills, amount: -112.58, date: ago(2, 7, 30), status: .completed, method: "Checking •• 0193", reference: "ACH 20388"),
            Transaction(merchant: "Apple Store", category: .shopping, amount: -249.00, date: ago(3, 16, 45), status: .declined, method: "Visa •• 4821", reference: "POS 66012"),
            Transaction(merchant: "Sweetgreen", category: .dining, amount: -14.32, date: ago(3, 12, 18), status: .completed, method: "Apple Pay", reference: "POS 66001"),
            Transaction(merchant: "CVS Pharmacy", category: .health, amount: -23.87, date: ago(4, 19, 2), status: .completed, method: "Visa •• 4821", reference: "POS 54110"),
            Transaction(merchant: "MTA Subway", category: .transport, amount: -34.00, date: ago(4, 8, 15), status: .completed, method: "Apple Pay", reference: "OMNY 3321"),
            Transaction(merchant: "Trader Joe's", category: .groceries, amount: -62.41, date: ago(5, 17, 50), status: .completed, method: "Visa •• 4821", reference: "POS 43018"),
            Transaction(merchant: "Delta Air Lines", category: .travel, amount: -428.60, date: ago(6, 21, 3), status: .completed, method: "Visa •• 4821", reference: "DL 0067213"),
            Transaction(merchant: "Amazon", category: .shopping, amount: -37.99, date: ago(6, 10, 22), status: .completed, method: "Visa •• 4821", reference: "AMZ 113-49"),
            Transaction(merchant: "Amazon Refund", category: .shopping, amount: 19.99, date: ago(7, 15, 40), status: .completed, method: "Visa •• 4821", reference: "AMZ 113-12"),
            Transaction(merchant: "Spotify", category: .entertainment, amount: -11.99, date: ago(8, 6, 0), status: .completed, method: "Visa •• 4821", reference: "SUB 88120"),
            Transaction(merchant: "Verizon Wireless", category: .bills, amount: -85.00, date: ago(9, 7, 0), status: .completed, method: "Checking •• 0193", reference: "ACH 19920"),
        ]
    }
}

// MARK: - Screen

struct S_list: View {
    @State private var transactions: [Transaction] = SampleData.make()
    @State private var filter: TxFilter = .all
    @State private var query: String = ""

    init() {}

    private var filtered: [Transaction] {
        transactions.filter { tx in
            switch filter {
            case .all: break
            case .income: if !tx.isIncome { return false }
            case .expenses: if tx.isIncome { return false }
            case .pending: if tx.status != .pending { return false }
            }
            let q = query.trimmingCharacters(in: .whitespaces)
            guard !q.isEmpty else { return true }
            return tx.merchant.localizedCaseInsensitiveContains(q)
                || tx.category.rawValue.localizedCaseInsensitiveContains(q)
        }
        .sorted { $0.date > $1.date }
    }

    private var sections: [(day: Date, items: [Transaction])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filtered) { cal.startOfDay(for: $0.date) }
        return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
    }

    private var monthIn: Decimal {
        transactions.filter { $0.isIncome && $0.status != .declined }.reduce(0) { $0 + $1.amount }
    }

    private var monthOut: Decimal {
        transactions.filter { !$0.isIncome && $0.status != .declined }.reduce(0) { $0 - $1.amount }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SummaryCard(balance: 12_486.32, moneyIn: monthIn, moneyOut: monthOut)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    FilterBar(selection: $filter)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if sections.isEmpty {
                    Section {
                        ContentUnavailableView(
                            query.isEmpty ? "No \(filter.rawValue.lowercased()) transactions" : "No results for \u{201C}\(query)\u{201D}",
                            systemImage: query.isEmpty ? "tray" : "magnifyingglass",
                            description: Text(query.isEmpty ? "Transactions will appear here as they post to your account." : "Try a different merchant or category.")
                        )
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
                            HStack {
                                Text(Fmt.sectionTitle(section.day))
                                Spacer()
                                let net = section.items
                                    .filter { $0.status != .declined }
                                    .reduce(Decimal(0)) { $0 + $1.amount }
                                Text(Fmt.money(net, signed: true))
                                    .monospacedDigit()
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(nil)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Transactions")
            .searchable(text: $query, prompt: "Search merchants or categories")
            .refreshable {
                try? await Task.sleep(for: .milliseconds(800))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Export statement", systemImage: "square.and.arrow.up") {}
                        Button("Download CSV", systemImage: "doc.text") {}
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
                }
            }
            .navigationDestination(for: Transaction.self) { tx in
                TransactionDetail(tx: tx)
            }
        }
    }
}

// MARK: - Summary

fileprivate struct SummaryCard: View {
    let balance: Decimal
    let moneyIn: Decimal
    let moneyOut: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Everyday Checking •• 0193")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                Text(Fmt.money(balance))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text("Available balance")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            HStack(spacing: 12) {
                stat(title: "Money in", value: moneyIn, symbol: "arrow.down.left")
                stat(title: "Money out", value: moneyOut, symbol: "arrow.up.right")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Color(red: 0.10, green: 0.25, blue: 0.55), Color(red: 0.16, green: 0.45, blue: 0.75)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    private func stat(title: String, value: Decimal, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.footnote.weight(.bold))
                .frame(width: 28, height: 28)
                .background(.white.opacity(0.2), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).opacity(0.8)
                Text(Fmt.money(value)).font(.subheadline.weight(.semibold)).monospacedDigit()
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Filter bar

fileprivate struct FilterBar: View {
    @Binding var selection: TxFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TxFilter.allCases) { f in
                    let selected = f == selection
                    Button {
                        withAnimation(.snappy) { selection = f }
                    } label: {
                        Text(f.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundStyle(selected ? Color.white : Color.primary)
                            .background(selected ? Color.accentColor : Color(.secondarySystemGroupedBackground),
                                        in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Row

fileprivate struct CategoryIcon: View {
    let category: TxCategory
    var size: CGFloat = 40

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

    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: tx.category)

            VStack(alignment: .leading, spacing: 3) {
                Text(tx.merchant)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(tx.category.rawValue)
                    Text("·")
                    Text(tx.date, format: .dateTime.hour().minute())
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text(Fmt.money(tx.amount, signed: true))
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .strikethrough(tx.status == .declined)
                    .foregroundStyle(amountColor)
                StatusBadge(status: tx.status)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    private var amountColor: Color {
        if tx.status == .declined { return .secondary }
        return tx.isIncome ? .green : .primary
    }
}

fileprivate struct StatusBadge: View {
    let status: TxStatus

    var body: some View {
        switch status {
        case .completed:
            EmptyView()
        case .pending:
            label("Pending", color: .orange)
        case .declined:
            label("Declined", color: .red)
        }
    }

    private func label(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(color)
            .background(color.opacity(0.15), in: Capsule())
    }
}

// MARK: - Detail

fileprivate struct TransactionDetail: View {
    let tx: Transaction

    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    CategoryIcon(category: tx.category, size: 64)
                    Text(tx.merchant).font(.title3.weight(.semibold))
                    Text(Fmt.money(tx.amount, signed: true))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(tx.isIncome ? .green : .primary)
                        .strikethrough(tx.status == .declined)
                    StatusBadge(status: tx.status)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section("Details") {
                LabeledContent("Status", value: statusText)
                LabeledContent("Date", value: tx.date.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Category", value: tx.category.rawValue)
                LabeledContent("Payment method", value: tx.method)
                LabeledContent("Reference", value: tx.reference)
            }

            Section {
                Button("Split with friends", systemImage: "person.2") {}
                Button("Report a problem", systemImage: "exclamationmark.bubble") {}
                    .tint(.red)
            }
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusText: String {
        switch tx.status {
        case .completed: return "Completed"
        case .pending: return "Pending"
        case .declined: return "Declined"
        }
    }
}

#Preview {
    S_list()
}
