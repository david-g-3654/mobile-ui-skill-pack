// Screen.swift — Paywall archetype (mobile-ui/references/screen-paywall.md), default "Quiet" skin.
// Job: pick a plan and start the trial. Focal: serif headline + pre-selected yearly plan.
// Primary: one pinned CTA whose label states the deal. Cut: feature comparison table, hero art.

import SwiftUI

// MARK: - Sample data

fileprivate struct JournalPlan: Identifiable, Equatable {
    let id: String
    let name: String
    let price: String
    let period: String
    let detail: String
    let badge: String?
    let trialDays: Int?
    let renewalPhrase: String

    static let monthly = JournalPlan(
        id: "monthly", name: "Monthly", price: "$6.99", period: "/mo",
        detail: "Billed monthly", badge: nil, trialDays: nil,
        renewalPhrase: "$6.99/month"
    )
    static let yearly = JournalPlan(
        id: "yearly", name: "Yearly", price: "$44.99", period: "/yr",
        detail: "$3.75/mo", badge: "Save 46%", trialDays: 7,
        renewalPhrase: "$44.99/year"
    )
    static let all: [JournalPlan] = [.monthly, .yearly]
}

fileprivate enum PaywallCopy {
    static let product = "Margin Plus"
    static let headline = "Write it down.\nSee the pattern."
    static let benefits = [
        "Unlimited journals, photos and voice notes",
        "Weekly insights on mood and sleep",
        "Sync across iPhone, iPad and Mac",
        "Lock private entries with Face ID",
    ]
}

fileprivate struct TrialStep: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let detail: String
}

// MARK: - Screen

struct S_paywall: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    @State private var selected: JournalPlan = .yearly
    @State private var isPurchasing = false
    @State private var purchaseCount = 0
    @State private var toastMessage: String?

    init() {}

    private var ctaTitle: String {
        if let days = selected.trialDays { return "Start \(days)-day free trial" }
        return "Subscribe for \(selected.renewalPhrase)"
    }

    private var terms: String {
        if let days = selected.trialDays {
            return "\(days) days free, then \(selected.renewalPhrase). Cancel anytime in Settings."
        }
        return "\(selected.renewalPhrase), renews automatically. Cancel anytime in Settings."
    }

    private var trialSteps: [TrialStep] {
        let cal = Calendar.current
        let today = Date.now
        let reminder = cal.date(byAdding: .day, value: 5, to: today) ?? today
        let billing = cal.date(byAdding: .day, value: 7, to: today) ?? today
        let fmt = Date.FormatStyle().month(.abbreviated).day()
        return [
            TrialStep(systemImage: "lock.open", title: "Today",
                      detail: "Every Plus feature unlocks. Nothing is charged."),
            TrialStep(systemImage: "bell", title: reminder.formatted(fmt),
                      detail: "We'll remind you 2 days before the trial ends."),
            TrialStep(systemImage: "creditcard", title: billing.formatted(fmt),
                      detail: "You're billed \(selected.renewalPhrase) unless you cancel."),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                header
                benefitList
                planPicker
                if selected.trialDays != nil {
                    trialTimeline
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, Space.margin)
            .padding(.top, Space.xxxl)
            .padding(.bottom, Space.xl)
        }
        .canvasBackground()
        .tint(Palette.ink)
        .overlay(alignment: .topLeading) { closeButton }
        .overlay(alignment: .topTrailing) {
            Button("Restore") { restore() }
                .buttonStyle(.tertiary)
                .padding(.trailing, Space.xs)
                .accessibilityLabel("Restore purchases")
        }
        .bottomActionBar { purchaseBar }
        .toast(toastMessage)
        .sensoryFeedback(.success, trigger: purchaseCount)
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(PaywallCopy.product).overlineStyle()
            Text(PaywallCopy.headline)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var benefitList: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            ForEach(PaywallCopy.benefits, id: \.self) { benefit in
                Label {
                    Text(benefit)
                        .font(.dsBody)
                        .foregroundStyle(Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Palette.accent)
                }
            }
        }
    }

    private var planPicker: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: Space.sm))
            : AnyLayout(HStackLayout(alignment: .top, spacing: Space.sm))
        return layout {
            ForEach(JournalPlan.all) { plan in
                PlanCard(
                    name: plan.name, price: plan.price, period: plan.period,
                    detail: plan.detail, badge: plan.badge,
                    isSelected: selected == plan
                ) {
                    withAnimation(Motion.snappy) { selected = plan }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Choose a plan")
    }

    private var trialTimeline: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text("How your trial works").font(.dsHeadline).foregroundStyle(Palette.ink)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(trialSteps.enumerated()), id: \.element.id) { index, step in
                    TimelineRow(step: step, isLast: index == trialSteps.count - 1)
                }
            }
        }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(Palette.ink2)
                .frame(width: Metrics.minTap, height: Metrics.minTap)
                .background(Palette.surface2, in: Circle())
        }
        .accessibilityLabel("Close paywall")
        .padding(.leading, Space.md)
    }

    @ViewBuilder private var purchaseBar: some View {
        PrimaryButton(title: ctaTitle, isLoading: isPurchasing) { purchase() }
            .contentTransition(.opacity)
        Text(terms)
            .font(.dsFootnote)
            .foregroundStyle(Palette.ink2)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        HStack(spacing: Space.md) {
            Link("Terms", destination: URL(string: "https://example.com/terms")!)
            Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
        }
        .font(.dsFootnote.weight(.semibold))
        .foregroundStyle(Palette.ink2)
    }

    // MARK: Actions (simulated StoreKit)

    private func purchase() {
        guard !isPurchasing else { return }
        isPurchasing = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            isPurchasing = false
            purchaseCount += 1
            if let days = selected.trialDays {
                showToast("Your \(days)-day trial has started")
            } else {
                showToast("Welcome to Margin Plus")
            }
        }
    }

    private func restore() {
        showToast("No past purchases found for this Apple ID")
    }

    private func showToast(_ message: String) {
        toastMessage = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if toastMessage == message { toastMessage = nil }
        }
    }
}

// MARK: - Trial timeline row

fileprivate struct TimelineRow: View {
    let step: TrialStep
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Space.sm) {
            VStack(spacing: Space.xxs) {
                Image(systemName: step.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.ink2)
                    .frame(width: 32, height: 32)
                    .background(Palette.surface2, in: Circle())
                    .accessibilityHidden(true)
                if !isLast {
                    Rectangle()
                        .fill(Palette.hairline)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title).font(.dsHeadline).foregroundStyle(Palette.ink)
                Text(step.detail)
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, Space.xxs)
            .padding(.bottom, isLast ? 0 : Space.md)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") { S_paywall() }
#Preview("Dark") { S_paywall().preferredColorScheme(.dark) }
#Preview("Large text") { S_paywall().dynamicTypeSize(.accessibility2) }
