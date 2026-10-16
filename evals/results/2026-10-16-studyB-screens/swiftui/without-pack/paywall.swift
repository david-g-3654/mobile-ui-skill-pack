import SwiftUI

struct S_paywall: View {
    private var planStorage = State<JournalPlan>(initialValue: .yearly)
    private var confirmationStorage = State<Bool>(initialValue: false)
    private var restoreStorage = State<Bool>(initialValue: false)
    private var termsStorage = State<Bool>(initialValue: false)

    private var selectedPlan: JournalPlan {
        get { planStorage.wrappedValue }
        nonmutating set { planStorage.wrappedValue = newValue }
    }

    private var showingConfirmation: Bool {
        get { confirmationStorage.wrappedValue }
        nonmutating set { confirmationStorage.wrappedValue = newValue }
    }

    private var showingRestore: Bool {
        get { restoreStorage.wrappedValue }
        nonmutating set { restoreStorage.wrappedValue = newValue }
    }

    private var showingTerms: Bool {
        get { termsStorage.wrappedValue }
        nonmutating set { termsStorage.wrappedValue = newValue }
    }

    init() {}

    private let ink = Color(red: 0.17, green: 0.25, blue: 0.21)
    private let paper = Color(red: 0.97, green: 0.96, blue: 0.92)

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    illustration
                        .padding(.top, 12)
                    introduction
                        .padding(.top, 21)
                    benefits
                        .padding(.top, 25)
                    plans
                        .padding(.top, 29)
                    purchaseArea
                        .padding(.top, 20)
                    footer
                        .padding(.top, 19)
                        .padding(.bottom, 14)
                }
                .padding(.horizontal, 26)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .background(paper.ignoresSafeArea())
        }
        .foregroundStyle(ink)
        .alert("Your next chapter awaits", isPresented: confirmationStorage.projectedValue) {
            Button("Keep exploring", role: .cancel) {}
        } message: {
            Text("You selected \(selectedPlan.title.lowercased()) membership at \(selectedPlan.price). This preview does not process purchases.")
        }
        .alert("Restore purchases", isPresented: restoreStorage.projectedValue) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("No existing membership was found in this preview. In the full app, purchases are restored using your Apple Account.")
        }
        .sheet(isPresented: termsStorage.projectedValue) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("A little clarity").font(.system(.title, design: .serif))
                        Text("Membership is billed monthly or yearly, depending on your selection. Payment is charged to your Apple Account when you confirm your purchase. Your subscription renews automatically unless canceled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings.")
                        Text("Your words stay yours").font(.headline)
                        Text("Your journal is personal. This sample screen does not collect journal entries or process payments.")
                    }
                    .padding(26)
                }
                .background(paper)
                .navigationTitle("Membership details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingTerms = false } } }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "leaf")
                    .font(.system(size: 18, weight: .medium))
                Text("still").font(.system(size: 27, weight: .medium, design: .serif))
            }
            Spacer()
            Text("MEMBERSHIP")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(2.2)
                .foregroundStyle(ink.opacity(0.55))
        }
        .padding(.top, 13)
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.89, green: 0.89, blue: 0.81))
                .frame(width: 175, height: 175)
            Circle()
                .stroke(ink.opacity(0.1), lineWidth: 1)
                .frame(width: 203, height: 203)
            Image(systemName: "sparkle")
                .font(.system(size: 20, weight: .light))
                .offset(x: -100, y: -43)
            Image(systemName: "sparkle")
                .font(.system(size: 13, weight: .light))
                .offset(x: 100, y: 45)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.48, green: 0.55, blue: 0.40))
                .frame(width: 112, height: 145)
                .rotationEffect(.degrees(13))
                .offset(x: 19, y: 0)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(ink)
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 7)
                    .padding(.leading, 9)
                VStack(spacing: 11) {
                    Image(systemName: "sun.max")
                        .font(.system(size: 29, weight: .ultraLight))
                    Text("THE DAILY\nBECOMING")
                        .font(.system(size: 9, weight: .medium, design: .serif))
                        .tracking(1.8)
                        .multilineTextAlignment(.center)
                    Rectangle().frame(width: 22, height: 1).opacity(0.5)
                }
                .foregroundStyle(Color(red: 0.88, green: 0.85, blue: 0.65))
                .frame(maxWidth: .infinity)
            }
            .frame(width: 111, height: 146)
            .rotationEffect(.degrees(-10))
            .shadow(color: ink.opacity(0.18), radius: 12, x: 1, y: 10)
            .offset(x: -12, y: 3)
        }
        .frame(height: 211)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private var introduction: some View {
        VStack(spacing: 11) {
            Text("A little space.\nA deeper connection.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .tracking(-1.1)
                .lineSpacing(0)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text("Make room for every version of you.\nUnlock your full journaling journey with Still Plus.")
                .font(.system(size: 14))
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .foregroundStyle(ink.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 15) {
            benefit("book.closed", title: "Every thought, a place", detail: "Unlimited journals & entries")
            benefit("sun.horizon", title: "Find your way inward", detail: "Guided prompts for meaningful reflection")
            benefit("chart.xyaxis.line", title: "See how far you’ve grown", detail: "Mood patterns & personal insights")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 13)
    }

    private func benefit(_ symbol: String, title: String, detail: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .light))
                .frame(width: 29)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14, weight: .medium))
                Text(detail).font(.system(size: 12)).foregroundStyle(ink.opacity(0.6))
            }
        }
    }

    private var plans: some View {
        HStack(spacing: 11) {
            planCard(.monthly)
            planCard(.yearly)
        }
    }

    private func planCard(_ plan: JournalPlan) -> some View {
        let selected = selectedPlan == plan
        return Button {
            withAnimation(.easeInOut(duration: 0.18)) { selectedPlan = plan }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(plan.title).font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 4)
                    ZStack {
                        Circle().stroke(selected ? ink : ink.opacity(0.25), lineWidth: 1)
                        if selected {
                            Circle().fill(ink)
                            Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(paper)
                        }
                    }
                    .frame(width: 19, height: 19)
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(plan.amount).font(.system(size: 25, weight: .medium, design: .serif))
                    Text(plan == .yearly ? "/ year" : "/ month")
                        .font(.system(size: 11))
                        .foregroundStyle(ink.opacity(0.65))
                }
                Text(plan == .yearly ? "Just $2.50 per month" : "Billed monthly")
                    .font(.system(size: 11))
                    .foregroundStyle(ink.opacity(0.6))
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selected ? Color(red: 0.90, green: 0.92, blue: 0.85) : Color.white.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(selected ? ink : ink.opacity(0.16), lineWidth: selected ? 1.5 : 1))
            .overlay(alignment: .top) {
                if plan == .yearly {
                    Text("SAVE 58%")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(ink, in: Capsule())
                        .foregroundStyle(paper)
                        .offset(y: -11)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(plan.title), \(plan.price)\(plan == .yearly ? ", save 58 percent" : "")")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    private var purchaseArea: some View {
        VStack(spacing: 10) {
            Button { showingConfirmation = true } label: {
                HStack {
                    Spacer()
                    Text("Begin your next chapter").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.right").font(.system(size: 15))
                }
                .padding(.horizontal, 20)
                .frame(height: 54)
                .foregroundStyle(paper)
                .background(ink, in: RoundedRectangle(cornerRadius: 15))
            }
            Text("\(selectedPlan.price) · Auto-renews. Cancel anytime.")
                .font(.system(size: 10))
                .foregroundStyle(ink.opacity(0.6))
        }
    }

    private var footer: some View {
        HStack(spacing: 16) {
            Button("Restore purchases") { showingRestore = true }
            Text("·")
            Button("Terms") { showingTerms = true }
            Text("·")
            Button("Privacy") { showingTerms = true }
        }
        .font(.system(size: 10))
        .foregroundStyle(ink.opacity(0.55))
        .buttonStyle(.plain)
    }
}

fileprivate enum JournalPlan {
    case monthly
    case yearly

    var title: String { self == .monthly ? "Monthly" : "Yearly" }
    var amount: String { self == .monthly ? "$5.99" : "$29.99" }
    var price: String { self == .monthly ? "$5.99/month" : "$29.99/year" }
}
