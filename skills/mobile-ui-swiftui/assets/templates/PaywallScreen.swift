// PaywallScreen.swift — Paywall archetype (mobile-ui/references/screen-paywall.md).
// Close visible from frame one. Recommended plan pre-selected. CTA states the deal. Terms beside CTA.
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import SwiftUI

struct PaywallScreen: View {
    enum Plan: String, CaseIterable, Identifiable {
        case monthly, yearly
        var id: Self { self }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var plan: Plan = .yearly
    @State private var isPurchasing = false

    private let benefits = [
        "Unlimited journals and entries",
        "Weekly insights on your mood patterns",
        "Sync across iPhone, iPad and Mac",
        "Lock sensitive entries with Face ID",
    ]

    private var ctaTitle: String {
        plan == .yearly ? "Start 7-day free trial" : "Subscribe for $7.99/month"
    }

    private var terms: String {
        plan == .yearly
            ? "7 days free, then $49.99/year. Cancel anytime in Settings."
            : "$7.99/month. Cancel anytime in Settings."
    }

    /// Plain-language terms + links. Pinned under the CTA, or in the scroll content at large text sizes.
    @ViewBuilder private var legal: some View {
        Text(terms)
            .font(.dsFootnote)
            .foregroundStyle(QPalette.ink2)
            .multilineTextAlignment(.center)
        HStack(spacing: QSpace.md) {
            Link("Terms", destination: URL(string: "https://example.com/terms")!)
            Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
        }
        .font(.dsFootnote.weight(.semibold))
        .foregroundStyle(QPalette.ink2)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xl) {
                Text("Write it down.\nSee the pattern.")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(QPalette.ink)
                    .padding(.top, QSpace.xxxl)

                VStack(alignment: .leading, spacing: QSpace.sm) {
                    ForEach(benefits, id: \.self) { benefit in
                        Label {
                            Text(benefit).font(.dsBody).foregroundStyle(QPalette.ink)
                        } icon: {
                            Image(systemName: "checkmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(QPalette.accent)
                        }
                    }
                }

                HStack(spacing: QSpace.sm) {
                    QPlanCard(name: "Monthly", price: "$7.99", period: "/mo",
                             detail: "Billed monthly", isSelected: plan == .monthly) {
                        withAnimation(QMotion.snappy) { plan = .monthly }
                    }
                    QPlanCard(name: "Yearly", price: "$49.99", period: "/yr",
                             detail: "$4.17/mo", badge: "Save 48%", isSelected: plan == .yearly) {
                        withAnimation(QMotion.snappy) { plan = .yearly }
                    }
                }

                // At accessibility sizes the bar pins only the button; the terms move here.
                QLargeTextFooter { legal }
            }
            .padding(.horizontal, QSpace.margin)
            .padding(.bottom, QSpace.xl)
        }
        .qCanvasBackground()
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(QPalette.ink2)
                    .frame(width: QMetrics.minTap, height: QMetrics.minTap)
                    .background(QPalette.surface2, in: Circle())
            }
            .accessibilityLabel("Close")
            .padding(.leading, QSpace.md)
        }
        .overlay(alignment: .topTrailing) {
            Button("Restore") {}
                .buttonStyle(.qTertiary)
                .padding(.trailing, QSpace.sm)
        }
        .qBottomActionBar {
            QPrimaryButton(title: ctaTitle, isLoading: isPurchasing) {
                isPurchasing = true
            }
        } footer: {
            legal
        }
        .sensoryFeedback(.success, trigger: isPurchasing)
    }
}

#Preview("Light") { PaywallScreen() }
#Preview("Dark") { PaywallScreen().preferredColorScheme(.dark) }
#Preview("Large text") { PaywallScreen().dynamicTypeSize(.accessibility2) }
