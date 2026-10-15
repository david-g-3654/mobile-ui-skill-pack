import SwiftUI

// MARK: - Models

fileprivate enum PlanKind: String, CaseIterable, Identifiable {
    case yearly, monthly
    var id: String { rawValue }
}

fileprivate struct Plan: Identifiable {
    let kind: PlanKind
    let title: String
    let price: Decimal
    let periodLabel: String
    let detail: String
    let badge: String?
    let trialDays: Int?
    var id: PlanKind { kind }

    func formatted(_ value: Decimal) -> String {
        value.formatted(.currency(code: "USD"))
    }
}

fileprivate struct Feature: Identifiable {
    let id = UUID()
    let symbol: String
    let tint: Color
    let title: String
    let subtitle: String
}

fileprivate struct Testimonial: Identifiable {
    let id = UUID()
    let quote: String
    let name: String
    let streak: String
}

fileprivate enum SampleData {
    static let plans: [Plan] = [
        Plan(kind: .yearly,
             title: "Yearly",
             price: 39.99,
             periodLabel: "/ year",
             detail: "Just $3.33 a month, billed annually",
             badge: "Save 44%",
             trialDays: 7),
        Plan(kind: .monthly,
             title: "Monthly",
             price: 5.99,
             periodLabel: "/ month",
             detail: "Billed monthly, cancel anytime",
             badge: nil,
             trialDays: nil)
    ]

    static let features: [Feature] = [
        Feature(symbol: "sparkles", tint: .orange,
                title: "Guided prompts",
                subtitle: "300+ reflections for mornings, evenings and hard days"),
        Feature(symbol: "chart.line.uptrend.xyaxis", tint: .teal,
                title: "Mood insights",
                subtitle: "See patterns in how you feel across weeks and months"),
        Feature(symbol: "lock.shield.fill", tint: .indigo,
                title: "Face ID lock & encrypted backup",
                subtitle: "Your entries stay private, on every device"),
        Feature(symbol: "photo.on.rectangle.angled", tint: .pink,
                title: "Unlimited photos & voice notes",
                subtitle: "Capture the moment, not just the words"),
        Feature(symbol: "doc.richtext", tint: .brown,
                title: "Export to PDF",
                subtitle: "Turn a year of entries into a keepsake book")
    ]

    static let testimonials: [Testimonial] = [
        Testimonial(quote: "The evening prompts helped me finally build a habit. I haven't missed a night since spring.",
                    name: "Maya R.", streak: "212-day streak"),
        Testimonial(quote: "Mood insights showed me Sundays were my hardest day. That alone was worth it.",
                    name: "Daniel K.", streak: "94-day streak"),
        Testimonial(quote: "Calm, private, and beautiful. It feels like a notebook I actually want to open.",
                    name: "Priya S.", streak: "158-day streak")
    ]
}

// MARK: - Theme

fileprivate enum Theme {
    static let accent = Color(red: 0.36, green: 0.30, blue: 0.78)
    static let warm = Color(red: 0.98, green: 0.62, blue: 0.38)
    static let paper = Color(red: 0.99, green: 0.97, blue: 0.94)
}

// MARK: - Screen

struct S_paywall: View {
    @State private var selected: PlanKind = .yearly
    @State private var isPurchasing = false
    @State private var showConfirmation = false
    @State private var showRestoreAlert = false
    @State private var dismissed = false
    @Environment(\.colorScheme) private var colorScheme

    init() {}

    private var selectedPlan: Plan {
        SampleData.plans.first { $0.kind == selected } ?? SampleData.plans[0]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            background

            ScrollView {
                VStack(spacing: 28) {
                    HeaderView()
                    FeatureList(features: SampleData.features)
                    VStack(spacing: 12) {
                        ForEach(SampleData.plans) { plan in
                            PlanCard(plan: plan, isSelected: plan.kind == selected) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selected = plan.kind
                                }
                            }
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Choose a plan")

                    TestimonialCarousel(items: SampleData.testimonials)
                    FinePrint(plan: selectedPlan) { showRestoreAlert = true }
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 180)
            }
            .scrollIndicators(.hidden)

            PurchaseBar(plan: selectedPlan, isPurchasing: isPurchasing) {
                purchase()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismissed = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(.thinMaterial, in: Circle())
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityLabel("Close")
        }
        .alert("Welcome to Daybook Plus", isPresented: $showConfirmation) {
            Button("Start writing") {}
        } message: {
            Text(selectedPlan.trialDays != nil
                 ? "Your 7-day free trial has started. We'll remind you 2 days before it ends."
                 : "Your \(selectedPlan.title.lowercased()) subscription is active.")
        }
        .alert("No purchases found", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't find an active subscription for this Apple ID.")
        }
        .alert("Maybe later", isPresented: $dismissed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can keep journaling for free. Upgrade anytime from Settings.")
        }
        .sensoryFeedback(.selection, trigger: selected)
        .sensoryFeedback(.success, trigger: showConfirmation) { _, new in new }
    }

    private var background: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(red: 0.10, green: 0.09, blue: 0.18), Color.black]
                : [Theme.paper, Color(red: 0.93, green: 0.92, blue: 0.99)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func purchase() {
        guard !isPurchasing else { return }
        isPurchasing = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            isPurchasing = false
            showConfirmation = true
        }
    }
}

// MARK: - Header

fileprivate struct HeaderView: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [Theme.warm, Theme.accent],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: Theme.accent.opacity(0.35), radius: 18, y: 8)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white)
                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(x: 30, y: -30)
                    .scaleEffect(animate ? 1.1 : 0.85)
                    .opacity(animate ? 1 : 0.6)
            }
            .accessibilityHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }

            Text("Daybook Plus")
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("Make reflection a daily ritual with guided prompts, insights and a journal that's truly yours.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill").font(.caption)
                }
                Text("4.8 · 23k ratings")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(Theme.warm)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rated 4.8 out of 5 from 23 thousand ratings")
        }
    }
}

// MARK: - Features

fileprivate struct FeatureList: View {
    let features: [Feature]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(features) { f in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: f.symbol)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(f.tint)
                        .frame(width: 36, height: 36)
                        .background(f.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(f.title).font(.subheadline.weight(.semibold))
                        Text(f.subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(18)
        .background(.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.primary.opacity(0.06))
        )
    }
}

// MARK: - Plan card

fileprivate struct PlanCard: View {
    let plan: Plan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Theme.accent : Color.secondary.opacity(0.4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle().fill(Theme.accent).frame(width: 14, height: 14)
                            .transition(.scale)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(plan.title).font(.headline)
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .textCase(.uppercase)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.warm, in: Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                    Text(plan.detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if let days = plan.trialDays {
                        Label("\(days)-day free trial", systemImage: "gift.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 0) {
                    Text(plan.formatted(plan.price))
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                    Text(plan.periodLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(isSelected ? Theme.accent : Color.primary.opacity(0.08),
                                  lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? Theme.accent.opacity(0.18) : .clear, radius: 12, y: 6)
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Testimonials

fileprivate struct TestimonialCarousel: View {
    let items: [Testimonial]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Loved by mindful writers")
                .font(.headline)
                .padding(.horizontal, 4)
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(items) { t in
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: "quote.opening")
                                .foregroundStyle(Theme.accent.opacity(0.6))
                                .accessibilityHidden(true)
                            Text(t.quote)
                                .font(.system(.subheadline, design: .serif))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                            HStack {
                                Text(t.name).font(.footnote.weight(.semibold))
                                Spacer()
                                Label(t.streak, systemImage: "flame.fill")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(Theme.warm)
                            }
                        }
                        .padding(16)
                        .frame(width: 260, height: 170, alignment: .topLeading)
                        .background(.background.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .accessibilityElement(children: .combine)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, 4, for: .scrollContent)
        }
    }
}

// MARK: - Fine print

fileprivate struct FinePrint: View {
    let plan: Plan
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(termsText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 18) {
                Button("Restore Purchases", action: onRestore)
                Link("Terms", destination: URL(string: "https://example.com/terms")!)
                Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.caption.weight(.medium))
            .tint(.secondary)
        }
    }

    private var termsText: String {
        let price = plan.formatted(plan.price)
        if let days = plan.trialDays {
            return "Free for \(days) days, then \(price) \(plan.periodLabel). Subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage in Settings > Apple ID."
        }
        return "\(price) \(plan.periodLabel). Subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage in Settings > Apple ID."
    }
}

// MARK: - Purchase bar

fileprivate struct PurchaseBar: View {
    let plan: Plan
    let isPurchasing: Bool
    let action: () -> Void

    private var ctaTitle: String {
        plan.trialDays != nil ? "Start 7-Day Free Trial" : "Subscribe for \(plan.formatted(plan.price))\(plan.periodLabel.replacingOccurrences(of: " ", with: ""))"
    }

    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                ZStack {
                    Text(ctaTitle)
                        .font(.headline)
                        .opacity(isPurchasing ? 0 : 1)
                    if isPurchasing {
                        ProgressView().tint(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(colors: [Theme.accent, Theme.accent.opacity(0.85)],
                                   startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .shadow(color: Theme.accent.opacity(0.35), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(isPurchasing)
            .accessibilityLabel(isPurchasing ? "Processing purchase" : ctaTitle)

            Text(plan.trialDays != nil ? "No charge today · Cancel anytime" : "Cancel anytime")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.2), value: plan.kind)
    }
}

#Preview {
    S_paywall()
}
