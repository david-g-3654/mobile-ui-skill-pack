// Screen.swift — Paywall for "Margins", a journaling app.
// Archetype: Paywall. Job: pick a plan and start writing without limits.
// Focal: serif headline + the pre-selected yearly plan. Primary: pinned CTA that states the deal.
// Cut: feature comparison table (behind "Compare free and Plus"), testimonials, countdown timers.

import SwiftUI

// MARK: - Sample data

fileprivate enum JournalPlan: String, CaseIterable, Identifiable {
    case monthly, yearly
    var id: Self { self }

    var name: String { self == .monthly ? "Monthly" : "Yearly" }
    var price: String { self == .monthly ? "$5.99" : "$39.99" }
    var period: String { self == .monthly ? "/mo" : "/yr" }
    var detail: String { self == .monthly ? "Billed every month" : "$3.33/mo, billed yearly" }
    var badge: String? { self == .yearly ? "Save 44%" : nil }
    var hasTrial: Bool { self == .yearly }

    var ctaTitle: String {
        hasTrial ? "Try Plus free for 7 days" : "Subscribe for $5.99/month"
    }

    var terms: String {
        hasTrial
            ? "Free until Oct 21, then $39.99/year. Cancel anytime in Settings."
            : "$5.99/month, renews monthly. Cancel anytime in Settings."
    }
}

fileprivate struct TrialStep: Identifiable {
    let id = UUID()
    let when: String
    let what: String
}

fileprivate enum PaywallContent {
    static let eyebrow = "Margins Plus"
    static let headline = "Your journal is\nout of free pages."
    static let context = "You've written 50 entries since June. Keep going without a cap."

    static let benefits = [
        "Unlimited entries, journals and photos",
        "A monthly look-back at what you wrote about",
        "Voice notes transcribed into your entries",
        "End-to-end encrypted sync on every device",
    ]

    static let trial = [
        TrialStep(when: "Today", what: "Every Plus feature unlocks"),
        TrialStep(when: "Oct 19", what: "We remind you two days before billing"),
        TrialStep(when: "Oct 21", what: "Billed $39.99 unless you cancel"),
    ]
}

// MARK: - Screen

struct S_paywall: View {
    init() {}

    var body: some View {
        NavigationStack {
            PaywallView()
        }
        .tint(Palette.ink)
    }
}

fileprivate struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var plan: JournalPlan = .yearly
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var toastMessage: String?
    @State private var purchaseSucceeded = false
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xxl) {
                header
                benefitList
                planPicker
                if plan.hasTrial {
                    TrialTimeline(steps: PaywallContent.trial)
                        .transition(.opacity)
                }
                Button("Compare free and Plus") {}
                    .buttonStyle(.tertiary)
                    .padding(.leading, -Space.xs)

                // At accessibility sizes the bar pins only the button; terms move here.
                LargeTextFooter { legal }
            }
            .padding(.horizontal, Space.margin)
            .padding(.top, Space.xs)
            .padding(.bottom, Space.xl)
        }
        .canvasBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Palette.canvas, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Palette.ink2)
                        .frame(width: Metrics.minTap, height: Metrics.minTap)
                }
                .accessibilityLabel("Close paywall")
            }
            ToolbarItem(placement: .primaryAction) {
                Button(isRestoring ? "Restoring…" : "Restore") { restore() }
                    .buttonStyle(.tertiary)
                    .disabled(isRestoring || isPurchasing)
            }
        }
        .bottomActionBar {
            PrimaryButton(title: purchaseSucceeded ? "You're on Plus" : plan.ctaTitle,
                          isLoading: isPurchasing) {
                purchase()
            }
            .disabled(purchaseSucceeded)
            .contentTransition(.opacity)
        } footer: {
            legal
        }
        .toast(toastMessage)
        .sensoryFeedback(.success, trigger: purchaseSucceeded)
        .alert("Purchase didn't go through", isPresented: $showError) {
            Button("Try again") { purchase() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The App Store couldn't be reached. You haven't been charged.")
        }
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text(PaywallContent.eyebrow).overlineStyle()
            Text(PaywallContent.headline)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(PaywallContent.context)
                .font(.dsBody)
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var benefitList: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            ForEach(PaywallContent.benefits, id: \.self) { benefit in
                Label {
                    Text(benefit).font(.dsBody).foregroundStyle(Palette.ink)
                } icon: {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Palette.accent)
                }
            }
        }
    }

    @ViewBuilder private var planPicker: some View {
        let cards = ForEach(JournalPlan.allCases.reversed()) { option in
            PlanCard(name: option.name, price: option.price, period: option.period,
                     detail: option.detail, badge: option.badge, isSelected: plan == option) {
                withAnimation(Motion.snappy) { plan = option }
            }
        }
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: Space.sm) { cards }
            VStack(spacing: Space.sm) { cards }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Choose a plan")
    }

    /// Plain-language terms + links: pinned under the CTA, or in the scroll content at large sizes.
    @ViewBuilder private var legal: some View {
        Text(plan.terms)
            .font(.dsFootnote)
            .foregroundStyle(Palette.ink2)
            .multilineTextAlignment(.center)
            .contentTransition(.opacity)
        HStack(spacing: Space.md) {
            Link("Terms", destination: URL(string: "https://margins.app/terms")!)
            Link("Privacy", destination: URL(string: "https://margins.app/privacy")!)
        }
        .font(.dsFootnote.weight(.semibold))
        .foregroundStyle(Palette.ink2)
    }

    // MARK: Actions (simulated StoreKit)

    private func purchase() {
        isPurchasing = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            isPurchasing = false
            purchaseSucceeded = true
            showToast(plan.hasTrial ? "Trial started. Write as much as you like." : "Welcome to Margins Plus")
        }
    }

    private func restore() {
        isRestoring = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            isRestoring = false
            showToast("No earlier purchase found for this Apple ID")
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            if toastMessage == message { toastMessage = nil }
        }
    }
}

// MARK: - Trial timeline

fileprivate struct TrialTimeline: View {
    let steps: [TrialStep]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text("How the trial works").overlineStyle()
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    HStack(alignment: .top, spacing: Space.sm) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(index == 0 ? Palette.ink : Palette.surface2)
                                .overlay { Circle().strokeBorder(Palette.hairline, lineWidth: 1) }
                                .frame(width: Space.sm, height: Space.sm)
                                .padding(.top, Space.xxs)
                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(Palette.hairline)
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: Space.sm)
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.when).font(.dsHeadline).foregroundStyle(Palette.ink)
                            Text(step.what).font(.dsSubhead).foregroundStyle(Palette.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.bottom, index < steps.count - 1 ? Space.md : 0)
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }
}

#Preview("Light") { S_paywall() }
#Preview("Dark") { S_paywall().preferredColorScheme(.dark) }
#Preview("Large text") { S_paywall().dynamicTypeSize(.accessibility2) }
