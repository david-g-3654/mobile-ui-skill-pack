import SwiftUI

struct S_list: View {
    @State private var searchText = ""
    @State private var selectedFlow = TransactionFlow.all
    @State private var selectedTransaction: BankTransaction?
    @State private var lastUpdated = Date()

    init() {}

    private var matchingTransactions: [BankTransaction] {
        BankTransaction.samples.filter { transaction in
            let matchesFlow = selectedFlow == .all
                || (selectedFlow == .outgoing && transaction.cents < 0)
                || (selectedFlow == .incoming && transaction.cents > 0)
            let matchesSearch = searchText.isEmpty
                || "\(transaction.merchant) \(transaction.category) \(transaction.note)"
                    .localizedCaseInsensitiveContains(searchText)
            return matchesFlow && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            List {
                summary
                    .listRowInsets(EdgeInsets(top: QSpace.md, leading: QSpace.margin,
                                              bottom: QSpace.xl, trailing: QSpace.margin))
                    .listRowBackground(QPalette.canvas)
                    .listRowSeparator(.hidden)

                flowFilters
                    .listRowInsets(EdgeInsets(top: 0, leading: 0,
                                              bottom: QSpace.sm, trailing: 0))
                    .listRowBackground(QPalette.canvas)
                    .listRowSeparator(.hidden)

                if matchingTransactions.isEmpty {
                    QEmptyState(
                        title: "No matching transactions",
                        message: searchText.isEmpty
                            ? "There are no transactions for this filter. Try all activity."
                            : "Nothing matches “\(searchText)”. Try a merchant or category.",
                        systemImage: "magnifyingglass"
                    ) {
                        Button("Clear filters") {
                            searchText = ""
                            selectedFlow = .all
                        }
                        .buttonStyle(.qTertiary)
                    }
                    .listRowBackground(QPalette.canvas)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach([0, 1, 2, 3], id: \.self) { dayOffset in
                        let dailyTransactions = matchingTransactions.filter { $0.dayOffset == dayOffset }
                        if !dailyTransactions.isEmpty {
                            Section {
                                ForEach(dailyTransactions) { transaction in
                                    Button {
                                        selectedTransaction = transaction
                                    } label: {
                                        TransactionLine(transaction: transaction)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowInsets(EdgeInsets(top: QSpace.md, leading: QSpace.margin,
                                                              bottom: QSpace.md, trailing: QSpace.margin))
                                    .listRowBackground(QPalette.surface)
                                    .listRowSeparatorTint(QPalette.hairline)
                                    .accessibilityHint("Opens transaction details")
                                }
                            } header: {
                                Text(BankTransaction.dayTitle(dayOffset))
                                    .font(.dsSubhead.weight(.semibold))
                                    .foregroundStyle(QPalette.ink2)
                                    .textCase(nil)
                                    .padding(.vertical, QSpace.xs)
                                    .accessibilityAddTraits(.isHeader)
                            }
                        }
                    }

                    Text("Updated \(lastUpdated.formatted(date: .omitted, time: .shortened)) · All amounts in USD")
                        .font(.dsSubhead)
                        .foregroundStyle(QPalette.ink2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, QSpace.sm)
                        .listRowBackground(QPalette.canvas)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .qCanvasBackground()
            .navigationTitle("Transactions")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search merchant or category")
            .searchSuggestions {
                if searchText.isEmpty {
                    Text("Groceries").searchCompletion("Groceries")
                    Text("Transport").searchCompletion("Transport")
                    Text("Income").searchCompletion("Income")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .refreshable { lastUpdated = Date() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: statement) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share transaction summary")
                }
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionReceipt(transaction: transaction)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(QRadius.xl)
            }
        }
        .tint(QPalette.ink)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            Text("Everyday account · 4821")
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
            HStack(alignment: .firstTextBaseline, spacing: QSpace.xxs) {
                Text(String(BankTransaction.money(486235).prefix(1)))
                    .font(.dsTitle)
                    .foregroundStyle(QPalette.ink2)
                QHeroText(text: String(BankTransaction.money(486235).dropFirst()))
            }
            Text("Available balance")
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Everyday account ending in 4821. Available balance, 4,862 dollars and 35 cents.")
    }

    private var flowFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: QSpace.xs) {
                ForEach(TransactionFlow.allCases) { flow in
                    Button {
                        selectedFlow = flow
                    } label: {
                        HStack(spacing: QSpace.xxs) {
                            if selectedFlow == flow {
                                Image(systemName: "checkmark")
                                    .accessibilityHidden(true)
                            }
                            Text(flow.rawValue)
                        }
                        .accessibilityLabel(flow.rawValue)
                        .font(.dsSubhead)
                        .padding(.horizontal, QSpace.sm)
                        .frame(minHeight: QMetrics.minTap)
                        .foregroundStyle(selectedFlow == flow ? QPalette.onPrimary : QPalette.ink)
                        .background(selectedFlow == flow ? QPalette.primaryFill : QPalette.surface2,
                                    in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(flow.rawValue)
                    .accessibilityAddTraits(selectedFlow == flow ? .isSelected : [])
                }
            }
            .padding(.horizontal, QSpace.margin)
        }
        .sensoryFeedback(.selection, trigger: selectedFlow)
    }

    private var statement: String {
        (["Everyday account · 4821", "Transaction summary · USD"] + matchingTransactions.map {
            "\($0.date.formatted(date: .abbreviated, time: .omitted)) · \($0.merchant) · \($0.amount) · \($0.pending ? "Pending" : "Completed")"
        }).joined(separator: "\n")
    }
}

fileprivate enum TransactionFlow: String, CaseIterable, Identifiable {
    case all = "All activity"
    case outgoing = "Money out"
    case incoming = "Money in"
    var id: String { rawValue }
}

fileprivate struct BankTransaction: Identifiable {
    let id: String
    let merchant: String
    let category: String
    let symbol: String
    let cents: Int
    let dayOffset: Int
    let note: String
    var pending = false

    var date: Date {
        Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date()
    }

    var amount: String {
        let value = Self.money(abs(cents))
        return "\(cents < 0 ? "−" : "+")\(value)"
    }

    static func money(_ cents: Int) -> String {
        (Double(cents) / 100).formatted(.currency(code: "USD").locale(Locale(identifier: "en_US")))
    }

    static func dayTitle(_ offset: Int) -> String {
        if offset == 0 { return "Today" }
        if offset == 1 { return "Yesterday" }
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
        return date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    static let samples: [BankTransaction] = [
        .init(id: "TX-10482", merchant: "Blue Bottle Coffee", category: "Food & drink", symbol: "cup.and.saucer", cents: -675, dayOffset: 0, note: "San Francisco, CA", pending: true),
        .init(id: "TX-10481", merchant: "Whole Foods Market", category: "Groceries", symbol: "basket", cents: -8642, dayOffset: 0, note: "San Francisco, CA"),
        .init(id: "TX-10480", merchant: "Alex Morgan", category: "Transfer received", symbol: "arrow.down.left", cents: 4850, dayOffset: 0, note: "Dinner on Tuesday"),
        .init(id: "TX-10479", merchant: "SFMTA", category: "Transport", symbol: "tram", cents: -300, dayOffset: 1, note: "Clipper card reload"),
        .init(id: "TX-10478", merchant: "Spotify", category: "Subscriptions", symbol: "music.note", cents: -1299, dayOffset: 1, note: "Premium Individual"),
        .init(id: "TX-10477", merchant: "Good Earth Studio", category: "Income · Salary", symbol: "building.2", cents: 324850, dayOffset: 1, note: "October payroll"),
        .init(id: "TX-10476", merchant: "Tartine Bakery", category: "Food & drink", symbol: "fork.knife", cents: -1845, dayOffset: 2, note: "San Francisco, CA"),
        .init(id: "TX-10475", merchant: "Green Apple Books", category: "Shopping", symbol: "book.closed", cents: -3278, dayOffset: 2, note: "San Francisco, CA"),
        .init(id: "TX-10474", merchant: "Pacific Gas & Electric", category: "Bills & utilities", symbol: "bolt", cents: -9436, dayOffset: 3, note: "Monthly electricity bill"),
        .init(id: "TX-10473", merchant: "Everlane", category: "Shopping · Refund", symbol: "arrow.uturn.backward", cents: 6800, dayOffset: 3, note: "Returned purchase")
    ]
}

fileprivate struct TransactionLine: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    let transaction: BankTransaction

    var body: some View {
        HStack(alignment: .top, spacing: QSpace.sm) {
            Image(systemName: transaction.symbol)
                .font(.dsBody)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(QPalette.ink2)
                .frame(width: QSpace.xl)
                .frame(minHeight: QSpace.xl)
                .accessibilityHidden(true)

            (typeSize.isAccessibilitySize
             ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.xs))
             : AnyLayout(HStackLayout(alignment: .top, spacing: QSpace.sm))) {
                VStack(alignment: .leading, spacing: QSpace.xxs) {
                    Text(transaction.merchant)
                        .font(.dsBody)
                        .foregroundStyle(QPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(transaction.pending ? "Pending · \(transaction.category)" : transaction.category)
                        .font(.dsSubhead)
                        .foregroundStyle(QPalette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(transaction.amount)
                    .font(.dsBody)
                    .monospacedDigit()
                    .foregroundStyle(transaction.cents > 0 ? QPalette.positive : QPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct TransactionReceipt: View {
    @Environment(\.dismiss) private var dismiss
    let transaction: BankTransaction

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: QSpace.xs) {
                        Text(transaction.merchant).font(.dsTitle)
                        QHeroText(text: transaction.amount)
                        Text(transaction.pending ? "Pending card payment" : "Completed")
                            .font(.dsSubhead)
                            .foregroundStyle(QPalette.ink2)
                    }
                    .padding(.vertical, QSpace.sm)
                    .listRowBackground(QPalette.canvas)
                }
                Section {
                    LabeledContent("Date", value: transaction.date.formatted(date: .abbreviated, time: .omitted))
                    LabeledContent("Category", value: transaction.category)
                    LabeledContent("Account", value: "Everyday · 4821")
                    LabeledContent("Reference", value: transaction.id)
                }
                .qSurfaceRow()
                Section {
                    Text(transaction.note)
                    if transaction.pending {
                        Text("The final amount may change when the merchant completes this payment.")
                    }
                }
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
                .listRowBackground(QPalette.canvas)
            }
            .listStyle(.insetGrouped)
            .qCanvasBackground()
            .foregroundStyle(QPalette.ink)
            .navigationTitle("Transaction details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(QPalette.ink)
    }
}

#Preview("Light") {
    S_list().preferredColorScheme(.light)
}

#Preview("Dark") {
    S_list().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_list().dynamicTypeSize(.accessibility2)
}
