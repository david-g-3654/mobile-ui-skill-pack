import SwiftUI

struct S_paywall: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: JournalPlan = .yearly
    @State private var showingPaywall = true
    @State private var notice: JournalNotice?
    @State private var legalPage: JournalLegalPage?

    init() {}

    var body: some View {
        NavigationStack {
            Group {
                if showingPaywall {
                    paywall
                } else {
                    freeJournal
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(QPalette.canvas, for: .navigationBar)
            .toolbar {
                if showingPaywall {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingPaywall = false
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.dsBody)
                                .frame(minWidth: QMetrics.minTap, minHeight: QMetrics.minTap)
                        }
                        .accessibilityLabel("Close paywall")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Restore purchases") { notice = .restore }
                            .font(.dsFootnote)
                            .frame(minHeight: QMetrics.minTap)
                    }
                }
            }
        }
        .tint(QPalette.ink)
        .sheet(item: $legalPage) { page in
            JournalLegalSheet(page: page)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(QRadius.xl)
        }
        .alert(item: $notice) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Got it")))
        }
    }

    private var paywall: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xxl) {
                VStack(alignment: .leading, spacing: QSpace.md) {
                    Label("Daymark Plus", systemImage: "book.closed")
                        .font(.dsFootnote.weight(.semibold))
                        .foregroundStyle(QPalette.ink2)

                    Text("Make room\nfor yourself.")
                        .font(.dsLargeTitle.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text("A little reflection today.\nA deeper understanding over time.")
                        .font(.dsBody)
                        .foregroundStyle(QPalette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: QSpace.sm) {
                    benefit("Space for every thought, without limits")
                    benefit("Gentle prompts when words feel far away")
                    benefit("Mood insights to see what lifts you")
                }

                VStack(alignment: .leading, spacing: QSpace.sm) {
                    Text("Choose your rhythm")
                        .font(.dsHeadline)
                        .accessibilityAddTraits(.isHeader)

                    (typeSize.isAccessibilitySize
                     ? AnyLayout(VStackLayout(spacing: QSpace.sm))
                     : AnyLayout(HStackLayout(alignment: .top, spacing: QSpace.sm))) {
                        ForEach(JournalPlan.allCases) { plan in
                            JournalPlanTile(plan: plan, isSelected: selectedPlan == plan) {
                                withAnimation(reduceMotion ? nil : QMotion.snappy) {
                                    selectedPlan = plan
                                }
                            }
                        }
                    }
                }

                QLargeTextFooter { legalFooter }
            }
            .frame(maxWidth: 600, alignment: .leading)
            .padding(.horizontal, QSpace.margin)
            .padding(.top, QSpace.xl)
            .padding(.bottom, QSpace.xl)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(QPalette.ink)
        .qCanvasBackground()
        .qBottomActionBar {
            Button("Subscribe \(selectedPlan.rawValue.lowercased())") {
                notice = .purchase
            }
            .buttonStyle(.qPrimary)
            .accessibilityHint("\(selectedPlan.price) per \(selectedPlan.period). No free trial.")
        } footer: {
            legalFooter
        }
        .sensoryFeedback(.selection, trigger: selectedPlan)
    }

    private func benefit(_ title: String) -> some View {
        Label {
            Text(title)
                .font(.dsBody)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "checkmark")
                .font(.dsBody)
                .foregroundStyle(QPalette.ink2)
                .accessibilityHidden(true)
        }
    }

    private var legalFooter: some View {
        VStack(spacing: QSpace.xxs) {
            Text("\(selectedPlan.price)/\(selectedPlan.period), billed \(selectedPlan.rawValue.lowercased()). No free trial.\nAuto-renews. Cancel anytime in Settings.")
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: QSpace.xl) {
                Button("Terms") { legalPage = .terms }
                Button("Privacy") { legalPage = .privacy }
            }
            .font(.dsFootnote)
            .frame(minHeight: QMetrics.minTap)
            .buttonStyle(.borderless)
        }
    }

    private var freeJournal: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xl) {
                Text("Your space, at your pace.")
                    .font(.dsTitle)
                Text("Today")
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
                Text("What is one small thing you want to remember about today?")
                    .font(.dsBody)
                Button("Explore Daymark Plus") { showingPaywall = true }
                    .buttonStyle(.qSecondary)
            }
            .padding(QSpace.margin)
        }
        .navigationTitle("Your journal")
        .qCanvasBackground()
    }
}

fileprivate enum JournalPlan: String, CaseIterable, Identifiable {
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: Self { self }
    var price: String { self == .yearly ? "$39.99" : "$5.99" }
    var period: String { self == .yearly ? "year" : "month" }
    var detail: String { self == .yearly ? "$3.33/month equivalent" : "Billed monthly" }
}

fileprivate struct JournalPlanTile: View {
    let plan: JournalPlan
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: QSpace.sm) {
                HStack(spacing: QSpace.xs) {
                    Text(plan.rawValue).font(.dsHeadline)
                    Spacer(minLength: 0)
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.dsBody)
                        .foregroundStyle(isSelected ? QPalette.accent : QPalette.ink2)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: QSpace.xxs) {
                    Text(plan.price)
                        .font(.dsTitle)
                        .monospacedDigit()
                    Text("per \(plan.period)")
                        .font(.dsFootnote)
                        .foregroundStyle(QPalette.ink2)
                }

                Text(plan.detail)
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(plan == .yearly ? "Save 44%" : "Pay as you go")
                    .font(.dsFootnote.weight(.semibold))
                    .foregroundStyle(plan == .yearly ? QPalette.accent : QPalette.ink2)
            }
            .foregroundStyle(QPalette.ink)
            .padding(QSpace.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: QRadius.l, style: .continuous)
                    .strokeBorder(isSelected ? QPalette.ink : (contrast == .increased ? QPalette.ink2 : QPalette.hairline), lineWidth: isSelected ? 2 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(plan.rawValue), \(plan.price) per \(plan.period), \(plan.detail)\(plan == .yearly ? ", save 44 percent" : "")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

fileprivate enum JournalNotice: String, Identifiable {
    case purchase, restore
    var id: Self { self }
    var title: String { self == .purchase ? "Subscription preview" : "Restore unavailable" }
    var message: String {
        self == .purchase
            ? "This preview isn't connected to the App Store. No payment was taken."
            : "This preview can't access App Store purchases. Your existing subscriptions haven't changed."
    }
}

fileprivate enum JournalLegalPage: String, Identifiable {
    case terms = "Terms"
    case privacy = "Privacy"
    var id: Self { self }
}

fileprivate struct JournalLegalSheet: View {
    let page: JournalLegalPage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.md) {
                    Text("Design preview")
                        .font(.dsTitle)
                    Text(page == .terms
                         ? "Sample plans are $5.99 per month or $39.99 per year, with no free trial. The selected plan renews automatically until canceled in Settings."
                         : "No journal entries or payment details are collected by this screen. This preview does not connect to a journaling service.")
                        .font(.dsBody)
                    Text("The published app must provide its full \(page == .terms ? "subscription terms" : "privacy policy") here before purchases are enabled.")
                        .font(.dsFootnote)
                        .foregroundStyle(QPalette.ink2)
                }
                .padding(QSpace.margin)
            }
            .qCanvasBackground()
            .navigationTitle(page.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(QPalette.ink)
    }
}

#Preview("Light") { S_paywall() }
#Preview("Dark") { S_paywall().preferredColorScheme(.dark) }
#Preview("Large text") { S_paywall().dynamicTypeSize(.accessibility2) }
