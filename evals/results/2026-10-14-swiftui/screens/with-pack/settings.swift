// Screen.swift — Settings archetype (mobile-ui/references/screen-settings.md), default "Quiet" skin.
// Job: change preferences and manage the account. Focal: the account header row.
// Primary action: none — toggles and pickers apply immediately; destructive actions sit in the last group.
// Cutting: row icons (rule: tiles on every row or none — none keeps it calm), a "Save" button, upsell banners.

import SwiftUI

// MARK: - Sample data

fileprivate enum SampleAccount {
    static let name = "Amara Okafor"
    static let email = "amara.okafor@fastmail.com"
    static let username = "amarareads"
    static let memberSince = "March 2023"
    static let passwordChanged = "Changed 3 months ago"
    static let devices = ["iPhone 16 Pro · this device", "iPad Air · last seen yesterday", "MacBook Air · last seen Oct 2"]

    static let planName = "Margin Pro"
    static let planPrice = "$29.99 a year"
    static let paymentMethod = "Apple ID"
    static let renewal: Date = Calendar.current.date(byAdding: .day, value: 147, to: .now) ?? .now
    static let appVersion = "Margin 3.8.1 (2417)"
}

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
    case serif = "New York", sans = "SF Pro", mono = "SF Mono"
    var id: Self { self }
}

fileprivate enum ExportState: Equatable {
    case idle, preparing, ready
}

// MARK: - Screen

struct S_settings: View {
    @State private var theme: ThemeChoice = .system
    @State private var readerFont: ReaderFont = .serif
    @State private var matchSystemTextSize = true

    @State private var readingReminder = true
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 30)) ?? .now
    @State private var weeklyRecap = true
    @State private var friendHighlights = false

    @State private var confirmSignOut = false
    @State private var confirmDelete = false
    @State private var toastMessage: String?
    @State private var isRestoring = false

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
                signOutSection
            }
            .listStyle(.insetGrouped)
            .canvasBackground()
            .navigationTitle("Settings")
            .tint(Palette.ink)
            .sensoryFeedback(.selection, trigger: readingReminder)
            .sensoryFeedback(.selection, trigger: weeklyRecap)
            .sensoryFeedback(.selection, trigger: friendHighlights)
            .sensoryFeedback(.selection, trigger: theme)
            .toast(toastMessage)
            .confirmationDialog("Sign out of Margin?", isPresented: $confirmSignOut, titleVisibility: .visible) {
                Button("Sign out", role: .destructive) {}
                Button("Stay signed in", role: .cancel) {}
            } message: {
                Text("Your library stays synced to your account. You'll need your password to sign back in.")
            }
            .confirmationDialog("Delete your account?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) {}
                Button("Keep my account", role: .cancel) {}
            } message: {
                Text("Your 214 highlights, 38 notes and reading history will be permanently removed. This can't be undone.")
            }
        }
        .preferredColorScheme(theme.colorScheme)
    }

    // MARK: Account header (focal)

    private var accountHeader: some View {
        Section {
            NavigationLink {
                ProfileDetail()
            } label: {
                let layout = typeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: Space.xs))
                    : AnyLayout(HStackLayout(spacing: Space.sm))
                layout {
                    Avatar(name: SampleAccount.name, size: 48)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(SampleAccount.name).font(.dsHeadline)
                        Text(SampleAccount.email)
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

    // MARK: Appearance

    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $theme) {
                ForEach(ThemeChoice.allCases) { Text($0.rawValue).tag($0) }
            }
            .surfaceRow()
            Picker("Reading font", selection: $readerFont) {
                ForEach(ReaderFont.allCases) { Text($0.rawValue).tag($0) }
            }
            .surfaceRow()
            Toggle("Match system text size", isOn: $matchSystemTextSize)
                .tint(Palette.positive)
                .surfaceRow()
        } header: {
            Text("Appearance").overlineStyle()
        } footer: {
            Text("Reading font applies to books and notes. The rest of the app uses the system font.")
                .font(.dsFootnote).foregroundStyle(Palette.ink2)
        }
    }

    // MARK: Notifications

    private var notificationsSection: some View {
        Section {
            Toggle("Daily reading reminder", isOn: $readingReminder.animation(Motion.snappy))
                .tint(Palette.positive)
                .surfaceRow()
            if readingReminder {
                DatePicker("Remind me at", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .surfaceRow()
            }
            Toggle(isOn: $weeklyRecap) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly recap")
                    Text("Pages read and streak, every Sunday")
                        .font(.dsSubhead).foregroundStyle(Palette.ink2)
                }
            }
            .tint(Palette.positive)
            .surfaceRow()
            Toggle("Highlights from friends", isOn: $friendHighlights)
                .tint(Palette.positive)
                .surfaceRow()
        } header: {
            Text("Notifications").overlineStyle()
        } footer: {
            Text(readingReminder
                 ? "We'll skip the reminder on days you've already read for 10 minutes."
                 : "Turn on a daily reminder to keep your 12-day streak going.")
                .font(.dsFootnote).foregroundStyle(Palette.ink2)
        }
    }

    // MARK: Subscription

    private var subscriptionSection: some View {
        Section {
            NavigationLink {
                PlanDetail()
            } label: {
                LabeledContent(SampleAccount.planName) {
                    Text("Renews \(SampleAccount.renewal.formatted(.dateTime.month(.abbreviated).day()))")
                }
            }
            .surfaceRow()
            Button {
                restorePurchases()
            } label: {
                HStack {
                    Text(isRestoring ? "Restoring…" : "Restore purchases")
                    Spacer()
                    if isRestoring { ProgressView() }
                }
            }
            .foregroundStyle(Palette.ink)
            .disabled(isRestoring)
            .surfaceRow()
        } header: {
            Text("Subscription").overlineStyle()
        } footer: {
            Text("Billed through your Apple ID. Cancel anytime in Manage subscription.")
                .font(.dsFootnote).foregroundStyle(Palette.ink2)
        }
    }

    // MARK: Account

    private var accountSection: some View {
        Section {
            LabeledContent("Email", value: SampleAccount.email)
                .lineLimit(1)
                .surfaceRow()
            NavigationLink {
                PasswordDetail()
            } label: {
                LabeledContent("Password", value: SampleAccount.passwordChanged)
            }
            .surfaceRow()
            NavigationLink {
                DevicesDetail()
            } label: {
                LabeledContent("Signed-in devices", value: "\(SampleAccount.devices.count)")
            }
            .surfaceRow()
            Button("Export my library") {
                showToast("Export ready — check your email")
            }
            .foregroundStyle(Palette.ink)
            .surfaceRow()
        } header: {
            Text("Account").overlineStyle()
        } footer: {
            Text("Exports include highlights, notes and reading history as a CSV and Markdown file.")
                .font(.dsFootnote).foregroundStyle(Palette.ink2)
        }
    }

    // MARK: Sign out / delete (last)

    private var signOutSection: some View {
        Section {
            Button("Sign out") { confirmSignOut = true }
                .foregroundStyle(Palette.ink)
                .surfaceRow()
            Button("Delete account", role: .destructive) { confirmDelete = true }
                .foregroundStyle(Palette.negative)
                .surfaceRow()
        } footer: {
            VStack(spacing: Space.xxs) {
                Text(SampleAccount.appVersion)
                Text("Member since \(SampleAccount.memberSince)")
            }
            .font(.dsFootnote)
            .foregroundStyle(Palette.ink2)
            .frame(maxWidth: .infinity)
            .padding(.top, Space.xl)
        }
    }

    // MARK: Actions

    private func restorePurchases() {
        isRestoring = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            isRestoring = false
            showToast("You're on Margin Pro")
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if toastMessage == message { toastMessage = nil }
        }
    }
}

// MARK: - Pushed screens

fileprivate struct ProfileDetail: View {
    @State private var name = SampleAccount.name
    @State private var username = SampleAccount.username

    var body: some View {
        List {
            Section {
                TextField("Full name", text: $name)
                    .textContentType(.name)
                    .surfaceRow()
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .surfaceRow()
            } header: {
                Text("Profile").overlineStyle()
            } footer: {
                Text("Your username appears on highlights you share with friends.")
                    .font(.dsFootnote).foregroundStyle(Palette.ink2)
            }
            Section {
                LabeledContent("Email", value: SampleAccount.email)
                    .lineLimit(1)
                    .surfaceRow()
                LabeledContent("Member since", value: SampleAccount.memberSince)
                    .surfaceRow()
            }
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct PlanDetail: View {
    var body: some View {
        List {
            Section {
                LabeledContent("Plan", value: SampleAccount.planName).surfaceRow()
                LabeledContent("Price", value: SampleAccount.planPrice).surfaceRow()
                LabeledContent("Next charge",
                               value: SampleAccount.renewal.formatted(date: .abbreviated, time: .omitted))
                    .surfaceRow()
                LabeledContent("Paid with", value: SampleAccount.paymentMethod).surfaceRow()
            } footer: {
                Text("Pro includes unlimited highlights, AI chapter summaries and Kindle import.")
                    .font(.dsFootnote).foregroundStyle(Palette.ink2)
            }
            Section {
                Button("Switch to monthly · $3.99") {}
                    .foregroundStyle(Palette.ink)
                    .surfaceRow()
                Button("Cancel subscription", role: .destructive) {}
                    .foregroundStyle(Palette.negative)
                    .surfaceRow()
            } footer: {
                Text("If you cancel, Pro stays active until your next charge date.")
                    .font(.dsFootnote).foregroundStyle(Palette.ink2)
            }
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle("Manage subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct PasswordDetail: View {
    @State private var current = ""
    @State private var new = ""

    var body: some View {
        List {
            Section {
                SecureField("Current password", text: $current)
                    .textContentType(.password)
                    .surfaceRow()
                SecureField("New password", text: $new)
                    .textContentType(.newPassword)
                    .surfaceRow()
            } footer: {
                Text("Use at least 10 characters. Changing it signs you out on your other devices.")
                    .font(.dsFootnote).foregroundStyle(Palette.ink2)
            }
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle("Change password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Update") {}
                    .fontWeight(.semibold)
                    .disabled(current.isEmpty || new.count < 10)
            }
        }
    }
}

fileprivate struct DevicesDetail: View {
    var body: some View {
        List {
            Section {
                ForEach(SampleAccount.devices, id: \.self) { device in
                    Text(device).surfaceRow()
                }
            } footer: {
                Text("Don't recognize a device? Change your password to sign it out.")
                    .font(.dsFootnote).foregroundStyle(Palette.ink2)
            }
            Section {
                Button("Sign out of other devices", role: .destructive) {}
                    .foregroundStyle(Palette.negative)
                    .surfaceRow()
            }
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle("Signed-in devices")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Light") { S_settings() }
#Preview("Dark") { S_settings().preferredColorScheme(.dark) }
#Preview("Large text") { S_settings().dynamicTypeSize(.accessibility2) }
