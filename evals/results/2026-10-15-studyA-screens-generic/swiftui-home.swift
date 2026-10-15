import SwiftUI

// MARK: - Models

fileprivate struct BudgetCategory: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let color: Color
    let spent: Double
    let limit: Double

    var progress: Double { min(spent / limit, 1) }
    var remaining: Double { limit - spent }
    var isOver: Bool { spent > limit }
}

fileprivate struct Transaction: Identifiable {
    let id = UUID()
    let merchant: String
    let category: String
    let symbol: String
    let color: Color
    let amount: Double // negative = expense
    let date: Date
}

fileprivate enum SampleData {
    static let monthlyBudget: Double = 3_200
    static let income: Double = 4_850

    static let categories: [BudgetCategory] = [
        .init(name: "Groceries", symbol: "cart.fill", color: .green, spent: 412.37, limit: 550),
        .init(name: "Dining Out", symbol: "fork.knife", color: .orange, spent: 268.90, limit: 250),
        .init(name: "Transport", symbol: "car.fill", color: .blue, spent: 94.20, limit: 180),
        .init(name: "Shopping", symbol: "bag.fill", color: .pink, spent: 156.48, limit: 300),
        .init(name: "Entertainment", symbol: "film.fill", color: .purple, spent: 61.97, limit: 120),
    ]

    static var totalSpent: Double {
        categories.reduce(0) { $0 + $1.spent } + 1_150 // + rent & bills
    }

    static func daysAgo(_ d: Int, hour: Int = 12) -> Date {
        let cal = Calendar.current
        let base = cal.date(byAdding: .day, value: -d, to: .now) ?? .now
        return cal.date(bySettingHour: hour, minute: 15, second: 0, of: base) ?? base
    }

    static let transactions: [Transaction] = [
        .init(merchant: "Trader Joe's", category: "Groceries", symbol: "cart.fill", color: .green, amount: -64.12, date: daysAgo(0, hour: 18)),
        .init(merchant: "Blue Bottle Coffee", category: "Dining Out", symbol: "cup.and.saucer.fill", color: .orange, amount: -6.75, date: daysAgo(0, hour: 9)),
        .init(merchant: "Acme Corp Payroll", category: "Income", symbol: "arrow.down.circle.fill", color: .mint, amount: 2_425.00, date: daysAgo(1, hour: 8)),
        .init(merchant: "Lyft", category: "Transport", symbol: "car.fill", color: .blue, amount: -18.40, date: daysAgo(1, hour: 22)),
        .init(merchant: "Netflix", category: "Entertainment", symbol: "play.tv.fill", color: .purple, amount: -15.49, date: daysAgo(2)),
        .init(merchant: "Uniqlo", category: "Shopping", symbol: "tshirt.fill", color: .pink, amount: -49.90, date: daysAgo(3)),
    ]
}

fileprivate extension Double {
    func currency(showSign: Bool = false, fraction: Bool = true) -> String {
        var style = FloatingPointFormatStyle<Double>.Currency(code: "USD")
            .precision(.fractionLength(fraction ? 2 : 0))
        if showSign { style = style.sign(strategy: .always()) }
        return self.formatted(style)
    }
}

// MARK: - Root

struct S_home: View {
    init() {}

    var body: some View {
        TabView {
            HomeTab()
                .tabItem { Label("Home", systemImage: "house.fill") }
            PlaceholderTab(title: "Budgets", symbol: "chart.pie.fill")
                .tabItem { Label("Budgets", systemImage: "chart.pie.fill") }
            PlaceholderTab(title: "Activity", symbol: "list.bullet.rectangle.fill")
                .tabItem { Label("Activity", systemImage: "list.bullet.rectangle.fill") }
            PlaceholderTab(title: "Settings", symbol: "gearshape.fill")
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

fileprivate struct PlaceholderTab: View {
    let title: String
    let symbol: String
    var body: some View {
        NavigationStack {
            ContentUnavailableView(title, systemImage: symbol, description: Text("Coming soon."))
                .navigationTitle(title)
        }
    }
}

// MARK: - Home

fileprivate struct HomeTab: View {
    @State private var showingAdd = false

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: .now)
        switch h {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SummaryCard(
                        spent: SampleData.totalSpent,
                        budget: SampleData.monthlyBudget,
                        income: SampleData.income
                    )

                    QuickActions(onAdd: { showingAdd = true })

                    SectionHeader(title: "Budgets", action: "See All")
                    VStack(spacing: 0) {
                        ForEach(Array(SampleData.categories.enumerated()), id: \.element.id) { idx, cat in
                            CategoryRow(category: cat)
                            if idx < SampleData.categories.count - 1 {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }
                    .cardBackground()

                    SectionHeader(title: "Recent Activity", action: "See All")
                    VStack(spacing: 0) {
                        ForEach(Array(SampleData.transactions.enumerated()), id: \.element.id) { idx, tx in
                            TransactionRow(tx: tx)
                            if idx < SampleData.transactions.count - 1 {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }
                    .cardBackground()
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(greeting)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: {
                        Image(systemName: "bell")
                    }
                    .accessibilityLabel("Notifications")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityLabel("Add transaction")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTransactionSheet()
            }
        }
    }
}

// MARK: - Summary card

fileprivate struct SummaryCard: View {
    let spent: Double
    let budget: Double
    let income: Double
    @Environment(\.dynamicTypeSize) private var typeSize

    private var remaining: Double { budget - spent }
    private var progress: Double { min(spent / budget, 1) }

    private var daysLeft: Int {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: .now) else { return 0 }
        return range.count - cal.component(.day, from: .now) + 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Left to spend in \(Date.now.formatted(.dateTime.month(.wide)))")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text(remaining.currency())
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text("\(max(remaining / Double(max(daysLeft, 1)), 0).currency()) per day · \(daysLeft) days left")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: progress)
                    .tint(.white)
                    .background(.white.opacity(0.25), in: Capsule())
                    .scaleEffect(x: 1, y: 1.6, anchor: .center)
                    .padding(.vertical, 2)
                Text("\(spent.currency(fraction: false)) of \(budget.currency(fraction: false)) spent")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Budget used")
            .accessibilityValue("\(Int(progress * 100)) percent, \(spent.currency(fraction: false)) of \(budget.currency(fraction: false))")

            let stats = Group {
                StatPill(title: "Income", value: income.currency(fraction: false), symbol: "arrow.down.left")
                StatPill(title: "Spent", value: spent.currency(fraction: false), symbol: "arrow.up.right")
            }
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 10) { stats }
            } else {
                HStack(spacing: 10) { stats }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.20, green: 0.42, blue: 0.95), Color(red: 0.42, green: 0.27, blue: 0.86)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: Color.indigo.opacity(0.25), radius: 16, y: 8)
        .padding(.top, 8)
    }
}

fileprivate struct StatPill: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.white)
                .padding(8)
                .background(.white.opacity(0.2), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Quick actions

fileprivate struct QuickActions: View {
    var onAdd: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    private let items: [(String, String, Color)] = [
        ("Add", "plus", .blue),
        ("Transfer", "arrow.left.arrow.right", .teal),
        ("Goals", "target", .orange),
        ("Reports", "chart.bar.xaxis", .purple),
    ]

    var body: some View {
        let columns = typeSize.isAccessibilitySize
            ? [GridItem(.flexible()), GridItem(.flexible())]
            : Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items, id: \.0) { item in
                Button {
                    if item.0 == "Add" { onAdd() }
                } label: {
                    QuickActionLabel(title: item.0, symbol: item.1, color: item.2)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

fileprivate struct QuickActionLabel: View {
    let title: String
    let symbol: String
    let color: Color
    @ScaledMetric(relativeTo: .title3) private var circle: CGFloat = 48

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: circle, height: circle)
                .background(color.opacity(0.14), in: Circle())
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .cardBackground(radius: 16)
        .contentShape(Rectangle())
    }
}

// MARK: - Section header

fileprivate struct SectionHeader: View {
    let title: String
    let action: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            Button(action) { }
                .font(.subheadline)
        }
        .padding(.bottom, -12)
    }
}

// MARK: - Rows

fileprivate struct IconBadge: View {
    let symbol: String
    let color: Color
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 36

    var body: some View {
        Image(systemName: symbol)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .accessibilityHidden(true)
    }
}

fileprivate struct CategoryRow: View {
    let category: BudgetCategory
    @Environment(\.dynamicTypeSize) private var typeSize

    private var statusText: String {
        category.isOver
            ? "\(abs(category.remaining).currency()) over"
            : "\(category.remaining.currency()) left"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(symbol: category.symbol, color: category.color)
            VStack(alignment: .leading, spacing: 8) {
                let title = Text(category.name).font(.body.weight(.medium))
                let amounts = Text("\(category.spent.currency(fraction: false)) / \(category.limit.currency(fraction: false))")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                if typeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 2) { title; amounts }
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        title
                        Spacer(minLength: 8)
                        amounts
                    }
                }
                ProgressView(value: category.progress)
                    .tint(category.isOver ? .red : category.color)
                Label {
                    Text(statusText)
                } icon: {
                    if category.isOver {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                }
                .labelStyle(.titleAndIcon)
                .font(.caption.weight(category.isOver ? .semibold : .regular))
                .foregroundStyle(category.isOver ? Color.red : Color.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(category.name)
        .accessibilityValue("\(category.spent.currency()) of \(category.limit.currency()) spent, \(statusText)")
    }
}

fileprivate struct TransactionRow: View {
    let tx: Transaction
    @Environment(\.dynamicTypeSize) private var typeSize

    private var dateText: String {
        if Calendar.current.isDateInToday(tx.date) {
            return "Today, " + tx.date.formatted(date: .omitted, time: .shortened)
        } else if Calendar.current.isDateInYesterday(tx.date) {
            return "Yesterday"
        }
        return tx.date.formatted(.dateTime.month(.abbreviated).day())
    }

    var body: some View {
        let amount = Text(tx.amount.currency(showSign: tx.amount > 0))
            .font(.body.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(tx.amount > 0 ? Color.green : Color.primary)
        let info = VStack(alignment: .leading, spacing: 2) {
            Text(tx.merchant)
                .font(.body.weight(.medium))
            Text("\(tx.category) · \(dateText)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }

        HStack(alignment: typeSize.isAccessibilitySize ? .top : .center, spacing: 12) {
            IconBadge(symbol: tx.symbol, color: tx.color)
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) { info; amount }
                Spacer(minLength: 0)
            } else {
                info
                Spacer(minLength: 8)
                amount
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(tx.merchant), \(tx.category)")
        .accessibilityValue("\(tx.amount > 0 ? "Received" : "Spent") \(abs(tx.amount).currency()), \(dateText)")
    }
}

// MARK: - Add sheet

fileprivate struct AddTransactionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var merchant = ""
    @State private var category = "Groceries"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Merchant", text: $merchant)
                }
                Section {
                    Picker("Category", selection: $category) {
                        ForEach(SampleData.categories) { c in
                            Label(c.name, systemImage: c.symbol).tag(c.name)
                        }
                    }
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                        .disabled(amount.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Helpers

fileprivate extension View {
    func cardBackground(radius: CGFloat = 18) -> some View {
        background(Color(.secondarySystemGroupedBackground),
                   in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

#Preview {
    S_home()
}
