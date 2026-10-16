import SwiftUI

struct S_home: View {
    @State private var expenses = HomeExpense.samples
    @State private var showingExpense = false
    @State private var showingActivity = false
    @State private var savedCount = 0
    @Environment(\.dynamicTypeSize) private var typeSize

    init() {}

    private var spent: Double { 1_913.58 + expenses.filter { $0.isNew }.reduce(0) { $0 + $1.amount } }
    private var remaining: Double { 3_200 - spent }
    private var grocerySpent: Double {
        311.60 + expenses.filter { $0.isNew && $0.category == "Groceries" }.reduce(0) { $0 + $1.amount }
    }
    private var groceryUsage: String { "\(Int(grocerySpent / 380 * 100))% used" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xxl) {
                    balance
                    groceryBudget
                    upcoming
                    activity
                }
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, QSpace.margin)
                .padding(.top, QSpace.xl)
                .padding(.bottom, QSpace.xl)
            }
            .qCanvasBackground()
            .navigationTitle("Overview")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("October 2026")
                        .font(.dsFootnote)
                        .foregroundStyle(QPalette.ink2)
                }
            }
            .qBottomActionBar {
                Button { showingExpense = true } label: {
                    Label("Add expense", systemImage: "plus")
                }
                .buttonStyle(.qPrimary)
            }
            .sheet(isPresented: $showingExpense) {
                HomeExpenseEditor { merchant, amount, category in
                    expenses.insert(HomeExpense(merchant: merchant, category: category,
                                                amount: amount, date: "Today", isNew: true), at: 0)
                    savedCount += 1
                }
                .presentationDetents([.large])
                .presentationCornerRadius(QRadius.xl)
            }
            .navigationDestination(isPresented: $showingActivity) {
                HomeActivity(expenses: expenses)
            }
            .sensoryFeedback(.success, trigger: savedCount)
        }
        .tint(QPalette.ink)
    }

    private var balance: some View {
        VStack(alignment: .leading, spacing: QSpace.xl) {
            VStack(alignment: .leading, spacing: QSpace.xs) {
                Text("Left to spend")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                QHeroText(text: HomeMoney.string(remaining))
                    .contentTransition(.numericText())
                    .accessibilityLabel("Left to spend, \(HomeMoney.string(remaining))")
                Text("15 days left in your monthly plan")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
            }

            VStack(spacing: QSpace.sm) {
                ProgressView(value: min(max(spent / 3_200, 0), 1))
                    .tint(QPalette.accent)
                    .accessibilityLabel("Monthly budget spent")
                    .accessibilityValue("\(Int(spent / 3_200 * 100)) percent")
                (typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.sm)) : AnyLayout(HStackLayout(alignment: .top))) {
                    metric("Monthly budget", amount: 3_200)
                    if !typeSize.isAccessibilitySize { Spacer() }
                    metric("Spent so far", amount: spent)
                }
            }
        }
    }

    private func metric(_ title: String, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: QSpace.xxs) {
            Text(HomeMoney.string(amount))
                .font(.dsHeadline)
                .monospacedDigit()
                .foregroundStyle(QPalette.ink)
            Text(title)
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
        }
        .accessibilityElement(children: .combine)
    }

    private var groceryBudget: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            sectionTitle("Worth a look")
            VStack(alignment: .leading, spacing: QSpace.xs) {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Text("Groceries").font(.dsHeadline)
                        Spacer(minLength: QSpace.sm)
                        Text(groceryUsage).font(.dsSubhead).foregroundStyle(QPalette.accent)
                    }
                    VStack(alignment: .leading, spacing: QSpace.xxs) {
                        Text("Groceries").font(.dsHeadline)
                        Text(groceryUsage).font(.dsSubhead).foregroundStyle(QPalette.accent)
                    }
                }
                Text(grocerySpent <= 380
                     ? "\(HomeMoney.string(380 - grocerySpent)) left of \(HomeMoney.string(380))"
                     : "\(HomeMoney.string(grocerySpent - 380)) over your \(HomeMoney.string(380)) budget")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
            }
            .padding(QSpace.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
        }
    }

    private var upcoming: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            sectionTitle("Coming up")
            HomeAmountRow(title: "Internet", detail: "Oct 18 · Automatic payment", amount: 64.99)
                .padding(.vertical, QSpace.xxs)
            Divider().overlay(QPalette.hairline)
        }
    }

    private var activity: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            HStack {
                sectionTitle("Recent activity")
                Spacer()
                Button("See all") { showingActivity = true }
                    .buttonStyle(.qTertiary)
            }
            if expenses.isEmpty {
                Text("Your expenses will appear here. Add your first one below.")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(expenses.prefix(3).enumerated()), id: \.element.id) { index, expense in
                        HomeAmountRow(title: expense.merchant,
                                      detail: "\(expense.category) · \(expense.date)", amount: expense.amount)
                            .padding(QSpace.md)
                        if index < min(expenses.count, 3) - 1 {
                            Divider().overlay(QPalette.hairline).padding(.horizontal, QSpace.md)
                        }
                    }
                }
                .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.dsHeadline)
            .foregroundStyle(QPalette.ink)
            .accessibilityAddTraits(.isHeader)
    }
}

fileprivate enum HomeMoney {
    static func string(_ amount: Double) -> String {
        amount.formatted(.currency(code: "USD").locale(Locale(identifier: "en_US")))
    }
}

fileprivate struct HomeExpense: Identifiable {
    let id = UUID()
    let merchant: String
    let category: String
    let amount: Double
    let date: String
    var isNew = false

    static let samples = [
        HomeExpense(merchant: "Trader Joe’s", category: "Groceries", amount: 54.28, date: "Today"),
        HomeExpense(merchant: "Blue Bottle Coffee", category: "Dining", amount: 6.75, date: "Today"),
        HomeExpense(merchant: "San Francisco Municipal Railway", category: "Transport", amount: 2.50, date: "Yesterday"),
        HomeExpense(merchant: "City Lights Booksellers", category: "Shopping", amount: 24.95, date: "Oct 14"),
        HomeExpense(merchant: "October rent", category: "Home", amount: 1_450, date: "Oct 1")
    ]
}

fileprivate struct HomeAmountRow: View {
    let title: String
    let detail: String
    let amount: Double
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        (typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.xs)) : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: QSpace.sm))) {
            VStack(alignment: .leading, spacing: QSpace.xxs) {
                Text(title).font(.dsSubhead).foregroundStyle(QPalette.ink)
                Text(detail).font(.dsFootnote).foregroundStyle(QPalette.ink2)
            }
            if !typeSize.isAccessibilitySize { Spacer(minLength: QSpace.xs) }
            Text(HomeMoney.string(-amount))
                .font(.dsSubhead)
                .monospacedDigit()
                .foregroundStyle(QPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct HomeActivity: View {
    let expenses: [HomeExpense]

    var body: some View {
        List {
            Section {
                ForEach(expenses) { expense in
                    HomeAmountRow(title: expense.merchant, detail: "\(expense.category) · \(expense.date)", amount: expense.amount)
                        .listRowBackground(QPalette.surface)
                }
            } header: {
                Text("October expenses")
            }
        }
        .listStyle(.insetGrouped)
        .qCanvasBackground()
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct HomeExpenseEditor: View {
    let onSave: (String, Double, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var merchant = ""
    @State private var amount = ""
    @State private var category = "Dining"
    @State private var error: String?
    @FocusState private var focusedField: Field?

    fileprivate enum Field: Hashable { case merchant, amount }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: QSpace.xs) {
                        Text("Merchant").font(.dsSubhead).foregroundStyle(QPalette.ink2)
                        TextField("e.g. Whole Foods Market", text: $merchant)
                            .focused($focusedField, equals: .merchant)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .amount }
                    }
                    .padding(.vertical, QSpace.xs)
                    .listRowBackground(QPalette.surface)
                    VStack(alignment: .leading, spacing: QSpace.xs) {
                        Text("Amount · USD").font(.dsSubhead).foregroundStyle(QPalette.ink2)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .amount)
                    }
                    .padding(.vertical, QSpace.xs)
                    .listRowBackground(QPalette.surface)
                    Picker("Category", selection: $category) {
                        ForEach(["Dining", "Groceries", "Transport", "Shopping", "Home", "Other"], id: \.self) {
                            Text($0)
                        }
                    }
                    .listRowBackground(QPalette.surface)
                } footer: {
                    Text("Saved to your October budget on this device for this session.")
                }
                if let error {
                    Text(error).font(.dsSubhead).foregroundStyle(QPalette.negative)
                        .listRowBackground(QPalette.surface)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .qCanvasBackground()
            .navigationTitle("Add expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .qBottomActionBar {
                Button("Save expense", action: save).buttonStyle(.qPrimary)
            }
        }
        .tint(QPalette.ink)
    }

    private func save() {
        let cleanedMerchant = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedMerchant.isEmpty else {
            error = "Enter a merchant so you can recognize this expense."
            focusedField = .merchant
            return
        }
        guard let value = Double(amount), value.isFinite, value >= 0.01, value <= 999_999.99 else {
            error = "Enter an amount between 0.01 and 999,999.99."
            focusedField = .amount
            return
        }
        onSave(cleanedMerchant, (value * 100).rounded() / 100, category)
        dismiss()
    }
}

#Preview("Light") {
    S_home().preferredColorScheme(.light)
}

#Preview("Dark") {
    S_home().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_home().dynamicTypeSize(.accessibility2)
}
