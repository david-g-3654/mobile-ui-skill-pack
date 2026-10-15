// SettingsScreen.swift — Settings archetype (mobile-ui/references/screen-settings.md).
// Native inset-grouped List on canvas. Toggles apply immediately. Destructive actions last.
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import SwiftUI

struct SettingsScreen: View {
    enum Appearance: String, CaseIterable, Identifiable {
        case system = "System", light = "Light", dark = "Dark"
        var id: Self { self }
    }

    @State private var appearance: Appearance = .system
    @State private var wakeUp = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? .now
    @State private var dailyReminder = true
    @State private var weeklyReport = false
    @State private var confirmDelete = false
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        Text("Account")
                    } label: {
                        // Side by side normally; stacked at accessibility sizes so the name doesn't wrap word-by-word.
                        let layout = typeSize.isAccessibilitySize
                            ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.xs))
                            : AnyLayout(HStackLayout(spacing: QSpace.sm))
                        layout {
                            QAvatar(name: "Amara Okafor", size: 48)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Amara Okafor").font(.dsHeadline)
                                Text("amara@hey.com")
                                    .font(.dsSubhead)
                                    .foregroundStyle(QPalette.ink2)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                        .padding(.vertical, QSpace.xxs)
                    }
                    .qSurfaceRow()
                }

                Section {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(Appearance.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .qSurfaceRow()
                    DatePicker("Wake up", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .qSurfaceRow()
                    Toggle("Daily reminder", isOn: $dailyReminder)
                        .tint(QPalette.positive)
                        .qSurfaceRow()
                } header: {
                    Text("Preferences").qOverlineStyle()
                } footer: {
                    Text("Reminders arrive 10 minutes before your wake-up time.")
                        .font(.dsFootnote).foregroundStyle(QPalette.ink2)
                }

                Section {
                    Toggle(isOn: $weeklyReport) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Weekly report")
                            Text("A summary every Sunday evening")
                                .font(.dsSubhead).foregroundStyle(QPalette.ink2)
                        }
                    }
                    .tint(QPalette.positive)
                    .qSurfaceRow()
                } header: {
                    Text("Notifications").qOverlineStyle()
                }

                Section {
                    LabeledContent("Plan", value: "Pro · renews Oct 3")
                        .qSurfaceRow()
                    Button("Restore purchases") {}
                        .foregroundStyle(QPalette.accent)
                        .qSurfaceRow()
                } header: {
                    Text("Subscription").qOverlineStyle()
                }

                Section {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy policy").foregroundStyle(QPalette.ink)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(QPalette.ink3)
                                .accessibilityHidden(true)
                        }
                    }
                    .qSurfaceRow()
                }

                Section {
                    Button("Sign out") {}
                        .foregroundStyle(QPalette.ink)
                        .qSurfaceRow()
                    Button("Delete account", role: .destructive) { confirmDelete = true }
                        .foregroundStyle(QPalette.negative)
                        .qSurfaceRow()
                } footer: {
                    Text("Quiet 4.2.0 (1182)")
                        .font(.dsFootnote)
                        .foregroundStyle(QPalette.ink2)
                        .frame(maxWidth: .infinity)
                        .padding(.top, QSpace.xl)
                }
            }
            .listStyle(.insetGrouped)
            .qCanvasBackground()
            .navigationTitle("Settings")
            .tint(QPalette.ink)
            .sensoryFeedback(.selection, trigger: dailyReminder)
            .sensoryFeedback(.selection, trigger: weeklyReport)
            .confirmationDialog("Delete your account?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) {}
                Button("Keep my account", role: .cancel) {}
            } message: {
                Text("Your journals and settings will be permanently removed. This can't be undone.")
            }
        }
    }
}

#Preview("Light") { SettingsScreen() }
#Preview("Dark") { SettingsScreen().preferredColorScheme(.dark) }
#Preview("Large text") { SettingsScreen().dynamicTypeSize(.accessibility2) }
