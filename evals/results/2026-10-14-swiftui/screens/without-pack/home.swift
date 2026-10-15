import SwiftUI

// MARK: - Models

fileprivate struct BudgetCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let spent: Double
    let limit: Double

    var progress: Double { min(spent / limit, 1.0) }
    var remaining: Double { limit - spent }
    var isOver: Bool { spent > limit }
}

fileprivate struct Transaction: Identifiable {
    let id = UUID()
    let merchant: String
    let category: String
    let icon: String
    let color: Color
    let amount: Double // negative = expense
    let date: Date
}

fileprivate enum SampleData {
    static let monthlyIncome: Double = 5_200
    static let monthlyBudget: Double = 3_800

    static let categories: [BudgetCategory] = [
        .init(name: "Groceries", icon: "cart.fill", color: .green, spent: 412.35, limit: 550),
        .init(name: "Dining Out", icon: "fork.knife", color: .orange, spent: 268.90, limit: 250),
        .init(name: "Transport", icon: "car.fill", color: .blue, spent: 134.20, limit: 220),
        .init(name: "Shopping", icon: "bag.fill", color: .pink, spent: 189.99, limit: 300),
        .init(name: "Entertainment", icon: "film.fill", color: .purple, spent: 64.00, limit: 120),
        .init(name: "Utilities", icon: "bolt.fill", color: .yellow, spent: 158.42, limit: 200)
    ]

    static let rent: Double = 1_450

    static func daysAgo(_ d: Int, hour: Int = 12) -> Date {
        let cal = Calendar.current
        let base = cal.date(byAdding: .day, value: -d, to: Date()) ?? Date()
        return cal.date(bySettingHour: hour, minute: 15, second: 0, of: base) ?? base
    }

    static let transactions: [Transaction] = [
        .init(merchant: "Trader Joe's", category: "Groceries", icon: "cart.fill", color: .green, amount: -58.12, date: daysAgo(0, hour: 18)),
        .init(merchant: "Blue Bottle Coffee", category: "Dining Out", icon: "cup.and.saucer.fill", color: .orange, amount: -6.75, date: daysAgo(0, hour: 8)),
        .init(merchant: "Acme Corp Payroll", category: "Income", icon: "arrow.down.circle.fill", color: .mint, amount: 2_600.00, date: daysAgo(1, hour: 9)),
        .init(merchant: "Uber", category: "Transport", icon: "car.fill", color: .blue, amount: -18.40, date: daysAgo(1, hour: 22)),
        .init(merchant: "Netflix", category: "Entertainment", icon: "play.tv.fill", color: .purple, amount: -15.49, date: daysAgo(2)),
        .init(merchant: "PG&E", category: "Utilities", icon: "bolt.fill", color: .yellow, amount: -92.18, date: daysAgo(3)),
        .init(merchant: "Uniqlo", category: "Shopping", icon: "tshirt.fill", color: .pink, amount: -49.90, date: daysAgo(4))
    ]

    // Daily cumulative spending for the current month (sparkline)
    static let dailySpend: [Double] = [
        1450, 1478, 1502, 1530, 1611, 1640, 1655, 1702, 1750, 1790,
        1801, 1850, 1912, 1960, 2010, 2066, 2102, 2150, 2227, 2290,
        2340, 2380
    ]
}

fileprivate extension Double {
    var currency: String {
        self.formatted(.currency(code: "USD").precision(.fractionLength(2)))
    }
    var currencyShort: String {
        self.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
}

// MARK: - Screen

struct S_home: View {
    init() {}

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeDashboard()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            PlaceholderTab(title: "Budgets", icon: "chart.pie.fill")
                .tabItem { Label("Budgets", systemImage: "chart.pie.fill") }
                .tag(1)
            PlaceholderTab(title: "Transactions", icon: "list.bullet.rectangle.fill")
                .tabItem { Label("Activity", systemImage: "list.bullet.rectangle.fill") }
                .tag(2)
            PlaceholderTab(title: "Goals", icon: "flag.checkered")
                .tabItem { Label("Goals", systemImage: "flag.checkered") }
                .tag(3)
        }
        .tint(.indigo)
    }
}

fileprivate struct PlaceholderTab: View {
    let title: String
    let icon: String
    var body: some View {
        NavigationStack {
            ContentUnavailableView(title, systemImage: icon, description: Text("Coming soon."))
                .navigationTitle(title)
        }
    }
}

// MARK: - Dashboard

fileprivate struct HomeDashboard: View {
    private let categories = SampleData.categories
    private let transactions = SampleData.transactions

    private var totalSpent: Double {
        categories.reduce(0) { $0 + $1.spent } + SampleData.rent
    }
    private var leftToSpend: Double { SampleData.monthlyBudget - totalSpent }

    private var daysLeftInMonth: Int {
        let cal = Calendar.current
        let now = Date()
        guard let range = cal.range(of: .day, in: .month, for: now) else { return 0 }
        return range.count - cal.component(.day, from: now) + 1
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SummaryCard(
                        leftToSpend: leftToSpend,
                        spent: totalSpent,
                        budget: SampleData.monthlyBudget,
                        daysLeft: daysLeftInMonth,
                        trend: SampleData.dailySpend
                    )

                    QuickActions()

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Budgets", action: "See all")
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(categories) { CategoryCard(category: $0) }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Recent Transactions", action: "See all")
                        VStack(spacing: 0) {
                            ForEach(Array(transactions.enumerated()), id: \.element.id) { index, tx in
                                TransactionRow(transaction: tx)
                                if index < transactions.count - 1 {
                                    Divider().padding(.leading, 64)
                                }
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Hi, Alex")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "bell.badge")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityLabel("Notifications")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Profile")
                }
            }
        }
    }
}

// MARK: - Summary Card

fileprivate struct SummaryCard: View {
    let leftToSpend: Double
    let spent: Double
    let budget: Double
    let daysLeft: Int
    let trend: [Double]

    private var progress: Double { min(spent / budget, 1) }
    private var perDay: Double { daysLeft > 0 ? max(leftToSpend, 0) / Double(daysLeft) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date().formatted(.dateTime.month(.wide).year()))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Left to spend")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(leftToSpend.currency)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                Spacer()
                Sparkline(values: trend)
                    .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 90, height: 44)
                    .padding(.top, 20)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.25))
                        Capsule().fill(.white)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(spent.currencyShort) spent")
                    Spacer()
                    Text("of \(budget.currencyShort)")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
            }

            HStack(spacing: 0) {
                StatPill(icon: "calendar", title: "\(daysLeft) days left")
                Spacer(minLength: 8)
                StatPill(icon: "gauge.with.dots.needle.33percent", title: "\(perDay.currencyShort)/day")
            }
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color.indigo, Color(red: 0.42, green: 0.27, blue: 0.85)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: .indigo.opacity(0.3), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct StatPill: View {
    let icon: String
    let title: String
    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.white.opacity(0.18), in: Capsule())
    }
}

fileprivate struct Sparkline: Shape {
    let values: [Double]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard values.count > 1, let lo = values.min(), let hi = values.max(), hi > lo else { return path }
        let step = rect.width / CGFloat(values.count - 1)
        for (i, v) in values.enumerated() {
            let x = CGFloat(i) * step
            let y = rect.height - CGFloat((v - lo) / (hi - lo)) * rect.height
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        return path
    }
}

// MARK: - Quick Actions

fileprivate struct QuickActions: View {
    private let actions: [(String, String)] = [
        ("Add Expense", "minus.circle.fill"),
        ("Add Income", "plus.circle.fill"),
        ("Transfer", "arrow.left.arrow.right.circle.fill"),
        ("Scan Receipt", "doc.viewfinder.fill")
    ]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(actions, id: \.0) { action in
                Button {
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: action.1)
                            .font(.title2)
                            .foregroundStyle(.indigo)
                        Text(action.0)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Section header

fileprivate struct SectionHeader: View {
    let title: String
    let action: String
    var body: some View {
        HStack {
            Text(title).font(.title3.weight(.semibold))
            Spacer()
            Button(action) {}
                .font(.subheadline)
        }
    }
}

// MARK: - Category card

fileprivate struct CategoryCard: View {
    let category: BudgetCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: category.icon)
                    .font(.subheadline)
                    .foregroundStyle(category.color)
                    .frame(width: 32, height: 32)
                    .background(category.color.opacity(0.15), in: Circle())
                Spacer()
                if category.isOver {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            Text(category.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            ProgressView(value: category.progress)
                .tint(category.isOver ? .red : category.color)
            Text(category.isOver
                 ? "\((-category.remaining).currencyShort) over"
                 : "\(category.remaining.currencyShort) left")
                .font(.caption)
                .foregroundStyle(category.isOver ? .red : .secondary)
            + Text(" of \(category.limit.currencyShort)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Transaction row

fileprivate struct TransactionRow: View {
    let transaction: Transaction

    private var dateText: String {
        let cal = Calendar.current
        if cal.isDateInToday(transaction.date) { return "Today, " + transaction.date.formatted(date: .omitted, time: .shortened) }
        if cal.isDateInYesterday(transaction.date) { return "Yesterday" }
        return transaction.date.formatted(.dateTime.month(.abbreviated).day())
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.icon)
                .font(.body)
                .foregroundStyle(transaction.color)
                .frame(width: 40, height: 40)
                .background(transaction.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchant)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("\(transaction.category) · \(dateText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text((transaction.amount > 0 ? "+" : "") + transaction.amount.currency)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(transaction.amount > 0 ? .green : .primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    S_home()
}
