import SwiftUI

// MARK: - Models & sample data

fileprivate enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System", light = "Light", dark = "Dark"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

fileprivate enum AccentChoice: String, CaseIterable, Identifiable {
    case blue = "Blue", indigo = "Indigo", teal = "Teal", green = "Green", orange = "Orange", pink = "Pink"
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
    case never = "Never", daily = "Daily", weekly = "Weekly"
    var id: String { rawValue }
}

fileprivate struct UserProfile {
    var name = "Maya Thompson"
    var email = "maya.thompson@icloud.com"
    var initials: String { "MT" }
    var memberSince = "March 2022"
}

fileprivate struct Subscription {
    var plan = "Pro Annual"
    var price = "$39.99 / year"
    var renews = "Renews Feb 14, 2027"
    var storageUsed: Double = 38.4
    var storageTotal: Double = 100
}

fileprivate struct Device: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let detail: String
    let isCurrent: Bool
}

fileprivate let sampleDevices: [Device] = [
    Device(name: "Maya's iPhone 15 Pro", symbol: "iphone", detail: "This device", isCurrent: true),
    Device(name: "MacBook Air", symbol: "laptopcomputer", detail: "Active 2 hours ago", isCurrent: false),
    Device(name: "iPad mini", symbol: "ipad", detail: "Active 6 days ago", isCurrent: false)
]

// MARK: - Root

struct S_settings: View {
    @State private var profile = UserProfile()
    @State private var subscription = Subscription()

    // Notifications
    @State private var pushEnabled = true
    @State private var mentions = true
    @State private var comments = true
    @State private var reminders = false
    @State private var productNews = false
    @State private var digest: DigestFrequency = .weekly
    @State private var quietHours = true
    @State private var quietStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? .now
    @State private var quietEnd = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? .now

    // Appearance
    @State private var appearance: AppearanceMode = .system
    @State private var accent: AccentChoice = .blue
    @State private var appIconBadge = true
    @State private var reduceMotion = false

    // Account
    @State private var faceID = true
    @State private var showSignOut = false
    @State private var showDelete = false

    init() {}

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ProfileDetail(profile: $profile)
                    } label: {
                        ProfileHeader(profile: profile, accent: accent.color)
                    }
                }

                Section {
                    NavigationLink {
                        SubscriptionDetail(subscription: subscription, accent: accent.color)
                    } label: {
                        SubscriptionCard(subscription: subscription, accent: accent.color)
                    }
                } header: {
                    Text("Subscription")
                }

                Section {
                    Toggle(isOn: $pushEnabled.animation()) {
                        SettingsLabel("Allow Notifications", symbol: "bell.badge.fill", tint: .red)
                    }
                    if pushEnabled {
                        NavigationLink {
                            NotificationDetail(mentions: $mentions, comments: $comments, reminders: $reminders, productNews: $productNews)
                        } label: {
                            LabeledContent {
                                Text(enabledCount)
                            } label: {
                                SettingsLabel("Notification Types", symbol: "list.bullet.rectangle.fill", tint: .orange)
                            }
                        }
                        Picker(selection: $digest) {
                            ForEach(DigestFrequency.allCases) { Text($0.rawValue).tag($0) }
                        } label: {
                            SettingsLabel("Email Digest", symbol: "envelope.fill", tint: .blue)
                        }
                        Toggle(isOn: $quietHours.animation()) {
                            SettingsLabel("Quiet Hours", symbol: "moon.zzz.fill", tint: .indigo)
                        }
                        if quietHours {
                            DatePicker("From", selection: $quietStart, displayedComponents: .hourAndMinute)
                            DatePicker("To", selection: $quietEnd, displayedComponents: .hourAndMinute)
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    if pushEnabled && quietHours {
                        Text("Notifications are silenced during quiet hours, except for direct mentions.")
                    }
                }

                Section {
                    AppearancePicker(selection: $appearance, accent: accent.color)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    AccentPicker(selection: $accent)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    Toggle(isOn: $appIconBadge) {
                        SettingsLabel("App Icon Badge", symbol: "app.badge.fill", tint: .pink)
                    }
                    Toggle(isOn: $reduceMotion) {
                        SettingsLabel("Reduce Animations", symbol: "sparkles", tint: .purple)
                    }
                } header: {
                    Text("Appearance")
                }

                Section {
                    NavigationLink {
                        DevicesDetail()
                    } label: {
                        LabeledContent {
                            Text("\(sampleDevices.count)")
                        } label: {
                            SettingsLabel("Devices", symbol: "laptopcomputer.and.iphone", tint: .gray)
                        }
                    }
                    Toggle(isOn: $faceID) {
                        SettingsLabel("Unlock with Face ID", symbol: "faceid", tint: .green)
                    }
                    NavigationLink {
                        PlaceholderDetail(title: "Password & Security", symbol: "key.fill")
                    } label: {
                        SettingsLabel("Password & Security", symbol: "key.fill", tint: .gray)
                    }
                    NavigationLink {
                        PlaceholderDetail(title: "Privacy", symbol: "hand.raised.fill")
                    } label: {
                        SettingsLabel("Privacy", symbol: "hand.raised.fill", tint: .blue)
                    }
                    NavigationLink {
                        PlaceholderDetail(title: "Export Data", symbol: "square.and.arrow.up.fill")
                    } label: {
                        SettingsLabel("Export My Data", symbol: "square.and.arrow.up.fill", tint: .teal)
                    }
                } header: {
                    Text("Account")
                }

                Section {
                    NavigationLink {
                        PlaceholderDetail(title: "Help Center", symbol: "questionmark.circle.fill")
                    } label: {
                        SettingsLabel("Help Center", symbol: "questionmark.circle.fill", tint: .cyan)
                    }
                    NavigationLink {
                        PlaceholderDetail(title: "Send Feedback", symbol: "bubble.left.and.text.bubble.right.fill")
                    } label: {
                        SettingsLabel("Send Feedback", symbol: "bubble.left.fill", tint: .mint)
                    }
                } header: {
                    Text("Support")
                }

                Section {
                    Button("Sign Out") { showSignOut = true }
                        .frame(maxWidth: .infinity)
                    Button("Delete Account", role: .destructive) { showDelete = true }
                        .frame(maxWidth: .infinity)
                } footer: {
                    Text("Version 4.2.1 (1187)")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Sign out of \(profile.email)?", isPresented: $showSignOut, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {}
                Button("Cancel", role: .cancel) {}
            }
            .alert("Delete Account?", isPresented: $showDelete) {
                Button("Delete", role: .destructive) {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes your account, projects, and subscription history. This can't be undone.")
            }
        }
        .tint(accent.color)
        .preferredColorScheme(appearance.colorScheme)
    }

    private var enabledCount: String {
        let n = [mentions, comments, reminders, productNews].filter { $0 }.count
        return "\(n) of 4"
    }
}

// MARK: - Components

fileprivate struct SettingsLabel: View {
    let title: String
    let symbol: String
    let tint: Color
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 29

    init(_ title: String, symbol: String, tint: Color) {
        self.title = title
        self.symbol = symbol
        self.tint = tint
    }

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: symbol)
                .font(.system(size: size * 0.55, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(tint.gradient, in: RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
                .accessibilityHidden(true)
        }
    }
}

fileprivate struct Avatar: View {
    let initials: String
    let accent: Color
    @ScaledMetric(relativeTo: .title) private var size: CGFloat = 60

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(colors: [accent, accent.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: Circle()
            )
            .accessibilityHidden(true)
    }
}

fileprivate struct ProfileHeader: View {
    let profile: UserProfile
    let accent: Color
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
            : AnyLayout(HStackLayout(spacing: 14))
        layout {
            Avatar(initials: profile.initials, accent: accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.title3.weight(.semibold))
                Text(profile.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Account, Devices & Security")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct SubscriptionCard: View {
    let subscription: Subscription
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Label(subscription.plan, systemImage: "crown.fill")
                    .font(.headline)
                    .foregroundStyle(accent)
                Spacer(minLength: 8)
                Text("Active")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15), in: Capsule())
                    .foregroundStyle(.green)
            }
            Text("\(subscription.price) · \(subscription.renews)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: subscription.storageUsed, total: subscription.storageTotal)
                Text("\(subscription.storageUsed, specifier: "%.1f") GB of \(Int(subscription.storageTotal)) GB cloud storage used")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct AppearancePicker: View {
    @Binding var selection: AppearanceMode
    let accent: Color
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            let layout = typeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(spacing: 8))
                : AnyLayout(HStackLayout(spacing: 10))
            layout {
                ForEach(AppearanceMode.allCases) { mode in
                    let isSelected = mode == selection
                    Button {
                        withAnimation(.snappy) { selection = mode }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: mode.symbol)
                                .font(.title2)
                            Text(mode.rawValue)
                                .font(.footnote.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(isSelected ? accent : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? accent.opacity(0.12) : Color(.tertiarySystemFill))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(isSelected ? accent : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(mode.rawValue) theme")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }
}

fileprivate struct AccentPicker: View {
    @Binding var selection: AccentChoice
    @ScaledMetric(relativeTo: .body) private var dot: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accent Color")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(selection.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(selection.color)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: dot + 12), spacing: 8)], spacing: 10) {
                ForEach(AccentChoice.allCases) { choice in
                    Button {
                        withAnimation(.snappy) { selection = choice }
                    } label: {
                        Circle()
                            .fill(choice.color.gradient)
                            .frame(width: dot, height: dot)
                            .overlay {
                                if choice == selection {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: dot * 0.45, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(4)
                            .overlay(
                                Circle().strokeBorder(choice == selection ? choice.color : .clear, lineWidth: 2)
                            )
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(choice.rawValue)
                    .accessibilityAddTraits(choice == selection ? .isSelected : [])
                }
            }
        }
    }
}

// MARK: - Detail screens

fileprivate struct ProfileDetail: View {
    @Binding var profile: UserProfile

    var body: some View {
        Form {
            Section {
                VStack(spacing: 8) {
                    Avatar(initials: profile.initials, accent: .accentColor)
                        .scaleEffect(1.3)
                        .padding(.vertical, 10)
                    Text("Member since \(profile.memberSince)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            Section("Personal Information") {
                TextField("Name", text: $profile.name)
                    .textContentType(.name)
                TextField("Email", text: $profile.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct NotificationDetail: View {
    @Binding var mentions: Bool
    @Binding var comments: Bool
    @Binding var reminders: Bool
    @Binding var productNews: Bool

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $mentions) {
                    SettingsLabel("Mentions & Replies", symbol: "at", tint: .blue)
                }
                Toggle(isOn: $comments) {
                    SettingsLabel("Comments", symbol: "text.bubble.fill", tint: .green)
                }
                Toggle(isOn: $reminders) {
                    SettingsLabel("Due Date Reminders", symbol: "calendar.badge.clock", tint: .red)
                }
            } header: {
                Text("Activity")
            }
            Section {
                Toggle(isOn: $productNews) {
                    SettingsLabel("Tips & Product News", symbol: "megaphone.fill", tint: .orange)
                }
            } header: {
                Text("From Us")
            } footer: {
                Text("We send product news at most twice a month.")
            }
        }
        .navigationTitle("Notification Types")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct SubscriptionDetail: View {
    let subscription: Subscription
    let accent: Color
    @State private var showCancel = false

    private let perks = [
        ("Unlimited projects", "infinity"),
        ("100 GB cloud storage", "icloud.fill"),
        ("Priority support", "person.fill.questionmark"),
        ("Advanced export formats", "doc.richtext.fill")
    ]

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.largeTitle)
                        .foregroundStyle(accent.gradient)
                    Text(subscription.plan)
                        .font(.title2.bold())
                    Text(subscription.renews)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .multilineTextAlignment(.center)
            }
            Section("Included") {
                ForEach(perks, id: \.0) { perk in
                    Label(perk.0, systemImage: perk.1)
                }
            }
            Section("Billing") {
                LabeledContent("Price", value: subscription.price)
                LabeledContent("Payment", value: "Apple ID")
                LabeledContent("Next Charge", value: "Feb 14, 2027")
            }
            Section {
                Button("Switch to Monthly") {}
                Button("Restore Purchases") {}
                Button("Cancel Subscription", role: .destructive) { showCancel = true }
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Cancel Pro?", isPresented: $showCancel) {
            Button("Cancel Subscription", role: .destructive) {}
            Button("Keep Pro", role: .cancel) {}
        } message: {
            Text("You'll keep Pro features until Feb 14, 2027.")
        }
    }
}

fileprivate struct DevicesDetail: View {
    var body: some View {
        List {
            Section {
                ForEach(sampleDevices) { device in
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(device.name)
                            Text(device.detail)
                                .font(.footnote)
                                .foregroundStyle(device.isCurrent ? Color.green : .secondary)
                        }
                    } icon: {
                        Image(systemName: device.symbol)
                            .foregroundStyle(Color.accentColor)
                    }
                    .swipeActions {
                        if !device.isCurrent {
                            Button("Sign Out", role: .destructive) {}
                        }
                    }
                }
            } footer: {
                Text("Swipe left on a device to sign it out.")
            }
        }
        .navigationTitle("Devices")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct PlaceholderDetail: View {
    let title: String
    let symbol: String

    var body: some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text("Options for \(title.lowercased()) appear here."))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
