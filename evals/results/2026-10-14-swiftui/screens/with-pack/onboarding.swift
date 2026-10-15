// Screen.swift — Onboarding (single welcome + value list) for "Murmur", an AI voice notes app.
//
// Archetype: Onboarding. Job: get a new user to their first recording.
// Focal: the outcome headline. Primary: "Start recording" (pinned).
// Cutting: multi-page carousel, permission prompts at launch (mic is asked in context
// on the first recording), account creation (late — "Log in" is secondary).
// Uses the pack's default Quiet skin (DesignSystem.swift / Components.swift).

import SwiftUI

// MARK: - Sample data

fileprivate struct OnboardingValueProp: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let subtitle: String
}

fileprivate struct SampleNote {
    let title: String
    let meta: String
    let duration: String
    let summary: String
    let actionItems: [String]
    /// Normalised amplitudes, 0...1.
    let levels: [CGFloat]
    /// Fraction of the clip already played.
    let playedFraction: CGFloat
}

fileprivate enum OnboardingContent {
    static let headline = "Say it once.\nFind it forever."
    static let subhead = "Murmur turns rambling voice memos into clean notes, summaries and to-dos."

    static let valueProps: [OnboardingValueProp] = [
        .init(systemImage: "waveform",
              title: "Record anything",
              subtitle: "Meetings, lectures, ideas on a walk"),
        .init(systemImage: "text.magnifyingglass",
              title: "Ask your notes",
              subtitle: "“What did Priya say about the launch date?”"),
        .init(systemImage: "square.and.arrow.up",
              title: "Send it anywhere",
              subtitle: "Notion, Apple Notes, email or Slack"),
    ]

    static let note = SampleNote(
        title: "Kitchen remodel call with Marco",
        meta: "Today, 9:41 AM",
        duration: "6:12",
        summary: "Quartz counters approved. Cabinet delivery slips to May 14; Marco needs the tile choice by Friday.",
        actionItems: ["Pick backsplash tile by Fri", "Send deposit of $1,850"],
        levels: [0.22, 0.38, 0.55, 0.30, 0.72, 0.90, 0.64, 0.41, 0.28, 0.50,
                 0.83, 0.97, 0.70, 0.46, 0.33, 0.58, 0.76, 0.52, 0.36, 0.24,
                 0.44, 0.68, 0.88, 0.62, 0.40, 0.31, 0.54, 0.79, 0.57, 0.35,
                 0.26, 0.47, 0.66, 0.43, 0.29, 0.20],
        playedFraction: 0.42
    )
}

// MARK: - Screen

struct S_onboarding: View {
    @State private var showLogin = false
    @State private var startedTrigger = 0

    init() {}

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xxl) {
                    header
                    NotePreviewCard(note: OnboardingContent.note)
                    valueList
                }
                .padding(.horizontal, Space.margin)
                .padding(.top, Space.xl)
                .padding(.bottom, Space.xl)
            }
            .canvasBackground()
            .toolbar(.hidden, for: .navigationBar)
            .bottomActionBar {
                Button("Start recording") { startedTrigger += 1 }
                    .buttonStyle(.primary)
                    .sensoryFeedback(.success, trigger: startedTrigger)
                Button("I already have an account") { showLogin = true }
                    .buttonStyle(.tertiary)
                Text("By continuing you agree to the [Terms](https://example.com/terms) and [Privacy Policy](https://example.com/privacy).")
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.ink2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $showLogin) {
                LoginSheet()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(Radius.xl)
            }
        }
        .tint(Palette.ink)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text("Murmur")
                .overlineStyle()
            Text(OnboardingContent.headline)
                .font(.dsLargeTitle)
                .fontDesign(.serif)
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(OnboardingContent.subhead)
                .font(.dsBody)
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var valueList: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            ForEach(OnboardingContent.valueProps) { prop in
                ValuePropRow(prop: prop)
            }
        }
    }
}

// MARK: - Value prop row

fileprivate struct ValuePropRow: View {
    let prop: OnboardingValueProp
    @ScaledMetric(relativeTo: .body) private var glyphWidth: CGFloat = 28

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.md) {
            Image(systemName: prop.systemImage)
                .font(.dsBody)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Palette.ink)
                .frame(width: glyphWidth, alignment: .leading)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(prop.title)
                    .font(.dsHeadline)
                    .foregroundStyle(Palette.ink)
                Text(prop.subtitle)
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Note preview (the "what you get" object)

fileprivate struct NotePreviewCard: View {
    let note: SampleNote

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text(note.title)
                        .font(.dsHeadline)
                        .foregroundStyle(Palette.ink)
                    Text(note.meta)
                        .font(.dsFootnote)
                        .foregroundStyle(Palette.ink2)
                }
                Spacer(minLength: Space.sm)
                Text(note.duration)
                    .font(.dsFootnote)
                    .monospacedDigit()
                    .foregroundStyle(Palette.ink2)
            }

            Waveform(levels: note.levels, playedFraction: note.playedFraction)
                .frame(height: Space.xxl)
                .accessibilityLabel("Recording, \(note.duration) long")

            Divider().overlay(Palette.hairline)

            VStack(alignment: .leading, spacing: Space.xs) {
                Text("Summary")
                    .overlineStyle()
                Text(note.summary)
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: Space.xs) {
                ForEach(note.actionItems, id: \.self) { item in
                    Label {
                        Text(item)
                            .font(.dsSubhead)
                            .foregroundStyle(Palette.ink)
                    } icon: {
                        Image(systemName: "circle")
                            .font(.dsSubhead)
                            .foregroundStyle(Palette.ink2)
                    }
                }
            }
        }
        .padding(Space.lg)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Example note")
    }
}

fileprivate struct Waveform: View {
    let levels: [CGFloat]
    let playedFraction: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false

    var body: some View {
        GeometryReader { proxy in
            let count = max(levels.count, 1)
            let gap = Space.xxs
            let barWidth = max(2, (proxy.size.width - gap * CGFloat(count - 1)) / CGFloat(count))
            HStack(alignment: .center, spacing: gap) {
                ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                    let played = CGFloat(index) / CGFloat(count) < playedFraction
                    let scale: CGFloat = (played || reduceMotion) ? 1 : (breathing ? 1 : 0.8)
                    Capsule()
                        .fill(played ? Palette.accent : Palette.ink3)
                        .frame(width: barWidth, height: max(barWidth, proxy.size.height * level * scale))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                breathing = true
            }
        }
    }
}

// MARK: - Login sheet

fileprivate struct LoginSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Space.md) {
                Text("Welcome back")
                    .font(.dsTitle)
                    .foregroundStyle(Palette.ink)
                Text("Your notes sync from iCloud once you sign in.")
                    .font(.dsBody)
                    .foregroundStyle(Palette.ink2)
                Spacer(minLength: Space.md)
                Button {
                    dismiss()
                } label: {
                    Label("Continue with Apple", systemImage: "apple.logo")
                }
                .buttonStyle(.primary)
                Button("Use email instead") { dismiss() }
                    .buttonStyle(.secondary)
            }
            .padding(Space.margin)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.canvas.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    S_onboarding()
}

#Preview("Dark") {
    S_onboarding()
        .preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_onboarding()
        .dynamicTypeSize(.accessibility2)
}
