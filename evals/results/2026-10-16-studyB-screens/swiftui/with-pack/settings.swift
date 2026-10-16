import SwiftUI

struct S_settings: View {
    @AppStorage("daybook.appearance") private var appearance = "System"
    @AppStorage("daybook.reminders") private var reminders = true
    @AppStorage("daybook.weeklyReview") private var weeklyReview = true
    @AppStorage("daybook.productNews") private var productNews = false
    @AppStorage("daybook.name") private var name = "Elena Morales"
    @AppStorage("daybook.email") private var email = "elena.morales@icloud.com"
    @AppStorage("daybook.signedIn") private var signedIn = true
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var confirmSignOut = false
    @State private var confirmDeletion = false
    @State private var showRestore = false

    init() {}

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if signedIn {
                    settingsList
                } else {
                    ContentUnavailableView {
                        Label("Your space is waiting", systemImage: "book.closed")
                    } description: {
                        Text("Sign in to keep your journal and preferences together.")
                    } actions: {
                        Button("Use sample account") {
                            name = "Elena Morales"
                            email = "elena.morales@icloud.com"
                            signedIn = true
                        }
                        .buttonStyle(.qSecondary)
                    }
                    .qCanvasBackground()
                }
            }
            .navigationTitle("Settings")
        }
        .tint(QPalette.ink)
        .preferredColorScheme(colorScheme)
    }

    private var settingsList: some View {
        List {
            Section {
                NavigationLink {
                    SettingsAccountEditor(name: $name, email: $email)
                } label: {
                    (typeSize.isAccessibilitySize
                     ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.sm))
                     : AnyLayout(HStackLayout(alignment: .center, spacing: QSpace.md))) {
                        QAvatar(name: name, size: QSpace.xxxl)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: QSpace.xxs) {
                            Text(name).font(.dsHeadline)
                            Text(email)
                                .font(.dsFootnote)
                                .foregroundStyle(QPalette.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, QSpace.xs)
                }
            }
            .qSurfaceRow()

            Section {
                NavigationLink {
                    SettingsNotifications(reminders: $reminders,
                                          weeklyReview: $weeklyReview,
                                          productNews: $productNews)
                } label: {
                    LabeledContent("Notifications", value: reminders || weeklyReview || productNews ? "On" : "Off")
                }
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag("System")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                }
                .pickerStyle(.menu)
            } header: {
                Text("Preferences").qOverlineStyle()
            } footer: {
                Text("A little more you. Changes are saved automatically.")
                    .foregroundStyle(QPalette.ink2)
            }
            .qSurfaceRow()

            Section {
                NavigationLink {
                    SettingsMembership()
                } label: {
                    VStack(alignment: .leading, spacing: QSpace.xxs) {
                        Text("Daybook Plus").font(.dsHeadline)
                        Text("Annual plan · $29.99 / year")
                            .font(.dsFootnote)
                            .foregroundStyle(QPalette.ink2)
                    }
                    .padding(.vertical, QSpace.xxs)
                }
                Button("Restore purchases") { showRestore = true }
            } header: {
                Text("Subscription").qOverlineStyle()
            }
            .qSurfaceRow()

            Section {
                Button("Sign out") { confirmSignOut = true }
                Button("Delete account", role: .destructive) { confirmDeletion = true }
                    .foregroundStyle(QPalette.negative)
            } header: {
                Text("Account").qOverlineStyle()
            } footer: {
                VStack(spacing: QSpace.xxs) {
                    Text("Daybook 2.8.1 (204)")
                    Text("A little space for every day.")
                }
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
                .frame(maxWidth: .infinity)
                .padding(.top, QSpace.xl)
            }
            .qSurfaceRow()
        }
        .font(.dsBody)
        .foregroundStyle(QPalette.ink)
        .environment(\.defaultMinListRowHeight, QMetrics.rowMinHeight)
        .listStyle(.insetGrouped)
        .qCanvasBackground()
        .sensoryFeedback(.selection, trigger: appearance)
        .confirmationDialog("Sign out of Daybook?", isPresented: $confirmSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { signedIn = false }
        } message: {
            Text("Your preferences will stay on this device.")
        }
        .confirmationDialog("Delete your sample account?", isPresented: $confirmDeletion, titleVisibility: .visible) {
            Button("Delete account", role: .destructive) {
                name = ""
                email = ""
                reminders = false
                weeklyReview = false
                productNews = false
                signedIn = false
            }
        } message: {
            Text("This removes your sample profile and notification preferences from this device. This cannot be undone.")
        }
        .alert("Restore purchases", isPresented: $showRestore) {
            Button("Dismiss", role: .cancel) {}
        } message: {
            Text("You’re viewing a sample Plus membership. Restoring App Store purchases requires a connected StoreKit account.")
        }
    }
}

fileprivate struct SettingsNotifications: View {
    @Binding var reminders: Bool
    @Binding var weeklyReview: Bool
    @Binding var productNews: Bool
    @AppStorage("daybook.reminderTime") private var reminderTime = 20 * 60 + 30

    private var selectedTime: Binding<Date> {
        Binding {
            Calendar.current.startOfDay(for: Date()).addingTimeInterval(Double(reminderTime) * 60)
        } set: { date in
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            reminderTime = (components.hour ?? 20) * 60 + (components.minute ?? 30)
        }
    }

    var body: some View {
        List {
            Section {
                Toggle("Daily writing reminder", isOn: $reminders)
                    .tint(QPalette.positive)
                if reminders {
                    DatePicker("Reminder time", selection: selectedTime, displayedComponents: .hourAndMinute)
                }
            } footer: {
                Text("Make room for a few words at the end of your day.")
            }
            .qSurfaceRow()
            Section {
                Toggle("Weekly reflection", isOn: $weeklyReview)
                    .tint(QPalette.positive)
                Toggle("Product updates", isOn: $productNews)
                    .tint(QPalette.positive)
            } footer: {
                Text("These preferences are saved on this device. Delivery requires notification permission and a connected notification service.")
            }
            .qSurfaceRow()
        }
        .font(.dsBody)
        .foregroundStyle(QPalette.ink)
        .environment(\.defaultMinListRowHeight, QMetrics.rowMinHeight)
        .listStyle(.insetGrouped)
        .qCanvasBackground()
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: reminders)
        .sensoryFeedback(.selection, trigger: weeklyReview)
        .sensoryFeedback(.selection, trigger: productNews)
    }
}

fileprivate struct SettingsAccountEditor: View {
    @Binding var name: String
    @Binding var email: String
    @Environment(\.dismiss) private var dismiss
    @State private var draftName = ""
    @State private var draftEmail = ""

    private var isValid: Bool {
        !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && draftEmail.contains("@") && draftEmail.contains(".")
            && !draftEmail.contains(" ")
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: QSpace.xs) {
                    Text("Full name").font(.dsFootnote).foregroundStyle(QPalette.ink2)
                    TextField("Full name", text: $draftName)
                        .textContentType(.name)
                }
                .padding(.vertical, QSpace.xxs)
                VStack(alignment: .leading, spacing: QSpace.xs) {
                    Text("Email address").font(.dsFootnote).foregroundStyle(QPalette.ink2)
                    TextField("Email address", text: $draftEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.vertical, QSpace.xxs)
            } header: {
                Text("Personal details").qOverlineStyle()
            } footer: {
                Text("Use a name and a valid email address. This sample profile is stored only on this device.")
                    .foregroundStyle(QPalette.ink2)
            }
            .qSurfaceRow()
        }
        .font(.dsBody)
        .foregroundStyle(QPalette.ink)
        .qCanvasBackground()
        .navigationTitle("Your account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                    email = draftEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                    dismiss()
                }
                .disabled(!isValid)
            }
        }
        .onAppear {
            draftName = name
            draftEmail = email
        }
    }
}

fileprivate struct SettingsMembership: View {
    private var renewalDate: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }

    var body: some View {
        List {
            Section {
                Text("Daybook Plus").font(.dsHeadline)
                LabeledContent("Plan", value: "Annual")
                LabeledContent("Price", value: "$29.99 / year")
                LabeledContent("Next renewal", value: renewalDate.formatted(date: .abbreviated, time: .omitted))
            } header: {
                Text("Your membership").qOverlineStyle()
            } footer: {
                Text("Unlimited journals, photo entries and a little more room to reflect.")
            }
            .qSurfaceRow()
            Section {
                Text("This is a sample membership. To change or cancel a real plan, open Settings on your iPhone, tap your name, then Subscriptions.")
                    .font(.dsBody)
                    .foregroundStyle(QPalette.ink2)
            }
            .qSurfaceRow()
        }
        .font(.dsBody)
        .foregroundStyle(QPalette.ink)
        .listStyle(.insetGrouped)
        .qCanvasBackground()
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    S_settings().preferredColorScheme(.light)
}

#Preview("Dark") {
    S_settings().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_settings().environment(\.dynamicTypeSize, .accessibility2)
}
