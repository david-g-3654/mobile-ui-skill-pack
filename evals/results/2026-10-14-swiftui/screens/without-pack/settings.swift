import SwiftUI

// MARK: - Models

fileprivate enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

fileprivate enum AccentChoice: String, CaseIterable, Identifiable {
    case blue, indigo, teal, green, orange, pink
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .blue: return .blue
        case .indigo: return .indigo
        case .teal: return .teal
        case .green: return .green
        case .orange: return .orange
        case .pink: return .pink
        }
    }
}

fileprivate enum DigestFrequency: String, CaseIterable, Identifiable {
    case off = "Off"
    case daily = "Daily"
    case weekly = "Weekly"
    var id: String { rawValue }
}

fileprivate struct UserProfile {
    var name: String
    var email: String
    var initials: String
    var memberSince: String
}

fileprivate struct Subscription {
    var planName: String
    var price: String
    var renewalDate: String
    var storageUsedGB: Double
    var storageTotalGB: Double
}

fileprivate struct ConnectedDevice: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let lastActive: String
    let isCurrent: Bool
}

fileprivate enum SampleData {
    static let profile = UserProfile(
        name: "Lena Hoffmann",
        email: "lena.hoffmann@mailbox.org",
        initials: "LH",
        memberSince: "March 2022"
    )
    static let subscription = Subscription(
        planName: "Pro Annual",
        price: "$59.99 / year",
        renewalDate: "Mar 14, 2027",
        storageUsedGB: 38.4,
        storageTotalGB: 100
    )
    static let devices: [ConnectedDevice] = [
        ConnectedDevice(name: "iPhone 16 Pro", icon: "iphone", lastActive: "Active now", isCurrent: true),
        ConnectedDevice(name: "MacBook Air", icon: "laptopcomputer", lastActive: "2 hours ago", isCurrent: false),
        ConnectedDevice(name: "iPad mini", icon: "ipad", lastActive: "Oct 9", isCurrent: false)
    ]
}

// MARK: - Screen

struct S_settings: View {
    @State private var profile = SampleData.profile
    @State private var subscription = SampleData.subscription

    // Notifications
    @State private var pushEnabled = true
    @State private var messages = true
    @State private var reminders = true
    @State private var productUpdates = false
    @State private var digest: DigestFrequency = .weekly
    @State private var quietHours = true
    @State private var quietStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @State private var quietEnd = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()

    // Appearance
    @State private var appearance: AppearanceMode = .system
    @State private var accent: AccentChoice = .blue
    @State private var largerText = false
    @State private var reduceMotion = false

    // Account
    @State private var faceID = true
    @State private var twoFactor = true
    @State private var showSignOut = false
    @State private var showDelete = false

    init() {}

    var body: some View {
        NavigationStack {
            Form {
                profileSection
                subscriptionSection
                notificationsSection
                appearanceSection
                accountSection
                aboutSection
                signOutSection
            }
            .navigationTitle("Settings")
            .confirmationDialog("Sign out of this device?", isPresented: $showSignOut, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your data stays synced to your account.")
            }
            .alert("Delete account?", isPresented: $showDelete) {
                Button("Delete", role: .destructive) {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes your profile, files and subscription history. This can't be undone.")
            }
        }
        .tint(accent.color)
        .preferredColorScheme(appearance.colorScheme)
        .dynamicTypeSize(largerText ? .xLarge : .large)
    }

    // MARK: Profile

    private var profileSection: some View {
        Section {
            NavigationLink {
                ProfileDetailView(profile: $profile)
            } label: {
                HStack(spacing: 14) {
                    Text(profile.initials)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle().fill(
                                LinearGradient(colors: [accent.color, accent.color.opacity(0.6)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        )
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(profile.name)
                            .font(.title3.weight(.semibold))
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }

    // MARK: Subscription

    private var subscriptionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label {
                        Text(subscription.planName).font(.headline)
                    } icon: {
                        Image(systemName: "crown.fill").foregroundStyle(.yellow)
                    }
                    Spacer()
                    Text("Active")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.green.opacity(0.15)))
                        .foregroundStyle(.green)
                }
                Text("\(subscription.price) · Renews \(subscription.renewalDate)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 6) {
                    ProgressView(value: subscription.storageUsedGB, total: subscription.storageTotalGB)
                    Text(String(format: "%.1f GB of %.0f GB used", subscription.storageUsedGB, subscription.storageTotalGB))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)

            NavigationLink {
                PlansView(currentPlan: subscription.planName)
            } label: {
                SettingsRowLabel(title: "Change Plan", icon: "arrow.up.arrow.down.circle.fill", color: .purple)
            }
            NavigationLink {
                BillingHistoryView()
            } label: {
                SettingsRowLabel(title: "Billing History", icon: "doc.text.fill", color: .gray)
            }
            Button {
            } label: {
                SettingsRowLabel(title: "Restore Purchases", icon: "arrow.clockwise.circle.fill", color: .teal)
            }
            .foregroundStyle(.primary)
        } header: {
            Text("Subscription")
        } footer: {
            Text("Manage or cancel anytime in your App Store account settings.")
        }
    }

    // MARK: Notifications

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $pushEnabled.animation()) {
                SettingsRowLabel(title: "Push Notifications", icon: "bell.badge.fill", color: .red)
            }
            if pushEnabled {
                Toggle(isOn: $messages) {
                    SettingsRowLabel(title: "Messages", icon: "message.fill", color: .green)
                }
                Toggle(isOn: $reminders) {
                    SettingsRowLabel(title: "Reminders", icon: "alarm.fill", color: .orange)
                }
                Toggle(isOn: $productUpdates) {
                    SettingsRowLabel(title: "Product Updates", icon: "sparkles", color: .indigo)
                }
            }
            Picker(selection: $digest) {
                ForEach(DigestFrequency.allCases) { Text($0.rawValue).tag($0) }
            } label: {
                SettingsRowLabel(title: "Email Digest", icon: "envelope.fill", color: .blue)
            }
            Toggle(isOn: $quietHours.animation()) {
                SettingsRowLabel(title: "Quiet Hours", icon: "moon.zzz.fill", color: .indigo)
            }
            if quietHours {
                DatePicker("From", selection: $quietStart, displayedComponents: .hourAndMinute)
                DatePicker("To", selection: $quietEnd, displayedComponents: .hourAndMinute)
            }
        } header: {
            Text("Notifications")
        } footer: {
            if quietHours {
                Text("Notifications are silenced during quiet hours, except for calls from favorites.")
            }
        }
    }

    // MARK: Appearance

    private var appearanceSection: some View {
        Section("Appearance") {
            HStack(spacing: 10) {
                ForEach(AppearanceMode.allCases) { mode in
                    AppearanceTile(mode: mode, isSelected: appearance == mode, tint: accent.color) {
                        withAnimation(.snappy) { appearance = mode }
                    }
                }
            }
            .padding(.vertical, 6)

            VStack(alignment: .leading, spacing: 10) {
                Text("Accent Color")
                HStack(spacing: 0) {
                    ForEach(AccentChoice.allCases) { choice in
                        Button {
                            withAnimation(.snappy) { accent = choice }
                        } label: {
                            Circle()
                                .fill(choice.color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.primary.opacity(accent == choice ? 0.9 : 0), lineWidth: 2)
                                        .padding(-5)
                                )
                                .overlay {
                                    if accent == choice {
                                        Image(systemName: "checkmark")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(choice.rawValue.capitalized)
                        .accessibilityAddTraits(accent == choice ? .isSelected : [])
                    }
                }
            }
            .padding(.vertical, 4)

            Toggle(isOn: $largerText) {
                SettingsRowLabel(title: "Larger Text", icon: "textformat.size", color: .blue)
            }
            Toggle(isOn: $reduceMotion) {
                SettingsRowLabel(title: "Reduce Motion", icon: "figure.walk.motion", color: .cyan)
            }
        }
    }

    // MARK: Account

    private var accountSection: some View {
        Section("Account & Security") {
            NavigationLink {
                ProfileDetailView(profile: $profile)
            } label: {
                SettingsRowLabel(title: "Personal Information", icon: "person.crop.circle.fill", color: .blue)
            }
            NavigationLink {
                PasswordView()
            } label: {
                SettingsRowLabel(title: "Change Password", icon: "key.fill", color: .gray)
            }
            Toggle(isOn: $faceID) {
                SettingsRowLabel(title: "Unlock with Face ID", icon: "faceid", color: .green)
            }
            Toggle(isOn: $twoFactor) {
                SettingsRowLabel(title: "Two-Factor Authentication", icon: "lock.shield.fill", color: .orange)
            }
            NavigationLink {
                DevicesView()
            } label: {
                HStack {
                    SettingsRowLabel(title: "Devices", icon: "laptopcomputer.and.iphone", color: .purple)
                    Spacer()
                    Text("\(SampleData.devices.count)").foregroundStyle(.secondary)
                }
            }
            NavigationLink {
                PlaceholderDetail(title: "Privacy & Data", icon: "hand.raised.fill",
                                  message: "Export a copy of your data or manage what is shared for analytics.")
            } label: {
                SettingsRowLabel(title: "Privacy & Data", icon: "hand.raised.fill", color: .blue)
            }
        }
    }

    // MARK: About

    private var aboutSection: some View {
        Section("Support") {
            NavigationLink {
                PlaceholderDetail(title: "Help Center", icon: "questionmark.circle.fill",
                                  message: "Browse guides and FAQs, or contact our support team.")
            } label: {
                SettingsRowLabel(title: "Help Center", icon: "questionmark.circle.fill", color: .teal)
            }
            NavigationLink {
                PlaceholderDetail(title: "Terms & Privacy", icon: "doc.plaintext.fill",
                                  message: "Terms of Service and Privacy Policy, last updated September 2026.")
            } label: {
                SettingsRowLabel(title: "Terms & Privacy", icon: "doc.plaintext.fill", color: .gray)
            }
            LabeledContent {
                Text("4.12.0 (2381)").foregroundStyle(.secondary)
            } label: {
                SettingsRowLabel(title: "Version", icon: "info.circle.fill", color: .gray)
            }
        }
    }

    private var signOutSection: some View {
        Section {
            Button("Sign Out") { showSignOut = true }
                .frame(maxWidth: .infinity)
            Button("Delete Account", role: .destructive) { showDelete = true }
                .frame(maxWidth: .infinity)
        } footer: {
            Text("Member since \(profile.memberSince)")
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
    }
}

// MARK: - Components

fileprivate struct SettingsRowLabel: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        Label {
            Text(title).foregroundStyle(.primary)
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 29, height: 29)
                .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color))
        }
    }
}

fileprivate struct AppearanceTile: View {
    let mode: AppearanceMode
    let isSelected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                preview
                    .frame(height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(isSelected ? tint : Color.secondary.opacity(0.3), lineWidth: isSelected ? 2.5 : 1)
                    )
                HStack(spacing: 4) {
                    Image(systemName: mode.icon)
                    Text(mode.rawValue)
                }
                .font(.footnote.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? tint : .secondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mode.rawValue) appearance")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var preview: some View {
        switch mode {
        case .light: mini(bg: Color(white: 0.96), bar: Color(white: 0.82))
        case .dark: mini(bg: Color(white: 0.12), bar: Color(white: 0.32))
        case .system:
            HStack(spacing: 0) {
                mini(bg: Color(white: 0.96), bar: Color(white: 0.82))
                mini(bg: Color(white: 0.12), bar: Color(white: 0.32))
            }
        }
    }

    private func mini(bg: Color, bar: Color) -> some View {
        ZStack(alignment: .topLeading) {
            bg
            VStack(alignment: .leading, spacing: 5) {
                Capsule().fill(tint).frame(width: 22, height: 5)
                Capsule().fill(bar).frame(width: 34, height: 4)
                Capsule().fill(bar).frame(width: 26, height: 4)
            }
            .padding(9)
        }
    }
}

// MARK: - Detail screens

fileprivate struct ProfileDetailView: View {
    @Binding var profile: UserProfile

    var body: some View {
        Form {
            Section("Name") {
                TextField("Full name", text: $profile.name)
                    .textContentType(.name)
            }
            Section("Email") {
                TextField("Email", text: $profile.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
        }
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct PlanOption: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let features: [String]
}

fileprivate struct PlansView: View {
    let currentPlan: String
    private let plans: [PlanOption] = [
        PlanOption(name: "Free", price: "$0", features: ["5 GB storage", "Basic sync"]),
        PlanOption(name: "Pro Monthly", price: "$6.99 / month", features: ["100 GB storage", "Priority support", "Version history"]),
        PlanOption(name: "Pro Annual", price: "$59.99 / year", features: ["100 GB storage", "Priority support", "Version history", "Save 28%"]),
        PlanOption(name: "Family", price: "$89.99 / year", features: ["500 GB shared", "Up to 6 members", "Everything in Pro"])
    ]

    var body: some View {
        List(plans) { plan in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(plan.name).font(.headline)
                    Spacer()
                    if plan.name == currentPlan {
                        Text("Current")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tint)
                    }
                }
                Text(plan.price).font(.subheadline).foregroundStyle(.secondary)
                ForEach(plan.features, id: \.self) { f in
                    Label(f, systemImage: "checkmark")
                        .font(.footnote)
                        .labelStyle(.titleAndIcon)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Plans")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct BillingHistoryView: View {
    private let items: [(String, String)] = [
        ("Mar 14, 2026", "$59.99"),
        ("Mar 14, 2025", "$59.99"),
        ("Feb 14, 2025", "$6.99"),
        ("Jan 14, 2025", "$6.99")
    ]

    var body: some View {
        List(items, id: \.0) { item in
            LabeledContent(item.0, value: item.1)
        }
        .navigationTitle("Billing History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct PasswordView: View {
    @State private var current = ""
    @State private var new = ""
    @State private var confirm = ""

    private var canSave: Bool { !current.isEmpty && new.count >= 8 && new == confirm }

    var body: some View {
        Form {
            SecureField("Current password", text: $current)
            Section {
                SecureField("New password", text: $new)
                SecureField("Confirm new password", text: $confirm)
            } footer: {
                Text("Use at least 8 characters.")
            }
            Button("Update Password") {}
                .disabled(!canSave)
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct DevicesView: View {
    var body: some View {
        List(SampleData.devices) { device in
            HStack(spacing: 12) {
                Image(systemName: device.icon)
                    .font(.title3)
                    .frame(width: 32)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(device.name)
                    Text(device.isCurrent ? "This device" : device.lastActive)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !device.isCurrent {
                    Button("Sign Out", role: .destructive) {}
                        .buttonStyle(.borderless)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Devices")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct PlaceholderDetail: View {
    let title: String
    let icon: String
    let message: String

    var body: some View {
        ContentUnavailableView(title, systemImage: icon, description: Text(message))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    S_settings()
}
