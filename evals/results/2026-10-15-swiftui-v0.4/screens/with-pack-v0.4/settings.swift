// Screen.swift — Settings for "Margin", a reading app (archetype: Settings).
// Job: change preferences and manage the account. Focal: the account header row.
// Primary action: none — toggles and pickers apply immediately; sign out / delete live last.
// Uses the default "Quiet" skin (DesignSystem.swift + Components.swift).

import SwiftUI

// MARK: - Sample data

fileprivate struct MarginReader {
    let name: String
    let email: String
    let memberSince: String
    let signInMethod: String
}

fileprivate struct MarginPlan {
    let name: String
    let price: Decimal
    let period: String
    let renewsOn: Date
    let booksThisYear: Int
}

fileprivate enum SampleData {
    static let reader = MarginReader(
        name: "Priya Raghunathan",
        email: "priya.raghunathan@fastmail.com",
        memberSince: "March 2023",
        signInMethod: "Apple"
    )

    static let plan = MarginPlan(
        name: "Margin Plus",
        price: 39.99,
        period: "year",
        renewsOn: Calendar.current.date(byAdding: .day, value: 27, to: .now) ?? .now,
        booksThisYear: 23
    )

    static let version = "Margin 3.8.1 (2207)"
}

// MARK: - Preference types

fileprivate enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System", light = "Light", dark = "Dark"
    var id: Self { self }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

fileprivate enum ReadingTypeface: String, CaseIterable, Identifiable {
    case serif = "Serif", sans = "Sans serif", mono = "Monospaced"
    var id: Self { self }
}

fileprivate enum DigestDay: String, CaseIterable, Identifiable {
    case sunday = "Sunday", monday = "Monday", friday = "Friday"
    var id: Self { self }
}

// MARK: - Screen

struct S_settings: View {
    @State private var appearance: AppearanceMode = .system
    @State private var typeface: ReadingTypeface = .serif
    @State private var keepScreenAwake = true

    @State private var allowNotifications = true
    @State private var dailyReminder = true
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 30)) ?? .now
    @State private var authorReleases = true
    @State private var weeklyDigest = false
    @State private var digestDay: DigestDay = .sunday

    @State private var isRestoring = false
    @State private var toastMessage: String?
    @State private var confirmSignOut = false
    @State private var confirmDelete = false

    @Environment(\.dynamicTypeSize) private var typeSize

    init() {}

    private let reader = SampleData.reader
    private let plan = SampleData.plan

    var body: some View {
        NavigationStack {
            List {
                accountSection
                appearanceSection
                notificationsSection
                subscriptionSection
                supportSection
                sessionSection
            }
            .listStyle(.insetGrouped)
            .qCanvasBackground()
            .navigationTitle("Settings")
            .sensoryFeedback(.selection, trigger: allowNotifications)
            .sensoryFeedback(.selection, trigger: dailyReminder)
            .sensoryFeedback(.selection, trigger: authorReleases)
            .sensoryFeedback(.selection, trigger: weeklyDigest)
            .sensoryFeedback(.selection, trigger: keepScreenAwake)
            .sensoryFeedback(.success, trigger: toastMessage) { _, new in new != nil }
            .confirmationDialog("Sign out of Margin?", isPresented: $confirmSignOut, titleVisibility: .visible) {
                Button("Sign out") {}
                Button("Stay signed in", role: .cancel) {}
            } message: {
                Text("Downloaded books stay on this iPhone. Highlights sync again when you sign back in.")
            }
            .confirmationDialog("Delete your Margin account?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) {}
                Button("Keep account", role: .cancel) {}
            } message: {
                Text("Your library, 412 highlights and reading history will be erased. Cancel Margin Plus in the App Store first so you aren't billed again.")
            }
            .qToast(toastMessage)
        }
        .tint(QPalette.ink)
        .preferredColorScheme(appearance.colorScheme)
    }

    // MARK: Account

    private var accountSection: some View {
        Section {
            NavigationLink {
                AccountDetail(reader: reader)
            } label: {
                let layout = typeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.xs))
                    : AnyLayout(HStackLayout(spacing: QSpace.sm))
                layout {
                    QAvatar(name: reader.name, size: 48)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reader.name)
                            .font(.dsHeadline)
                            .foregroundStyle(QPalette.ink)
                        Text(reader.email)
                            .font(.dsSubhead)
                            .foregroundStyle(QPalette.ink2)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .padding(.vertical, QSpace.xxs)
            }
            .accessibilityHint("Edit name, email and sign-in")
            .qSurfaceRow()
        }
    }

    // MARK: Appearance

    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $appearance) {
                ForEach(AppearanceMode.allCases) { Text($0.rawValue).tag($0) }
            }
            .qSurfaceRow()

            Picker("Reading font", selection: $typeface) {
                ForEach(ReadingTypeface.allCases) { Text($0.rawValue).tag($0) }
            }
            .qSurfaceRow()

            Toggle("Keep screen awake", isOn: $keepScreenAwake)
                .tint(QPalette.positive)
                .qSurfaceRow()
        } header: {
            Text("Appearance").qOverlineStyle()
        } footer: {
            Text("The screen stays on while a book is open, then dims after 10 minutes without a page turn.")
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
        }
    }

    // MARK: Notifications

    private var notificationsSection: some View {
        Section {
            Toggle("Allow notifications", isOn: $allowNotifications.animation(QMotion.snappy))
                .tint(QPalette.positive)
                .qSurfaceRow()

            if allowNotifications {
                Toggle("Daily reading reminder", isOn: $dailyReminder.animation(QMotion.snappy))
                    .tint(QPalette.positive)
                    .qSurfaceRow()

                if dailyReminder {
                    DatePicker("Remind me at", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .qSurfaceRow()
                }

                Toggle(isOn: $authorReleases) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("New releases")
                        Text("From the 14 authors you follow")
                            .font(.dsSubhead)
                            .foregroundStyle(QPalette.ink2)
                    }
                }
                .tint(QPalette.positive)
                .qSurfaceRow()

                Toggle("Weekly digest", isOn: $weeklyDigest.animation(QMotion.snappy))
                    .tint(QPalette.positive)
                    .qSurfaceRow()

                if weeklyDigest {
                    Picker("Send on", selection: $digestDay) {
                        ForEach(DigestDay.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .qSurfaceRow()
                }
            }
        } header: {
            Text("Notifications").qOverlineStyle()
        } footer: {
            Text(allowNotifications
                 ? "Reminders skip days you've already read for 15 minutes."
                 : "Margin won't send anything. Your streak still counts in the app.")
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
        }
    }

    // MARK: Subscription

    private var subscriptionSection: some View {
        Section {
            NavigationLink {
                PlanDetail(plan: plan)
            } label: {
                LabeledContent(plan.name) {
                    Text("Renews \(plan.renewsOn.formatted(.dateTime.month(.abbreviated).day()))")
                }
            }
            .qSurfaceRow()

            Button {
                restorePurchases()
            } label: {
                HStack {
                    Text(isRestoring ? "Restoring…" : "Restore purchases")
                        .foregroundStyle(QPalette.ink)
                    Spacer()
                    if isRestoring {
                        ProgressView().tint(QPalette.ink2)
                    }
                }
            }
            .disabled(isRestoring)
            .qSurfaceRow()

            ExternalLinkRow(title: "Manage in App Store", url: URL(string: "https://apps.apple.com/account/subscriptions")!)
                .qSurfaceRow()
        } header: {
            Text("Subscription").qOverlineStyle()
        } footer: {
            Text("\(plan.price.formatted(.currency(code: "USD")))/\(plan.period), billed to your Apple ID. Cancel anytime before the renewal date.")
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
        }
    }

    // MARK: Support

    private var supportSection: some View {
        Section {
            ExternalLinkRow(title: "Help center", url: URL(string: "https://example.com/margin/help")!)
                .qSurfaceRow()
            ExternalLinkRow(title: "Privacy policy", url: URL(string: "https://example.com/margin/privacy")!)
                .qSurfaceRow()
        }
    }

    // MARK: Sign out / delete

    private var sessionSection: some View {
        Section {
            Button("Sign out") { confirmSignOut = true }
                .foregroundStyle(QPalette.ink)
                .qSurfaceRow()
            Button("Delete account", role: .destructive) { confirmDelete = true }
                .foregroundStyle(QPalette.negative)
                .qSurfaceRow()
        } footer: {
            Text(SampleData.version)
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
                .frame(maxWidth: .infinity)
                .padding(.top, QSpace.xl)
        }
    }

    private func restorePurchases() {
        isRestoring = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            isRestoring = false
            toastMessage = "Margin Plus is active"
            try? await Task.sleep(for: .seconds(2.5))
            toastMessage = nil
        }
    }
}

// MARK: - Rows

fileprivate struct ExternalLinkRow: View {
    let title: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack {
                Text(title).foregroundStyle(QPalette.ink)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(QPalette.ink2)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityHint("Opens in Safari")
    }
}

// MARK: - Pushed screens

fileprivate struct AccountDetail: View {
    let reader: MarginReader
    @State private var displayName: String
    @State private var exportRequested = false

    init(reader: MarginReader) {
        self.reader = reader
        _displayName = State(initialValue: reader.name)
    }

    var body: some View {
        List {
            Section {
                TextField("Display name", text: $displayName)
                    .textContentType(.name)
                    .submitLabel(.done)
                    .qSurfaceRow()
                LabeledContent("Email", value: reader.email)
                    .qSurfaceRow()
            } header: {
                Text("Profile").qOverlineStyle()
            } footer: {
                Text("Your display name appears on highlights you share to book clubs.")
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
            }

            Section {
                LabeledContent("Signed in with", value: reader.signInMethod)
                    .qSurfaceRow()
                LabeledContent("Member since", value: reader.memberSince)
                    .qSurfaceRow()
            } header: {
                Text("Sign-in").qOverlineStyle()
            }

            Section {
                Button(exportRequested ? "Export requested" : "Export highlights and notes") {
                    exportRequested = true
                }
                .foregroundStyle(exportRequested ? QPalette.ink2 : QPalette.ink)
                .disabled(exportRequested)
                .qSurfaceRow()
            } footer: {
                Text(exportRequested
                     ? "We'll email a Markdown file to \(reader.email) within a few minutes."
                     : "Get every highlight and note as a Markdown file by email.")
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
            }
        }
        .listStyle(.insetGrouped)
        .qCanvasBackground()
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: exportRequested)
    }
}

fileprivate struct PlanDetail: View {
    let plan: MarginPlan

    var body: some View {
        List {
            Section {
                LabeledContent("Plan", value: plan.name)
                    .qSurfaceRow()
                LabeledContent("Price", value: "\(plan.price.formatted(.currency(code: "USD")))/\(plan.period)")
                    .qSurfaceRow()
                LabeledContent("Next renewal", value: plan.renewsOn.formatted(date: .long, time: .omitted))
                    .qSurfaceRow()
            } footer: {
                Text("You've finished \(plan.booksThisYear) books this year with offline downloads, unlimited highlights and synced notes.")
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
            }

            Section {
                ExternalLinkRow(title: "Change or cancel plan", url: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    .qSurfaceRow()
            }
        }
        .listStyle(.insetGrouped)
        .qCanvasBackground()
        .navigationTitle("Margin Plus")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Light") { S_settings() }
#Preview("Dark") { S_settings().preferredColorScheme(.dark) }
#Preview("Large text") { S_settings().dynamicTypeSize(.accessibility2) }
