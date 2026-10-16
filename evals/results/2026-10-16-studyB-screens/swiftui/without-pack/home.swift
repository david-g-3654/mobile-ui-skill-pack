import SwiftUI

fileprivate typealias BudgetState<Value> = SwiftUI.State<Value>

fileprivate enum BudgetStyle {
    static let ink = Color(red: 0.15, green: 0.23, blue: 0.20)
    static let green = Color(red: 0.23, green: 0.39, blue: 0.30)
    static let background = Color(red: 0.97, green: 0.96, blue: 0.93)
    static let muted = Color(red: 0.48, green: 0.51, blue: 0.46)
}

struct S_home: View {
    @BudgetState private var selectedTab = 0
    @BudgetState private var showingEntry = false
    @BudgetState private var showingNotifications = false
    @BudgetState private var monthOffset = 0
    @BudgetState private var expenseName = ""
    @BudgetState private var expenseAmount = ""
    @BudgetState private var addedExpenses: [BudgetTransaction] = []

    init() {}

    private var monthName: String {
        let date = Calendar.current.date(byAdding: .month, value: monthOffset, to: Date(timeIntervalSince1970: 1792108800))!
        return date.formatted(.dateTime.month(.wide).year())
    }

    private var addedTotal: Double { addedExpenses.reduce(0) { $0 + $1.amount } }

    var body: some View {
        ZStack {
            BudgetStyle.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 27) {
                    header
                    if selectedTab == 0 {
                        overview
                        spendingSection
                        transactionsSection
                    } else if selectedTab == 1 {
                        budgetPage
                    } else {
                        activityPage
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
        .foregroundStyle(BudgetStyle.ink)
        .sheet(isPresented: $showingEntry) { entrySheet }
        .sheet(isPresented: $showingNotifications) {
            NavigationStack {
                VStack(spacing: 18) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 46)).foregroundStyle(BudgetStyle.green)
                    Text("Looking good, Alex").font(.title2.bold())
                    Text("You’ve used 65% of your monthly budget. Keep your daily spending under $68 to stay on track.")
                        .multilineTextAlignment(.center).foregroundStyle(.secondary)
                }
                .padding(32)
                .navigationTitle("Your check-in")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingNotifications = false } } }
            }
            .presentationDetents([.medium])
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14).fill(BudgetStyle.green).frame(width: 43, height: 43)
                    Image(systemName: "leaf.fill").font(.system(size: 21)).foregroundStyle(.white)
                }
                Text("folio").font(.system(size: 29, weight: .bold, design: .rounded)).tracking(-1.2)
            }
            Spacer()
            Button { showingNotifications = true } label: {
                Image(systemName: "bell").font(.system(size: 19))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.8), in: Circle())
                    .overlay(alignment: .topTrailing) {
                        Circle().fill(Color(red: 0.79, green: 0.44, blue: 0.28))
                            .frame(width: 7, height: 7).offset(x: -8, y: 7)
                    }
            }
            .accessibilityLabel("Notifications")
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 5) {
                Text("A little clarity, every day.")
                    .font(.system(size: 13, weight: .medium)).foregroundStyle(BudgetStyle.muted)
                Text("You’re doing well, Alex.")
                    .font(.system(size: 28, weight: .semibold, design: .serif)).tracking(-0.8)
            }
            VStack(alignment: .leading, spacing: 23) {
                HStack {
                    Text(monthName).font(.system(size: 14, weight: .medium))
                    Spacer()
                    HStack(spacing: 18) {
                        Button { monthOffset -= 1 } label: { Image(systemName: "chevron.left") }
                            .accessibilityLabel("Previous month")
                        Button { monthOffset += 1 } label: { Image(systemName: "chevron.right") }
                            .accessibilityLabel("Next month")
                    }.font(.system(size: 11, weight: .bold))
                }.foregroundStyle(.white.opacity(0.8))
                VStack(alignment: .leading, spacing: 5) {
                    Text("Left to spend").font(.system(size: 14)).foregroundStyle(.white.opacity(0.73))
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(Int((1380 - addedTotal).rounded(.towardZero)).formatted(.currency(code: "USD").precision(.fractionLength(0))))
                            .font(.system(size: 49, weight: .medium, design: .rounded)).tracking(-2)
                        Text(String(format: ".%02d", abs(Int(((1380 - addedTotal) * 100).rounded())) % 100)).font(.system(size: 26, weight: .regular, design: .rounded)).foregroundStyle(.white.opacity(0.55))
                    }
                }
                VStack(spacing: 10) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.15))
                            Capsule().fill(Color(red: 0.80, green: 0.87, blue: 0.62))
                                .frame(width: geometry.size.width * min((2620 + addedTotal) / 4000, 1))
                        }
                    }.frame(height: 7)
                    HStack {
                        Text("\((2620 + addedTotal).formatted(.currency(code: "USD").precision(.fractionLength(0)))) spent")
                        Spacer()
                        Text("of $4,000")
                    }.font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                }
                Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                HStack {
                    Label("On track", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 0.83, green: 0.90, blue: 0.69))
                    Spacer()
                    Text("16 days to go").font(.system(size: 12)).foregroundStyle(.white.opacity(0.65))
                }
            }
            .padding(23)
            .foregroundStyle(.white)
            .background(BudgetStyle.green, in: RoundedRectangle(cornerRadius: 25))
            HStack(spacing: 12) {
                summaryItem("Income", amount: "$5,200", icon: "arrow.down.left", color: BudgetStyle.green)
                summaryItem("Saved", amount: "$1,200", icon: "sparkles", color: Color(red: 0.65, green: 0.47, blue: 0.26))
            }
        }
    }

    private func summaryItem(_ title: String, amount: String, icon: String, color: Color) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon).font(.system(size: 15, weight: .medium))
                .foregroundStyle(color).frame(width: 34, height: 38)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 12)).foregroundStyle(BudgetStyle.muted)
                Text(amount).font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            Spacer(minLength: 0)
        }.padding(14).frame(maxWidth: .infinity)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))
    }

    private var spendingSection: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                Text("Your budgets").font(.system(size: 20, weight: .semibold, design: .serif))
                Spacer()
                Button("View all") { selectedTab = 1 }.font(.system(size: 12, weight: .semibold)).foregroundStyle(BudgetStyle.green)
            }
            HStack(spacing: 10) {
                categoryCard("Food", symbol: "carrot", spent: 420, limit: 600, color: Color(red: 0.67, green: 0.44, blue: 0.27))
                categoryCard("Shopping", symbol: "bag", spent: 180, limit: 400, color: Color(red: 0.49, green: 0.47, blue: 0.64))
                categoryCard("Transport", symbol: "tram", spent: 120, limit: 200, color: BudgetStyle.green)
            }
        }
    }

    private func categoryCard(_ name: String, symbol: String, spent: Double, limit: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbol).font(.system(size: 20)).foregroundStyle(color)
                .frame(width: 39, height: 39).background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 5) {
                Text(name).font(.system(size: 12, weight: .medium)).lineLimit(1)
                Text(spent.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            VStack(alignment: .leading, spacing: 7) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(color.opacity(0.12))
                        Capsule().fill(color.opacity(0.75)).frame(width: geometry.size.width * spent / limit)
                    }
                }.frame(height: 4)
                Text("of \(Int(limit).formatted(.currency(code: "USD").precision(.fractionLength(0))))")
                    .font(.system(size: 10)).foregroundStyle(BudgetStyle.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                Text("Recent activity").font(.system(size: 20, weight: .semibold, design: .serif))
                Spacer()
                Button { selectedTab = 2 } label: { Image(systemName: "arrow.up.right").font(.system(size: 14)) }
                    .accessibilityLabel("All transactions")
            }
            VStack(spacing: 17) {
                ForEach(Array((addedExpenses + BudgetTransaction.samples).prefix(3))) { transaction in
                    transactionRow(transaction)
                }
            }
        }
    }

    private func transactionRow(_ transaction: BudgetTransaction) -> some View {
        HStack(spacing: 13) {
            Image(systemName: transaction.symbol).font(.system(size: 19))
                .frame(width: 45, height: 45)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.name).font(.system(size: 14, weight: .semibold))
                Text(transaction.category).font(.system(size: 11)).foregroundStyle(BudgetStyle.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text("−" + transaction.amount.formatted(.currency(code: "USD")))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text(transaction.date).font(.system(size: 10)).foregroundStyle(BudgetStyle.muted)
            }
        }
    }

    private var budgetPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Room for what matters.").font(.system(size: 30, weight: .medium, design: .serif))
            Text("October budgets").font(.subheadline).foregroundStyle(BudgetStyle.muted)
            spendingSection
            VStack(alignment: .leading, spacing: 16) {
                Label("Home & bills", systemImage: "house")
                Text("$1,900 of $2,400").font(.title2.weight(.semibold))
                ProgressView(value: 1900, total: 2400).tint(BudgetStyle.green)
                Text("$500 left for the month").font(.subheadline).foregroundStyle(BudgetStyle.muted)
            }.padding(22).background(.white, in: RoundedRectangle(cornerRadius: 20))
        }
    }

    private var activityPage: some View {
        VStack(alignment: .leading, spacing: 23) {
            Text("Every little detail.").font(.system(size: 30, weight: .medium, design: .serif))
            Text("OCTOBER ACTIVITY").font(.system(size: 11, weight: .semibold)).tracking(1.8).foregroundStyle(BudgetStyle.muted)
            ForEach(addedExpenses + BudgetTransaction.samples) { transaction in transactionRow(transaction) }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            tab("Home", symbol: "square.grid.2x2", index: 0)
            tab("Budgets", symbol: "chart.pie", index: 1)
            tab("Activity", symbol: "arrow.left.arrow.right", index: 2)
            Button { showingEntry = true } label: {
                Image(systemName: "plus").font(.system(size: 23, weight: .medium))
                    .foregroundStyle(.white).frame(width: 49, height: 49)
                    .background(BudgetStyle.green, in: RoundedRectangle(cornerRadius: 17))
            }.accessibilityLabel("Add expense").padding(.leading, 20)
        }
        .padding(.horizontal, 25).padding(.top, 13).padding(.bottom, 8)
        .background(BudgetStyle.background.shadow(color: .black.opacity(0.04), radius: 12, y: -6))
    }

    private func tab(_ name: String, symbol: String, index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 6) {
                Image(systemName: symbol + (selectedTab == index && index != 2 ? ".fill" : ""))
                    .font(.system(size: 19))
                Text(name).font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
            }.frame(maxWidth: .infinity)
                .foregroundStyle(selectedTab == index ? BudgetStyle.green : BudgetStyle.muted)
        }
        .accessibilityAddTraits(selectedTab == index ? .isSelected : [])
    }

    private var entrySheet: some View {
        NavigationStack {
            Form {
                Section("Expense details") {
                    TextField("Merchant or description", text: $expenseName)
                    TextField("Amount", text: $expenseAmount).keyboardType(.decimalPad)
                }
                Section {
                    Button("Add expense") {
                        guard let amount = Double(expenseAmount), amount > 0 else { return }
                        addedExpenses.insert(BudgetTransaction(name: expenseName.trimmingCharacters(in: .whitespaces), category: "Other · Personal", amount: amount, symbol: "creditcard", date: "Just now"), at: 0)
                        expenseName = ""
                        expenseAmount = ""
                        showingEntry = false
                    }
                    .disabled(expenseName.trimmingCharacters(in: .whitespaces).isEmpty || (Double(expenseAmount) ?? 0) <= 0)
                }
            }
            .navigationTitle("New expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showingEntry = false } } }
            .tint(BudgetStyle.green)
        }.presentationDetents([.medium, .large])
    }
}

fileprivate struct BudgetTransaction: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let amount: Double
    let symbol: String
    let date: String

    static let samples: [BudgetTransaction] = [
        .init(name: "Whole Foods Market", category: "Food · Groceries", amount: 64.80, symbol: "basket", date: "Today"),
        .init(name: "Blue Bottle Coffee", category: "Food · Coffee", amount: 5.50, symbol: "cup.and.saucer", date: "Today"),
        .init(name: "Spotify Premium", category: "Lifestyle · Subscription", amount: 11.99, symbol: "waveform", date: "Yesterday"),
        .init(name: "Uniqlo", category: "Shopping · Clothing", amount: 49.90, symbol: "tshirt", date: "Oct 13")
    ]
}
