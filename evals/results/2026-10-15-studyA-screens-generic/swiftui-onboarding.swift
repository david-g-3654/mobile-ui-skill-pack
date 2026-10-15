import SwiftUI

// MARK: - Sample data

fileprivate struct OnboardingPage: Identifiable {
    enum Hero { case record, transcribe, summarize }
    let id: Int
    let hero: Hero
    let eyebrow: String
    let title: String
    let message: String
    let tint: Color
}

fileprivate enum SampleData {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0, hero: .record,
            eyebrow: "Capture",
            title: "Talk. We’ll take the notes.",
            message: "Tap once to record a thought, a meeting, or a lecture. Works offline and keeps going with the screen locked.",
            tint: .indigo
        ),
        OnboardingPage(
            id: 1, hero: .transcribe,
            eyebrow: "Transcribe",
            title: "Every word, ready to search",
            message: "Accurate transcripts in 40+ languages, with speakers labeled and timestamps you can tap to replay.",
            tint: .teal
        ),
        OnboardingPage(
            id: 2, hero: .summarize,
            eyebrow: "Summarize",
            title: "Key points and to‑dos, done for you",
            message: "Get a clean summary and action items the moment you stop recording. Your audio stays on your device unless you choose to sync.",
            tint: .orange
        )
    ]

    static let transcriptLines: [(speaker: String, time: String, text: String)] = [
        ("Maya", "0:42", "Let’s move the launch to the 14th so QA has a full week."),
        ("Jordan", "0:51", "Works for me. I’ll update the release checklist today."),
        ("Maya", "1:03", "And can someone confirm the venue for the demo?")
    ]

    static let summaryPoints: [String] = [
        "Launch moved to Thursday, Nov 14",
        "QA gets one extra week of testing"
    ]

    static let actionItems: [(owner: String, task: String, done: Bool)] = [
        ("Jordan", "Update release checklist", true),
        ("Priya", "Confirm demo venue", false)
    ]
}

// MARK: - Root screen

struct S_onboarding: View {
    @State private var selection: Int = 0
    @State private var showingStart = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let pages = SampleData.pages

    init() {}

    private var isLastPage: Bool { selection == pages.count - 1 }
    private var currentTint: Color { pages[selection].tint }

    var body: some View {
        ZStack {
            BackgroundGlow(tint: currentTint)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                TabView(selection: $selection) {
                    ForEach(pages) { page in
                        PageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selection)

                bottomControls
            }
        }
        .tint(currentTint)
        .animation(.easeInOut(duration: 0.35), value: selection)
        .sheet(isPresented: $showingStart) {
            PermissionSheet(tint: currentTint)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var topBar: some View {
        HStack {
            Label {
                Text("Echo Notes")
                    .font(.headline)
            } icon: {
                Image(systemName: "waveform")
                    .foregroundStyle(currentTint)
                    .fontWeight(.semibold)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            Spacer()

            if !isLastPage {
                Button("Skip") {
                    withAnimation { selection = pages.count - 1 }
                }
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(minHeight: 44)
                .accessibilityHint("Jumps to the last introduction page")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .frame(minHeight: 44)
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            PageDots(count: pages.count, selection: selection, tint: currentTint)

            Button {
                if isLastPage {
                    showingStart = true
                } else {
                    withAnimation { selection += 1 }
                }
            } label: {
                Text(isLastPage ? "Get Started" : "Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .contentTransition(.opacity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.capsule)

            if isLastPage {
                Button("I already have an account") {}
                    .font(.subheadline.weight(.medium))
                    .frame(minHeight: 44)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(.bar.opacity(dynamicTypeSize.isAccessibilitySize ? 1 : 0))
    }
}

// MARK: - Page

fileprivate struct PageView: View {
    let page: OnboardingPage
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack(spacing: dynamicTypeSize.isAccessibilitySize ? 20 : 32) {
                HeroView(hero: page.hero, tint: page.tint)
                    .frame(maxWidth: 420)
                    .accessibilityHidden(true)

                VStack(spacing: 12) {
                    Text(page.eyebrow.uppercased())
                        .font(.footnote.weight(.semibold))
                        .tracking(1.2)
                        .foregroundStyle(page.tint)

                    Text(page.title)
                        .font(.largeTitle.weight(.bold))
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text(page.message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - Heroes

fileprivate struct HeroView: View {
    let hero: OnboardingPage.Hero
    let tint: Color

    var body: some View {
        switch hero {
        case .record: RecordHero(tint: tint)
        case .transcribe: TranscriptHero(tint: tint)
        case .summarize: SummaryHero(tint: tint)
        }
    }
}

fileprivate struct RecordHero: View {
    let tint: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var buttonSize: CGFloat = 84

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                ForEach(0..<3) { ring in
                    Circle()
                        .stroke(tint.opacity(0.18 - Double(ring) * 0.05), lineWidth: 1.5)
                        .frame(width: min(buttonSize, 120) + CGFloat(ring + 1) * 34)
                }
                Circle()
                    .fill(tint.gradient)
                    .frame(width: min(buttonSize, 120), height: min(buttonSize, 120))
                    .shadow(color: tint.opacity(0.4), radius: 18, y: 8)
                Image(systemName: "mic.fill")
                    .font(.system(size: min(buttonSize, 120) * 0.38, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
            }
            .frame(height: min(buttonSize, 120) + 110)

            Waveform(tint: tint, animated: !reduceMotion)
                .frame(height: 44)
                .padding(.horizontal, 12)

            HStack(spacing: 8) {
                Circle().fill(.red).frame(width: 8, height: 8)
                Text("Recording · 02:17")
                    .font(.subheadline.monospacedDigit().weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

fileprivate struct Waveform: View {
    let tint: Color
    let animated: Bool
    private let barCount = 32

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !animated)) { context in
            let t = animated ? context.date.timeIntervalSinceReferenceDate : 0
            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<barCount, id: \.self) { i in
                    let phase = Double(i) * 0.45
                    let base = 0.35 + 0.3 * sin(Double(i) * 0.7)
                    let wobble = 0.35 * abs(sin(t * 3 + phase))
                    Capsule()
                        .fill(tint.opacity(0.35 + 0.65 * (base + wobble) / 1.0))
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .scaleEffect(x: 1, y: max(0.12, min(1, base + wobble)), anchor: .center)
                }
            }
        }
    }
}

fileprivate struct HeroCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06))
            )
            .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
    }
}

fileprivate struct TranscriptHero: View {
    let tint: Color
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var lines: [(speaker: String, time: String, text: String)] {
        let all = SampleData.transcriptLines
        return dynamicTypeSize.isAccessibilitySize ? Array(all.prefix(1)) : all
    }

    var body: some View {
        HeroCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Product sync", systemImage: "person.2.wave.2.fill")
                        .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 8)
                    Text("EN")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(tint.opacity(0.15), in: Capsule())
                        .foregroundStyle(tint)
                }

                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(line.speaker)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(index.isMultiple(of: 2) ? tint : .purple)
                            Text(line.time)
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.tertiary)
                        }
                        Text(highlighted(line.text, index: index))
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("“launch”")
                    Spacer()
                    Text("3 matches")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(10)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }

    private func highlighted(_ text: String, index: Int) -> AttributedString {
        var attr = AttributedString(text)
        if let range = attr.range(of: "launch") {
            attr[range].backgroundColor = tint.opacity(0.25)
            attr[range].font = .subheadline.weight(.semibold)
        }
        return attr
    }
}

fileprivate struct SummaryHero: View {
    let tint: Color

    var body: some View {
        HeroCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(tint)
                    Text("Summary")
                        .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 8)
                    Text("12 min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(SampleData.summaryPoints, id: \.self) { point in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Circle().fill(tint).frame(width: 6, height: 6)
                            Text(point)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Divider()

                Text("Action items")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(SampleData.actionItems, id: \.task) { item in
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.done ? tint : .secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.task)
                                    .font(.subheadline)
                                    .strikethrough(item.done, color: .secondary)
                                    .foregroundStyle(item.done ? .secondary : .primary)
                                Text(item.owner)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Label("Processed on device", systemImage: "lock.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Chrome

fileprivate struct PageDots: View {
    let count: Int
    let selection: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == selection ? AnyShapeStyle(tint) : AnyShapeStyle(Color.secondary.opacity(0.3)))
                    .frame(width: i == selection ? 22 : 8, height: 8)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Page \(selection + 1) of \(count)")
    }
}

fileprivate struct BackgroundGlow: View {
    let tint: Color

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            RadialGradient(
                colors: [tint.opacity(0.22), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 480
            )
        }
    }
}

// MARK: - Permission sheet

fileprivate struct PermissionSheet: View {
    let tint: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "mic.badge.plus")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(tint)
                    .padding(.top, 24)
                    .accessibilityHidden(true)

                Text("Allow microphone access")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Echo Notes needs your microphone to record. Recordings are stored on this iPhone and are never used to train models.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 10) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Allow Microphone")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)

                    Button("Not Now") { dismiss() }
                        .frame(minHeight: 44)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .tint(tint)
    }
}

#Preview {
    S_onboarding()
}
