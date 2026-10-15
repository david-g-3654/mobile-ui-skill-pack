import SwiftUI

// MARK: - Sample data

fileprivate enum PlanID: String, CaseIterable, Identifiable {
    case yearly, monthly
    var id: String { rawValue }
}

fileprivate struct Plan: Identifiable {
    let id: PlanID
    let title: String
    let price: String
    let period: String
    let detail: String
    let badge: String?
    let trial: String?
}

fileprivate struct Feature: Identifiable {
    let id = UUID()
    let symbol: String
    let tint: Color
    let title: String
    let subtitle: String
}

fileprivate struct Review: Identifiable {
    let id = UUID()
    let quote: String
    let author: String
}

fileprivate enum SampleData {
    static let plans: [Plan] = [
        Plan(id: .yearly,
             title: "Yearly",
             price: "$39.99",
             period: "year",
             detail: "Just $3.33/month, billed annually",
             badge: "Save 44%",
             trial: "7-day free trial"),
        Plan(id: .monthly,
             title: "Monthly",
             price: "$5.99",
             period: "month",
             detail: "Billed monthly, cancel anytime",
             badge: nil,
             trial: nil)
    ]

    static let features: [Feature] = [
        Feature(symbol: "sparkles", tint: .orange,
                title: "Guided prompts",
                subtitle: "Over 400 reflective prompts that adapt to your mood."),
        Feature(symbol: "lock.fill", tint: .blue,
                title: "Private & encrypted",
                subtitle: "Face ID lock and end-to-end encrypted iCloud sync."),
        Feature(symbol: "chart.line.uptrend.xyaxis", tint: .green,
                title: "Mood insights",
                subtitle: "See patterns in your energy, sleep and gratitude."),
        Feature(symbol: "photo.on.rectangle.angled", tint: .pink,
                title: "Unlimited media",
                subtitle: "Add photos, audio notes and places to every entry."),
        Feature(symbol: "square.and.arrow.up", tint: .purple,
                title: "Export to PDF",
                subtitle: "Beautiful printable books of your year.")
    ]

    static let review = Review(
        quote: "I’ve kept a journal for 312 days straight. The prompts make it feel effortless.",
        author: "Maya R., journaling since 2024"
    )
}

// MARK: - Screen

struct S_paywall: View {
    @State private var selected: PlanID = .yearly
    @State private var isPurchasing = false
    @State private var showConfirmation = false
    @State private var showRestoreAlert = false
    @Environment(\.dynamicTypeSize) private var typeSize

    init() {}

    private var selectedPlan: Plan {
        SampleData.plans.first { $0.id == selected } ?? SampleData.plans[0]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    PaywallHeader()
                    FeatureList(features: SampleData.features)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose your plan")
                            .font(.title3.weight(.semibold))
                            .accessibilityAddTraits(.isHeader)
                        ForEach(SampleData.plans) { plan in
                            PlanCard(plan: plan, isSelected: plan.id == selected) {
                                withAnimation(.snappy) { selected = plan.id }
                            }
                        }
                    }
                    ReviewCard(review: SampleData.review)
                    LegalFooter(onRestore: { showRestoreAlert = true })
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(BackgroundGradient().ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                PurchaseBar(plan: selectedPlan, isPurchasing: isPurchasing) {
                    purchase()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(.thinMaterial, in: Circle())
                    }
                    .accessibilityLabel("Close")
                }
            }
            .alert("Welcome to Reverie Plus", isPresented: $showConfirmation) {
                Button("Start Writing") {}
            } message: {
                Text("Your \(selectedPlan.title.lowercased()) subscription is active. Enjoy every feature.")
            }
            .alert("No purchases found", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("We couldn’t find a previous subscription for this Apple Account.")
            }
        }
    }

    private func purchase() {
        isPurchasing = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            isPurchasing = false
            showConfirmation = true
        }
    }
}

// MARK: - Components

fileprivate struct BackgroundGradient: View {
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        LinearGradient(
            colors: scheme == .dark
                ? [Color.indigo.opacity(0.35), Color(.systemBackground)]
                : [Color.orange.opacity(0.18), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .center
        )
        .background(Color(.systemBackground))
    }
}

fileprivate struct PaywallHeader: View {
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 84

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: iconSize * 0.26, style: .continuous)
                    .fill(LinearGradient(colors: [.orange, .pink],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .frame(width: iconSize, height: iconSize)
                    .shadow(color: .pink.opacity(0.3), radius: 16, y: 8)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: iconSize * 0.46, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            Text("Reverie Plus")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("Build a writing habit that sticks, with tools designed for reflection.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 8)
    }
}

fileprivate struct FeatureList: View {
    let features: [Feature]
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(features) { feature in
                FeatureRow(feature: feature)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground).opacity(0.9),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

fileprivate struct FeatureRow: View {
    let feature: Feature
    @ScaledMetric(relativeTo: .body) private var iconBox: CGFloat = 36
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 14))
        layout {
            Image(systemName: feature.symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(feature.tint)
                .frame(width: iconBox, height: iconBox)
                .background(feature.tint.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.headline)
                Text(feature.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct PlanCard: View {
    let plan: Plan
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityHidden(true)

                let layout = typeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
                    : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 8))

                layout {
                    VStack(alignment: .leading, spacing: 4) {
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 8) { titleText; badgeView }
                            VStack(alignment: .leading, spacing: 4) { titleText; badgeView }
                        }
                        Text(plan.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        if let trial = plan.trial {
                            Label(trial, systemImage: "gift.fill")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.green)
                        }
                    }
                    if !typeSize.isAccessibilitySize { Spacer(minLength: 0) }
                    VStack(alignment: typeSize.isAccessibilitySize ? .leading : .trailing, spacing: 0) {
                        Text(plan.price)
                            .font(.title3.weight(.bold))
                            .monospacedDigit()
                        Text("per \(plan.period)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(isSelected ? Color.accentColor : Color(.separator),
                                  lineWidth: isSelected ? 2 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var titleText: some View {
        Text(plan.title).font(.headline)
    }

    @ViewBuilder private var badgeView: some View {
        if let badge = plan.badge {
            Text(badge)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .foregroundStyle(.white)
                .background(Color.orange, in: Capsule())
        }
    }

    private var accessibilityText: String {
        var parts = ["\(plan.title) plan", "\(plan.price) per \(plan.period)", plan.detail]
        if let badge = plan.badge { parts.append(badge) }
        if let trial = plan.trial { parts.append(trial) }
        return parts.joined(separator: ", ")
    }
}

fileprivate struct ReviewCard: View {
    let review: Review
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                }
            }
            .font(.footnote)
            .foregroundStyle(.yellow)
            .accessibilityLabel("5 out of 5 stars")

            Text("“\(review.quote)”")
                .font(.callout)
                .italic()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(review.author)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("4.8 average from 12,400 ratings")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground).opacity(0.9),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct LegalFooter: View {
    let onRestore: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) { links }
                VStack(spacing: 8) { links }
            }
            .font(.footnote)

            Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder private var links: some View {
        Button("Restore Purchases", action: onRestore)
        Button("Terms of Use") {}
        Button("Privacy Policy") {}
    }
}

fileprivate struct PurchaseBar: View {
    let plan: Plan
    let isPurchasing: Bool
    let action: () -> Void

    private var ctaTitle: String {
        plan.trial != nil ? "Start Free Trial" : "Subscribe for \(plan.price)/\(plan.period)"
    }

    private var caption: String {
        if plan.trial != nil {
            return "7 days free, then \(plan.price)/\(plan.period). Cancel anytime."
        }
        return "Renews monthly. Cancel anytime."
    }

    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                ZStack {
                    Text(ctaTitle)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .opacity(isPurchasing ? 0 : 1)
                    if isPurchasing {
                        ProgressView().tint(.white)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 30)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 14))
            .controlSize(.large)
            .disabled(isPurchasing)
            .accessibilityHint(caption)

            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.opacity)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
        .animation(.snappy, value: plan.id)
    }
}

#Preview {
    S_paywall()
}
