// Screen.swift — Settings for "Margin", a reading-log app.
// Archetype: Settings (mobile-ui/references/screen-settings.md).
// Job: change preferences and manage the account. Focal: the account header row.
// Primary action: none — toggles and pickers apply immediately; destructive actions sit last.
// Built on the default "Quiet" skin (DesignSystem.swift + Components.swift).

import SwiftUI

// MARK: - Sample data

fileprivate enum ThemeChoice: String, CaseIterable, Identifiable {
    case system = "System", light = "Light", dark = "Dark"
    var id: Self { self }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

fileprivate enum ReaderFont: String, CaseIterable, Identifiable {
    case serif = "New York", sans = "SF Pro", rounded = "SF Rounded"
    var id: Self { self }
}

fileprivate struct ReaderProfile {
    let name: String
    let email: String
    let memberSince: String
    let booksLogged: Int
    let signInMethod: String
}

fileprivate struct PlanInfo {
    let name: String
    let price: String
    let renewal: String
}

fileprivate enum Sample {
    static let profile = ReaderProfile(
        name: "Tomás Ferreira",
        email: "tomas.ferreira@fastmail.com",
        memberSince: "Since February 2024",
        booksLogged: 87,
        signInMethod: "Sign in with Apple"
    )
    static let plan = PlanInfo(name: "Margin Plus", price: "$29.99 / year", renewal: "Renews Mar 18, 2027")
    static let version = "Margin 3.8.1 (2204)"
}

// MARK: - Screen

struct S_settings: View {
    @State private var theme: ThemeChoice = .system
    @State private var readerFont: ReaderFont = .serif
    @State private var dimAtNight = true

    @State private var readingReminder = true
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 30)) ?? .now
    @State private var streakAlerts = true
    @State private var friendActivity = false

    @State private var confirmSignOut = false
    @State private var confirmDelete = false
    @State private var toastMessage: String?

    @Environment(\.dynamicTypeSize) private var typeSize

    init() {}

    var body: some View {
        NavigationStack {
            List {
                accountHeader
                appearanceSection
                notificationsSection
                subscriptionSection
                accountSection
                sessionSection
            }
            .listStyle(.insetGrouped)
            .canvasBackground()
            .navigationTitle("Settings")
            .tint(Palette.ink)
            .animation(Motion.snappy, value: readingReminder)
            .sensoryFeedback(.selection, trigger: readingReminder)
            .sensoryFeedback(.selection, trigger: streakAlerts)
            .sensoryFeedback(.selection, trigger: friendActivity)
            .sensoryFeedback(.selection, trigger: dimAtNight)
            .sensoryFeedback(.success, trigger: toastMessage) { _, new in new != nil }
            .toast(toastMessage)
            .task(id: toastMessage) {
                guard toastMessage != nil else { return }
                try? await Task.sleep(for: .seconds(2.5))
                toastMessage = nil
            }
            .confirmationDialog("Sign out of Margin?", isPresented: $confirmSignOut, titleVisibility: .visible) {
                Button("Sign out", role: .destructive) {}
                Button("Stay signed in", role: .cancel) {}
            } message: {
                Text("Your shelves stay synced to your account. You can sign back in anytime.")
            }
            .confirmationDialog("Delete your account?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) {}
                Button("Keep my account", role: .cancel) {}
            } message: {
                Text("All 87 books, highlights and notes will be permanently erased. Cancel Margin Plus separately in the App Store.")
            }
        }
        .preferredColorScheme(theme.colorScheme)
    }

    // MARK: Sections

    private var accountHeader: some View {
        Section {
            NavigationLink {
                AccountDetailView(profile: Sample.profile)
            } label: {
                let layout = typeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: Space.xs))
                    : AnyLayout(HStackLayout(spacing: Space.sm))
                layout {
                    Avatar(name: Sample.profile.name, size: 48)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Sample.profile.name).font(.dsHeadline)
                        Text(Sample.profile.email)
                            .font(.dsSubhead)
                            .foregroundStyle(Palette.ink2)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .padding(.vertical, Space.xxs)
            }
            .surfaceRow()
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $theme) {
                ForEach(ThemeChoice.allCases) { Text($0.rawValue).tag($0) }
            }
            .surfaceRow()
            Picker("Reader font", selection: $readerFont) {
                ForEach(ReaderFont.allCases) { Text($0.rawValue).tag($0) }
            }
            .surfaceRow()
            Toggle("Warm pages after sunset", isOn: $dimAtNight)
                .tint(Palette.positive)
                .surfaceRow()
        } header: {
            Text("Appearance").overlineStyle()
        } footer: {
            Text("Warm pages shifts the reader to a sepia tone from sunset to sunrise in your time zone.")
                .font(.dsFootnote)
                .foregroundStyle(Palette.ink2)
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Reading reminder", isOn: $readingReminder)
                .tint(Palette.positive)
                .surfaceRow()
            if readingReminder {
                DatePicker("Remind me at", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .surfaceRow()
            }
            Toggle(isOn: $streakAlerts) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Streak at risk")
                    Text("Only if you haven't read by 8 PM")
                        .font(.dsSubhead)
                        .foregroundStyle(Palette.ink2)
                }
            }
            .tint(Palette.positive)
            .surfaceRow()
            Toggle("Friends finishing books", isOn: $friendActivity)
                .tint(Palette.positive)
                .surfaceRow()
        } header: {
            Text("Notifications").overlineStyle()
        } footer: {
            Text(readingReminder
                 ? "One quiet nudge a day. Margin never sends more than two notifications in 24 hours."
                 : "Reminders are off. You'll still get streak and friend alerts you've turned on.")
                .font(.dsFootnote)
                .foregroundStyle(Palette.ink2)
        }
    }

    private var subscriptionSection: some View {
        Section {
            LabeledContent {
                Text(Sample.plan.price).monospacedDigit()
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Sample.plan.name)
                    Text(Sample.plan.renewal)
                        .font(.dsSubhead)
                        .foregroundStyle(Palette.ink2)
                }
            }
            .surfaceRow()
            Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                HStack {
                    Text("Manage subscription").foregroundStyle(Palette.ink)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Palette.ink2)
                        .accessibilityHidden(true)
                }
            }
            .surfaceRow()
            Button("Restore purchases") {
                toastMessage = "Margin Plus is active on this iPhone"
            }
            .foregroundStyle(Palette.ink)
            .surfaceRow()
        } header: {
            Text("Subscription").overlineStyle()
        } footer: {
            Text("Billed through your Apple ID. Cancel at least 24 hours before renewal to avoid the next charge.")
                .font(.dsFootnote)
                .foregroundStyle(Palette.ink2)
        }
    }

    private var accountSection: some View {
        Section {
            LabeledContent("Signed in with", value: "Apple")
                .surfaceRow()
            NavigationLink {
                ExportHighlightsView()
            } label: {
                LabeledContent("Export highlights", value: "Markdown")
            }
            .surfaceRow()
            Link(destination: URL(string: "https://example.com/margin/privacy")!) {
                HStack {
                    Text("Privacy policy").foregroundStyle(Palette.ink)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Palette.ink2)
                        .accessibilityHidden(true)
                }
            }
            .surfaceRow()
        } header: {
            Text("Account").overlineStyle()
        }
    }

    private var sessionSection: some View {
        Section {
            Button("Sign out") { confirmSignOut = true }
                .foregroundStyle(Palette.ink)
                .surfaceRow()
            Button("Delete account", role: .destructive) { confirmDelete = true }
                .foregroundStyle(Palette.negative)
                .surfaceRow()
        } footer: {
            Text(Sample.version)
                .font(.dsFootnote)
                .foregroundStyle(Palette.ink2)
                .frame(maxWidth: .infinity)
                .padding(.top, Space.xl)
        }
    }
}

// MARK: - Pushed screens

fileprivate struct AccountDetailView: View {
    let profile: ReaderProfile

    var body: some View {
        List {
            Section {
                LabeledContent("Name", value: profile.name)
                    .surfaceRow()
                LabeledContent("Email") {
                    Text(profile.email)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .surfaceRow()
                LabeledContent("Sign-in", value: profile.signInMethod)
                    .surfaceRow()
            } footer: {
                Text("Your email comes from your Apple ID. Change it in the Settings app under your name.")
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.ink2)
            }

            Section {
                LabeledContent("Member") { Text(profile.memberSince) }
                    .surfaceRow()
                LabeledContent("Books logged") {
                    Text("\(profile.booksLogged)").monospacedDigit()
                }
                .surfaceRow()
            } header: {
                Text("Reading").overlineStyle()
            }
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct ExportHighlightsView: View {
    @State private var includeNotes = true

    var body: some View {
        List {
            Section {
                Toggle("Include my notes", isOn: $includeNotes)
                    .tint(Palette.positive)
                    .surfaceRow()
                LabeledContent("Highlights", value: "1,214")
                    .monospacedDigit()
                    .surfaceRow()
            } footer: {
                Text("Creates one Markdown file per book, grouped by shelf, ready for Obsidian or Notes.")
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.ink2)
            }
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle("Export highlights")
        .navigationBarTitleDisplayMode(.inline)
        .bottomActionBar {
            ShareLink(item: "Margin highlights — 1,214 passages from 87 books") {
                Text("Export 1,214 highlights")
            }
            .buttonStyle(.primary)
        }
    }
}

#Preview("Light") { S_settings() }
#Preview("Dark") { S_settings().preferredColorScheme(.dark) }
#Preview("Large text") { S_settings().dynamicTypeSize(.accessibility2) }
