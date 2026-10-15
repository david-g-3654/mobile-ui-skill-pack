// Screen.swift — Paywall for "Margin", a journaling app (mobile-ui paywall archetype, Quiet skin).
// Job: choose a plan and start. Focal: serif headline + the pre-selected yearly card.
// Primary: one pinned CTA whose label states the deal. Cut: feature comparison table, testimonials.

import SwiftUI

// MARK: - Model

fileprivate enum MarginPlan: String, CaseIterable, Identifiable {
    case monthly, yearly
    var id: Self { self }

    var name: String { self == .monthly ? "Monthly" : "Yearly" }
    var price: Decimal { self == .monthly ? 5.99 : 39.99 }
    var periodShort: String { self == .monthly ? "/mo" : "/yr" }
    var periodLong: String { self == .monthly ? "month" : "year" }
    var trialDays: Int? { self == .yearly ? 7 : nil }

    static func money(_ value: Decimal) -> String {
        value.formatted(.currency(code: "USD"))
    }

    /// Yearly price expressed per month, for the secondary line.
    static var yearlyPerMonth: Decimal {
        var raw = MarginPlan.yearly.price / 12
        var rounded = Decimal()
        NSDecimalRound(&rounded, &raw, 2, .plain)
        return rounded
    }

    /// Savings of yearly vs. 12 monthly payments, rounded down to a whole percent.
    static var yearlySavingsPercent: Int {
        let twelveMonths = MarginPlan.monthly.price * 12
        let ratio = (twelveMonths - MarginPlan.yearly.price) / twelveMonths
        return Int(truncating: NSDecimalNumber(decimal: ratio * 100))
    }
}

fileprivate struct TrialStep: Identifiable {
    let id = UUID()
    let day: String
    let title: String
    let detail: String
    let systemImage: String
}

// MARK: - Screen

struct S_paywall: View {
    @State private var plan: MarginPlan = .yearly
    @State private var isPurchasing = false
    @State private var didSubscribe = false
    @Environment(\.dynamicTypeSize) private var typeSize

    init() {}

    private let benefits = [
        "Unlimited entries, photos and voice notes",
        "A fresh writing prompt every morning",
        "Find any entry by mood, place or person",
        "Your year in themes, every December",
    ]

    private var trialSteps: [TrialStep] {
        let price = MarginPlan.money(MarginPlan.yearly.price)
        return [
            TrialStep(day: "Today", title: "Everything unlocks",
                      detail: "Write as much as you like.", systemImage: "lock.open"),
            TrialStep(day: "Day 5", title: "We remind you",
                      detail: "A notification 2 days before billing.", systemImage: "bell"),
            TrialStep(day: "Day 7", title: "Your plan starts",
                      detail: "\(price) for the year, unless you cancel.", systemImage: "calendar"),
        ]
    }

    private var ctaTitle: String {
        if let days = plan.trialDays { return "Start \(days)-day free trial" }
        return "Subscribe for \(MarginPlan.money(plan.price))/\(plan.periodLong)"
    }

    private var terms: String {
        let price = MarginPlan.money(plan.price)
        if let days = plan.trialDays {
            return "\(days) days free, then \(price)/\(plan.periodLong). Renews automatically. Cancel anytime in Settings."
        }
        return "\(price)/\(plan.periodLong). Renews automatically. Cancel anytime in Settings."
    }

    @ViewBuilder private var legal: some View {
        Text(terms)
            .font(.dsFootnote)
            .foregroundStyle(QPalette.ink2)
            .multilineTextAlignment(.center)
            .contentTransition(.opacity)
        HStack(spacing: QSpace.md) {
            Link("Terms of Use", destination: URL(string: "https://margin.example/terms")!)
            Link("Privacy Policy", destination: URL(string: "https://margin.example/privacy")!)
        }
        .font(.dsFootnote.weight(.semibold))
        .foregroundStyle(QPalette.ink2)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xl) {
                    header
                    benefitList
                    planPicker
                    if plan == .yearly {
                        trialTimeline
                            .transition(.opacity)
                    }
                    QLargeTextFooter { legal }
                }
                .padding(.horizontal, QSpace.margin)
                .padding(.top, QSpace.xs)
                .padding(.bottom, QSpace.xl)
            }
            .qCanvasBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(QPalette.canvas, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Dismissed by the presenting flow.
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(QPalette.ink2)
                            .frame(width: QMetrics.minTap, height: QMetrics.minTap)
                    }
                    .accessibilityLabel("Close paywall")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Restore") {}
                        .foregroundStyle(QPalette.ink)
                        .accessibilityLabel("Restore purchases")
                }
            }
            .qBottomActionBar {
                QPrimaryButton(title: ctaTitle, isLoading: isPurchasing) {
                    purchase()
                }
            } footer: {
                legal
            }
            .sensoryFeedback(.success, trigger: didSubscribe)
            .sheet(isPresented: $didSubscribe) {
                SubscribedSheet(plan: plan)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(QRadius.xl)
            }
        }
        .tint(QPalette.ink)
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            Text("Margin Plus")
                .qOverlineStyle()
            Text("Keep every page.\nNotice what returns.")
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(QPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text("You've written 38 entries since March. Plus keeps them searchable and safe.")
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var benefitList: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            ForEach(benefits, id: \.self) { benefit in
                Label {
                    Text(benefit)
                        .font(.dsBody)
                        .foregroundStyle(QPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(QPalette.ink)
                }
            }
        }
    }

    private var planPicker: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: QSpace.sm))
            : AnyLayout(HStackLayout(alignment: .top, spacing: QSpace.sm))
        return layout {
            QPlanCard(
                name: MarginPlan.monthly.name,
                price: MarginPlan.money(MarginPlan.monthly.price),
                period: MarginPlan.monthly.periodShort,
                detail: "Billed monthly, no trial",
                isSelected: plan == .monthly
            ) { select(.monthly) }

            QPlanCard(
                name: MarginPlan.yearly.name,
                price: MarginPlan.money(MarginPlan.yearly.price),
                period: MarginPlan.yearly.periodShort,
                detail: "\(MarginPlan.money(MarginPlan.yearlyPerMonth))/mo, 7 days free",
                badge: "Save \(MarginPlan.yearlySavingsPercent)%",
                isSelected: plan == .yearly
            ) { select(.yearly) }
        }
    }

    private var trialTimeline: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            Text("How the trial works")
                .qOverlineStyle()
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(trialSteps.enumerated()), id: \.element.id) { index, step in
                    HStack(alignment: .top, spacing: QSpace.sm) {
                        VStack(spacing: QSpace.xxs) {
                            Image(systemName: step.systemImage)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(index == 0 ? QPalette.accent : QPalette.ink2)
                                .frame(width: QSpace.xxl, height: QSpace.xxl)
                                .background(index == 0 ? QPalette.accentSoft : QPalette.surface2, in: Circle())
                            if index < trialSteps.count - 1 {
                                Rectangle()
                                    .fill(QPalette.hairline)
                                    .frame(width: 2)
                                    .frame(minHeight: QSpace.md)
                            }
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: QSpace.xxs) {
                            Text("\(step.day) · \(step.title)")
                                .font(.dsHeadline)
                                .foregroundStyle(QPalette.ink)
                            Text(step.detail)
                                .font(.dsSubhead)
                                .foregroundStyle(QPalette.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, QSpace.xxs)
                        .padding(.bottom, QSpace.md)
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    // MARK: Actions

    private func select(_ newPlan: MarginPlan) {
        withAnimation(QMotion.snappy) { plan = newPlan }
    }

    private func purchase() {
        isPurchasing = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            isPurchasing = false
            didSubscribe = true
        }
    }
}

// MARK: - Success sheet

fileprivate struct SubscribedSheet: View {
    let plan: MarginPlan
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: QSpace.xl) {
            QEmptyState(
                title: "You're all set",
                message: plan.trialDays != nil
                    ? "Margin Plus is unlocked. We'll remind you 2 days before your trial ends."
                    : "Margin Plus is unlocked. Your next entry is waiting.",
                systemImage: "book.closed"
            ) {
                EmptyView()
            }
            Button("Start writing") { dismiss() }
                .buttonStyle(.qPrimary)
                .padding(.horizontal, QSpace.margin)
        }
        .padding(.vertical, QSpace.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(QPalette.canvas.ignoresSafeArea())
    }
}

#Preview("Light") { S_paywall() }
#Preview("Dark") { S_paywall().preferredColorScheme(.dark) }
#Preview("Large text") { S_paywall().dynamicTypeSize(.accessibility2) }
