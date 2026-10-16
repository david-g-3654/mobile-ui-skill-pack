import SwiftUI

fileprivate typealias ListState<Value> = SwiftUI.State<Value>

struct S_list: View {
    @ListState private var search = ""
    @ListState private var selectedFilter = "All"
    @ListState private var selectedTransaction: BankTransaction? = nil
    @ListState private var showingAccount = false

    init() {}

    private let ink = Color(red: 0.13, green: 0.20, blue: 0.18)
    private let green = Color(red: 0.16, green: 0.37, blue: 0.28)
    private let background = Color(red: 0.96, green: 0.96, blue: 0.93)

    private var filteredTransactions: [BankTransaction] {
        BankTransaction.samples.filter { transaction in
            (selectedFilter == "All" || (selectedFilter == "Money in" ? transaction.isIncome : !transaction.isIncome)) &&
            (search.isEmpty || transaction.name.localizedCaseInsensitiveContains(search) || transaction.category.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 27) {
                    header
                    accountCard
                    transactionsHeader
                    searchField
                    filters
                    transactionGroups
                    HStack(spacing: 5) {
                        Image(systemName: "lock.shield")
                        Text("Your money. Always protected.")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 3)
                    .padding(.bottom, 28)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
            }
            .background(background)
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedTransaction) { transaction in
                transactionDetail(transaction)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingAccount) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Everyday account").font(.system(size: 28, weight: .semibold, design: .serif))
                    Text("Available balance").foregroundStyle(.secondary)
                    Text("$12,840.50").font(.system(size: 40, weight: .medium))
                    Divider()
                    LabeledContent("Account", value: "•••• 4829")
                    LabeledContent("Account holder", value: "Alex Morgan")
                    LabeledContent("Currency", value: "USD")
                }
                .padding(28)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        .tint(green)
        .foregroundStyle(ink)
    }

    private var header: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 25))
                Text("north").font(.system(size: 28, weight: .bold, design: .rounded))
                    .tracking(-1.5)
            }
            Spacer()
            Text("AM")
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 39, height: 39)
                .background(Color(red: 0.87, green: 0.89, blue: 0.80), in: Circle())
                .accessibilityLabel("Alex Morgan")
        }
    }

    private var accountCard: some View {
        Button { showingAccount = true } label: {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 7) {
                    Text("EVERYDAY ACCOUNT")
                        .font(.system(size: 10, weight: .semibold)).tracking(1.8)
                    Spacer()
                    Text("•••• 4829").font(.system(size: 11, weight: .medium))
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Available balance").font(.system(size: 12)).opacity(0.72)
                    Text("$12,840").font(.system(size: 36, weight: .regular, design: .serif))
                    + Text(".50").font(.system(size: 26, weight: .regular, design: .serif))
                }
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right").font(.system(size: 10, weight: .semibold))
                    Text("$1,245.80").fontWeight(.semibold)
                    Text("more in than out this month").opacity(0.7)
                }
                .font(.system(size: 10))
            }
            .foregroundStyle(Color(red: 0.95, green: 0.97, blue: 0.87))
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(green, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var transactionsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Transactions")
                .font(.system(size: 31, weight: .regular, design: .serif))
                .tracking(-0.8)
            Spacer()
            Text("OCTOBER 2026")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.1)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 2)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.system(size: 17))
            TextField("Search transactions", text: $search)
                .font(.system(size: 14))
                .autocorrectionDisabled()
            if !search.isEmpty {
                Button { search = "" } label: { Image(systemName: "xmark.circle.fill") }
                    .accessibilityLabel("Clear search")
            }
        }
        .foregroundStyle(ink.opacity(0.5))
        .padding(15)
        .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(ink.opacity(0.07)))
        .padding(.top, -10)
    }

    private var filters: some View {
        HStack(spacing: 8) {
            ForEach(["All", "Money out", "Money in"], id: \.self) { filter in
                Button { withAnimation(.easeInOut(duration: 0.18)) { selectedFilter = filter } } label: {
                    HStack(spacing: 5) {
                        if filter != "All" {
                            Image(systemName: filter == "Money in" ? "arrow.down.left" : "arrow.up.right")
                                .font(.system(size: 10, weight: .medium))
                        }
                        Text(filter).font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundStyle(selectedFilter == filter ? Color.white : ink.opacity(0.7))
                    .background(selectedFilter == filter ? ink : Color.clear, in: Capsule())
                    .overlay(Capsule().strokeBorder(selectedFilter == filter ? Color.clear : ink.opacity(0.13)))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedFilter == filter ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
        .padding(.top, -14)
    }

    private var transactionGroups: some View {
        VStack(spacing: 25) {
            if filteredTransactions.isEmpty {
                ContentUnavailableView.search(text: search)
            } else {
                ForEach(["Today", "Yesterday", "Wednesday, Oct 14"], id: \.self) { day in
                    let transactions = filteredTransactions.filter { $0.day == day }
                    if !transactions.isEmpty {
                        VStack(spacing: 0) {
                            HStack {
                                Text(day.uppercased())
                                    .font(.system(size: 10, weight: .semibold)).tracking(1.3)
                                Spacer()
                                Text(day == "Today" ? "OCT 16" : day == "Yesterday" ? "OCT 15" : "")
                                    .font(.system(size: 9, weight: .medium)).tracking(0.7)
                            }
                            .foregroundStyle(ink.opacity(0.47))
                            .padding(.bottom, 9)
                            ForEach(transactions) { transaction in
                                Button { selectedTransaction = transaction } label: {
                                    transactionRow(transaction)
                                }
                                .buttonStyle(.plain)
                                if transaction.id != transactions.last?.id {
                                    Divider().overlay(ink.opacity(0.03)).padding(.leading, 57)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, -1)
    }

    private func transactionRow(_ transaction: BankTransaction) -> some View {
        HStack(spacing: 13) {
            Image(systemName: transaction.symbol)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(transaction.iconColor)
                .frame(width: 44, height: 44)
                .background(transaction.iconColor.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.name).font(.system(size: 14, weight: .semibold))
                Text(transaction.category).font(.system(size: 11)).foregroundStyle(ink.opacity(0.5))
            }
            Spacer(minLength: 6)
            VStack(alignment: .trailing, spacing: 5) {
                Text(transaction.amount)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(transaction.isIncome ? green : ink)
                    .monospacedDigit()
                Text(transaction.status)
                    .font(.system(size: 10))
                    .foregroundStyle(transaction.status == "Pending" ? Color(red: 0.63, green: 0.43, blue: 0.19) : ink.opacity(0.43))
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var bottomBar: some View {
        HStack {
            Image(systemName: "building.columns")
                .foregroundStyle(ink.opacity(0.4))
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Banking")
            HStack(spacing: 7) {
                Image(systemName: "arrow.left.arrow.right")
                Text("Activity").font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(green)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(green.opacity(0.08), in: Capsule())
            .frame(maxWidth: .infinity)
            Image(systemName: "chart.pie")
                .foregroundStyle(ink.opacity(0.4))
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Insights")
        }
        .font(.system(size: 21))
        .padding(.horizontal, 16)
        .padding(.top, 13)
        .padding(.bottom, 8)
        .background(background.shadow(color: .black.opacity(0.04), radius: 12, y: -6))
    }

    private func transactionDetail(_ transaction: BankTransaction) -> some View {
        VStack(spacing: 19) {
            Image(systemName: transaction.symbol)
                .font(.system(size: 28))
                .foregroundStyle(transaction.iconColor)
                .frame(width: 66, height: 66)
                .background(transaction.iconColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
            Text(transaction.name).font(.system(size: 24, weight: .semibold, design: .serif))
            Text(transaction.amount).font(.system(size: 35, weight: .medium))
            Divider()
            LabeledContent("Category", value: transaction.category)
            LabeledContent("Status", value: transaction.status)
            LabeledContent("Paid with", value: "Everyday •• 4829")
        }
        .padding(28)
    }
}

fileprivate struct BankTransaction: Identifiable {
    let id: Int
    let name: String
    let category: String
    let amount: String
    let symbol: String
    let day: String
    let status: String
    let iconColor: Color
    var isIncome: Bool { amount.hasPrefix("+") }

    static let samples: [BankTransaction] = [
        .init(id: 1, name: "Blue Bottle Coffee", category: "Food & drink", amount: "−$6.50", symbol: "cup.and.saucer.fill", day: "Today", status: "Pending", iconColor: Color(red: 0.35, green: 0.46, blue: 0.58)),
        .init(id: 2, name: "Whole Foods Market", category: "Groceries", amount: "−$84.32", symbol: "basket.fill", day: "Today", status: "10:24 AM", iconColor: Color(red: 0.32, green: 0.45, blue: 0.31)),
        .init(id: 3, name: "From Jamie", category: "Transfer · Dinner split", amount: "+$42.00", symbol: "arrow.down.left", day: "Today", status: "9:15 AM", iconColor: Color(red: 0.29, green: 0.46, blue: 0.36)),
        .init(id: 4, name: "Spotify Premium", category: "Subscriptions", amount: "−$11.99", symbol: "waveform", day: "Yesterday", status: "Completed", iconColor: Color(red: 0.24, green: 0.43, blue: 0.30)),
        .init(id: 5, name: "Acme Studio", category: "Income · Salary", amount: "+$4,250.00", symbol: "building.2.fill", day: "Yesterday", status: "Completed", iconColor: Color(red: 0.41, green: 0.39, blue: 0.58)),
        .init(id: 6, name: "Uber", category: "Transport", amount: "−$18.40", symbol: "car.fill", day: "Yesterday", status: "Completed", iconColor: Color(red: 0.29, green: 0.31, blue: 0.32)),
        .init(id: 7, name: "Kinokuniya", category: "Shopping · Books", amount: "−$28.00", symbol: "book.closed.fill", day: "Wednesday, Oct 14", status: "Completed", iconColor: Color(red: 0.62, green: 0.39, blue: 0.26)),
        .init(id: 8, name: "Sweetgreen", category: "Food & drink", amount: "−$16.75", symbol: "leaf.fill", day: "Wednesday, Oct 14", status: "Completed", iconColor: Color(red: 0.38, green: 0.47, blue: 0.25))
    ]
}
