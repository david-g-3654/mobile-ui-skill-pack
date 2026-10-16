import SwiftUI

struct S_onboarding: View {
    @State private var showsSample = false

    init() {}

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xxl) {
                    Label("Thread", systemImage: "waveform")
                        .font(.dsHeadline)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityLabel("Thread, AI voice notes")

                    VStack(alignment: .leading, spacing: QSpace.md) {
                        Text("Think out loud.\nKeep what matters.")
                            .font(.dsLargeTitle)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)

                        Text("Your voice becomes clear notes, thoughtful summaries, and next steps. Let AI do the tidying.")
                            .font(.dsSubhead)
                            .foregroundStyle(QPalette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    ThoughtPreview()

                    QLargeTextFooter { explorationNote }
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, QSpace.margin)
                .padding(.top, QSpace.xl)
                .padding(.bottom, QSpace.xl)
                .frame(maxWidth: .infinity)
            }
            .qCanvasBackground()
            .toolbar(.hidden, for: .navigationBar)
            .qBottomActionBar {
                Button("Try a sample") { showsSample = true }
                    .buttonStyle(.qPrimary)
                    .accessibilityHint("Explore a sample transcript and its AI summary")
            } footer: {
                explorationNote
            }
            .sheet(isPresented: $showsSample) {
                SampleThoughtSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(QRadius.xl)
            }
        }
        .tint(QPalette.ink)
        .foregroundStyle(QPalette.ink)
    }

    private var explorationNote: some View {
        Text("No account or microphone needed to try.")
            .font(.dsFootnote)
            .foregroundStyle(QPalette.ink2)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

fileprivate struct ThoughtPreview: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: QSpace.lg) {
            VStack(alignment: .leading, spacing: QSpace.xxs) {
                Text("A thought on the way home")
                    .font(.dsHeadline)
                Text("Sample voice note · 38 seconds")
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
            }

            VoiceTrace()
                .frame(height: QSpace.xxxl)
                .accessibilityHidden(true)

            Divider().overlay(QPalette.hairline)

            VStack(alignment: .leading, spacing: QSpace.sm) {
                Text("A little distance. A fresh idea.")
                    .font(.dsHeadline)
                    .accessibilityAddTraits(.isHeader)
                Text("Take the weekly design catch-up outside. A short walk could make room for better ideas.")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                    .fixedSize(horizontal: false, vertical: true)

                Label("Ask Maya about a Friday walk", systemImage: "circle")
                    .font(.dsFootnote)
                    .padding(.top, QSpace.xxs)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Suggested next step: Ask Maya about a Friday walk")
            }
        }
        .padding(typeSize.isAccessibilitySize ? QSpace.md : QSpace.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
    }
}

fileprivate struct VoiceTrace: View {
    private let levels: [CGFloat] = [
        0.18, 0.3, 0.48, 0.28, 0.64, 0.82, 0.5, 0.34,
        0.62, 0.94, 0.72, 0.4, 0.26, 0.54, 0.78, 1,
        0.66, 0.42, 0.22, 0.38, 0.7, 0.88, 0.6, 0.32,
        0.5, 0.76, 0.96, 0.7, 0.4, 0.58, 0.8, 0.46,
        0.28, 0.5, 0.34, 0.22, 0.14
    ]

    var body: some View {
        HStack(spacing: QSpace.xxs) {
            ForEach(levels.indices, id: \.self) { index in
                Capsule()
                    .fill(QPalette.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: QSpace.xxxl * levels[index])
            }
        }
    }
}

fileprivate struct SampleThoughtSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selection = SampleVersion.summary

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xl) {
                    Picker("Note version", selection: $selection) {
                        ForEach(SampleVersion.allCases) { version in
                            Text(version.rawValue).tag(version)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: QSpace.sm) {
                        Text(selection == .summary ? "The idea, untangled" : "Just as it was spoken")
                            .font(.dsHeadline)
                            .accessibilityAddTraits(.isHeader)
                        Text(selection == .summary ? summary : transcript)
                            .font(.dsSubhead)
                            .foregroundStyle(QPalette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if selection == .summary {
                        VStack(alignment: .leading, spacing: QSpace.xs) {
                            Text("Suggested next step")
                                .font(.dsHeadline)
                                .accessibilityAddTraits(.isHeader)
                            Text("Ask Maya if she’s free for a 20-minute walk on Friday.")
                                .font(.dsSubhead)
                                .foregroundStyle(QPalette.ink2)
                        }
                    }

                    Text("An example of how Thread organizes a voice note.")
                        .font(.dsFootnote)
                        .foregroundStyle(QPalette.ink2)
                }
                .padding(QSpace.margin)
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .qCanvasBackground()
            .navigationTitle("A thought on the way home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(QPalette.ink)
        .foregroundStyle(QPalette.ink)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private let summary = "Move the weekly design catch-up outdoors. A 20-minute walk could help the team step away from screens and share fresh ideas, without slides or a formal agenda."
    private let transcript = "I was thinking, maybe we should take the design catch-up outside sometimes. We spend so much of the week looking at the same screens. Even twenty minutes around the neighborhood might help. No slides, no agenda, just whatever ideas come up. I should ask Maya if she’s around on Friday. We could try it once and see how it feels."
}

fileprivate enum SampleVersion: String, CaseIterable, Identifiable {
    case summary = "AI summary"
    case transcript = "Transcript"

    var id: Self { self }
}

#Preview("Light") {
    S_onboarding().preferredColorScheme(.light)
}

#Preview("Dark") {
    S_onboarding().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_onboarding().dynamicTypeSize(.accessibility2)
}
