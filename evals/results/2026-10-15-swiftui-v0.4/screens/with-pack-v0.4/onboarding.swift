// Onboarding — single welcome + value list, then an in-context microphone pre-prompt.
// Job: get a new user to record their first note. Focal: the outcome headline.
// Primary: "Record a note". Cut: feature carousel, account creation up front.

import SwiftUI

// MARK: - Sample data

fileprivate struct ValueProp: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let detail: String
}

fileprivate let valueProps: [ValueProp] = [
    ValueProp(systemImage: "waveform",
              title: "Talk for as long as you like",
              detail: "Walks, commutes, 2-hour meetings"),
    ValueProp(systemImage: "text.badge.checkmark",
              title: "Get the gist, not a transcript",
              detail: "Summaries, decisions and to-dos pulled out"),
    ValueProp(systemImage: "magnifyingglass",
              title: "Find what you said in March",
              detail: "Search every note by meaning, not keywords"),
]

fileprivate struct SampleNote {
    let title: String
    let meta: String
    let summary: String
    let todo: String
    let bars: [CGFloat]
}

fileprivate let sampleNote = SampleNote(
    title: "Kitchen reno call with Dario",
    meta: "Today, 8:14 AM · 6:42",
    summary: "Cabinets slip to Oct 28. Tile stays the same; quote is $1,186.40 over.",
    todo: "Send Dario the fridge dimensions",
    bars: [8, 16, 24, 12, 28, 20, 8, 16, 32, 24, 12, 20, 28, 16, 8, 12, 24, 20, 12, 8, 16, 28, 20, 12]
)

// MARK: - Root

struct S_onboarding: View {
    @State private var path: [Step] = []

    init() {}

    fileprivate enum Step: Hashable { case microphone }

    var body: some View {
        NavigationStack(path: $path) {
            WelcomePage { path.append(.microphone) }
                .navigationDestination(for: Step.self) { _ in
                    MicrophonePage()
                }
        }
        .tint(QPalette.ink)
    }
}

// MARK: - Welcome

fileprivate struct WelcomePage: View {
    let onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xxl) {
                VStack(alignment: .leading, spacing: QSpace.sm) {
                    Text("Murmur")
                        .qOverlineStyle()
                    Text("Say it messy.\nRead it back clear.")
                        .font(.dsLargeTitle)
                        .foregroundStyle(QPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text("Speak your thoughts and Murmur turns them into tidy notes you can search.")
                        .font(.dsSubhead)
                        .foregroundStyle(QPalette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                NotePreviewCard(note: sampleNote)

                VStack(alignment: .leading, spacing: QSpace.xl) {
                    ForEach(valueProps) { prop in
                        ValuePropRow(prop: prop)
                    }
                }

                QLargeTextFooter { WelcomeFooter() }
            }
            .padding(.horizontal, QSpace.margin)
            .padding(.top, QSpace.xl)
            .padding(.bottom, QSpace.xl)
        }
        .qCanvasBackground()
        .toolbar(.hidden, for: .navigationBar)
        .qBottomActionBar {
            Button(action: onStart) {
                Label("Record a note", systemImage: "mic.fill")
            }
            .buttonStyle(.qPrimary)
        } footer: {
            WelcomeFooter()
        }
    }
}

fileprivate struct WelcomeFooter: View {
    var body: some View {
        VStack(spacing: QSpace.xxs) {
            Button("I already have an account") {}
                .buttonStyle(.qTertiary)
            Text("By continuing you agree to the [Terms](https://example.com/terms) and [Privacy Policy](https://example.com/privacy).")
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

fileprivate struct ValuePropRow: View {
    let prop: ValueProp

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: QSpace.md) {
            Image(systemName: prop.systemImage)
                .font(.dsHeadline)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(QPalette.ink)
                .frame(width: QSpace.xl)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: QSpace.xxs) {
                Text(prop.title)
                    .font(.dsHeadline)
                    .foregroundStyle(QPalette.ink)
                Text(prop.detail)
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

/// A finished note, so the user sees the outcome before recording anything.
fileprivate struct NotePreviewCard: View {
    let note: SampleNote

    var body: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            HStack(alignment: .center, spacing: QSpace.sm) {
                Waveform(bars: note.bars)
                    .accessibilityHidden(true)
                Text(note.meta)
                    .font(.dsFootnote)
                    .monospacedDigit()
                    .foregroundStyle(QPalette.ink2)
                    .lineLimit(1)
                    .layoutPriority(1)
            }
            Text(note.title)
                .font(.dsHeadline)
                .foregroundStyle(QPalette.ink)
            Text(note.summary)
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
                .fixedSize(horizontal: false, vertical: true)
            Label {
                Text(note.todo)
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink)
            } icon: {
                Image(systemName: "circle")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.accent)
            }
            .accessibilityLabel("To-do: \(note.todo)")
        }
        .padding(QSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Example note")
    }
}

fileprivate struct Waveform: View {
    let bars: [CGFloat]
    @ScaledMetric(relativeTo: .footnote) private var scale: CGFloat = 1

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(Array(bars.enumerated()), id: \.offset) { _, height in
                Capsule()
                    .fill(QPalette.ink2)
                    .frame(width: 2, height: height * 0.6 * scale)
            }
        }
        .frame(height: 20 * scale)
        .clipped()
    }
}

// MARK: - Microphone pre-prompt

fileprivate struct MicrophonePage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false
    @State private var granted = false
    @ScaledMetric(relativeTo: .largeTitle) private var badgeSize: CGFloat = 96

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xxl) {
                ZStack {
                    Circle()
                        .fill(QPalette.accentSoft)
                        .scaleEffect(pulsing ? 1.12 : 1)
                    Image(systemName: granted ? "checkmark" : "mic.fill")
                        .font(.dsLargeTitle)
                        .foregroundStyle(QPalette.accent)
                        .contentTransition(.symbolEffect(.replace))
                }
                .frame(width: badgeSize, height: badgeSize)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: QSpace.sm) {
                    Text(granted ? "You're ready to record" : "Murmur listens only when you tap record")
                        .font(.dsLargeTitle)
                        .foregroundStyle(QPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text("Audio is transcribed on your iPhone. Nothing is recorded in the background, and you can delete any note for good.")
                        .font(.dsBody)
                        .foregroundStyle(QPalette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, QSpace.margin)
            .padding(.top, QSpace.xl)
        }
        .qCanvasBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Not now") {}
                    .buttonStyle(.qTertiary)
            }
        }
        .qBottomActionBar {
            Button(granted ? "Start recording" : "Allow microphone") {
                withAnimation(QMotion.snappy) { granted = true }
            }
            .buttonStyle(.qPrimary)
            .sensoryFeedback(.success, trigger: granted)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    S_onboarding()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    S_onboarding()
        .preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_onboarding()
        .dynamicTypeSize(.accessibility2)
}
