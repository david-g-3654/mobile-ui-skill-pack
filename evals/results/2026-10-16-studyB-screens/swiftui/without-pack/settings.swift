import SwiftUI

fileprivate typealias SettingsState<Value> = SwiftUI.State<Value>

struct S_settings: View {
    @SettingsState private var pushNotifications = true
    @SettingsState private var weeklySummary = false
    @SettingsState private var appearance = "System"
    @SettingsState private var selectedDetail: String? = nil
    @SettingsState private var showingSignOut = false
    @Environment(\.colorScheme) private var colorScheme

    init() {}

    private var ink: Color { colorScheme == .dark ? Color.white : Color(red: 0.16, green: 0.22, blue: 0.20) }
    private let accent = Color(red: 0.28, green: 0.40, blue: 0.32)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    profile
                    subscription

                    section("PREFERENCES") {
                        VStack(spacing: 0) {
                            settingRow("Notifications", subtitle: "Stay in the loop", symbol: "bell") {
                                Toggle("Push notifications", isOn: $pushNotifications)
                                    .labelsHidden()
                                    .tint(accent)
                            }
                            rowDivider
                            settingRow("Weekly summary", subtitle: "A little perspective, every Sunday", symbol: "calendar") {
                                Toggle("Weekly summary", isOn: $weeklySummary)
                                    .labelsHidden()
                                    .tint(accent)
                            }
                            rowDivider
                            settingRow("Appearance", symbol: "circle.lefthalf.filled") {
                                Menu {
                                    Picker("Appearance", selection: $appearance) {
                                        Text("System").tag("System")
                                        Text("Light").tag("Light")
                                        Text("Dark").tag("Dark")
                                    }
                                } label: {
                                    HStack(spacing: 7) {
                                        Text(appearance).font(.system(size: 14))
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 10, weight: .semibold))
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    section("ACCOUNT") {
                        VStack(spacing: 0) {
                            detailRow("Personal information", symbol: "person.crop.circle", detail: "Your profile")
                            rowDivider
                            detailRow("Privacy & security", symbol: "lock", detail: "Privacy & security")
                            rowDivider
                            detailRow("Help & support", symbol: "questionmark.circle", detail: "Here to help")
                        }
                    }

                    Button { showingSignOut = true } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign out").fontWeight(.medium)
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 0.60, green: 0.30, blue: 0.25))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(.background.opacity(0.65), in: RoundedRectangle(cornerRadius: 17))
                    }

                    VStack(spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: "leaf")
                            Text("A little better, every day.")
                        }
                        .font(.system(size: 12, weight: .medium))
                        Text("Version 2.8.0 · Made with care")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 18)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(colorScheme == .dark ? Color(red: 0.10, green: 0.13, blue: 0.11) : Color(red: 0.96, green: 0.96, blue: 0.93))
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: Binding(get: { selectedDetail != nil }, set: { if !$0 { selectedDetail = nil } })) {
                detailSheet(selectedDetail ?? "Settings")
            }
            .confirmationDialog("Sign out of your account?", isPresented: $showingSignOut, titleVisibility: .visible) {
                Button("Sign out", role: .destructive) { selectedDetail = "Signed out" }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your progress will be safely saved for when you return.")
            }
        }
        .preferredColorScheme(appearance == "Dark" ? .dark : appearance == "Light" ? .light : nil)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MAKE YOURSELF AT HOME")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(2.2)
                .foregroundStyle(accent)
            Text("Settings")
                .font(.system(size: 39, weight: .regular, design: .serif))
                .foregroundStyle(ink)
            Text("Your space. Your preferences.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 1)
    }

    private var profile: some View {
        Button { selectedDetail = "Your profile" } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Color(red: 0.85, green: 0.88, blue: 0.80))
                    Text("JL").font(.system(size: 22, weight: .medium, design: .serif)).foregroundStyle(accent)
                }
                .frame(width: 58, height: 58)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Jamie Lewis").font(.system(size: 17, weight: .semibold)).foregroundStyle(ink)
                    Text("jamie.lewis@email.com").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.tertiary)
            }
            .padding(17)
            .background(.background, in: RoundedRectangle(cornerRadius: 21))
        }
        .buttonStyle(.plain)
    }

    private var subscription: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("A LITTLE MORE POSSIBILITY").tracking(1.3)
                    }
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color(red: 0.81, green: 0.86, blue: 0.72))
                    Text("Your everyday, elevated.")
                        .font(.system(size: 23, weight: .regular, design: .serif))
                    Text("More room to grow with Plus.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer(minLength: 0)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 31, weight: .light))
                    .rotationEffect(.degrees(-20))
                    .foregroundStyle(.white.opacity(0.26))
                    .padding(.top, 18)
            }
            HStack {
                Text("FREE PLAN")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.12), in: Capsule())
                Spacer()
                Button { selectedDetail = "Explore Plus" } label: {
                    HStack(spacing: 8) {
                        Text("Explore Plus")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .foregroundStyle(ink)
                    .background(Color(red: 0.92, green: 0.93, blue: 0.83), in: Capsule())
                }
            }
        }
        .foregroundStyle(.white)
        .padding(21)
        .background(accent, in: RoundedRectangle(cornerRadius: 21))
    }

    private var rowDivider: some View {
        Divider().padding(.leading, 54).padding(.trailing, 16)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.8)
                .foregroundStyle(.secondary)
                .padding(.leading, 3)
            content()
                .background(.background, in: RoundedRectangle(cornerRadius: 19))
        }
    }

    private func settingRow<Trailing: View>(_ title: String, subtitle: String? = nil, symbol: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 14, weight: .medium))
                if let subtitle {
                    Text(subtitle).font(.system(size: 10)).foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 17)
    }

    private func detailRow(_ title: String, symbol: String, detail: String) -> some View {
        Button { selectedDetail = detail } label: {
            settingRow(title, symbol: symbol) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func detailSheet(_ detail: String) -> some View {
        NavigationStack {
            List {
                if detail == "Your profile" {
                    LabeledContent("Name", value: "Jamie Lewis")
                    LabeledContent("Email", value: "jamie.lewis@email.com")
                    LabeledContent("Member since", value: "March 2025")
                } else if detail == "Explore Plus" {
                    Section("A little more room to grow") {
                        Label("Unlimited daily reflections", systemImage: "book")
                        Label("Personal insights and trends", systemImage: "chart.xyaxis.line")
                        Label("All themes and collections", systemImage: "paintpalette")
                    }
                    Text("You’re on the Free plan. Plus subscriptions are not available in this preview.")
                        .foregroundStyle(.secondary)
                } else if detail == "Privacy & security" {
                    Label("Your reflections stay private", systemImage: "lock.shield")
                    Text("Your personal information is never sold. You can request a copy of your data or account deletion by contacting support.")
                } else if detail == "Signed out" {
                    Text("You’ve signed out of this preview. Your progress is saved.")
                } else {
                    LabeledContent("Email us", value: "hello@everyday.example")
                    Text("We’re here Monday–Friday, and usually reply within two working days.")
                }
            }
            .navigationTitle(detail)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { selectedDetail = nil }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
