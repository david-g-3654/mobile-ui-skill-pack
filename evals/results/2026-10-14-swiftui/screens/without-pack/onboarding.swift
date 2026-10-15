import SwiftUI

// MARK: - Sample data

fileprivate struct OnboardingPage: Identifiable {
    let id: Int
    let eyebrow: String
    let title: String
    let subtitle: String
    let accent: Color
}

fileprivate enum SampleData {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            eyebrow: "Capture",
            title: "Just talk.\nWe’ll take the notes.",
            subtitle: "Record a thought, a meeting, or a 2am idea. Echo transcribes it as you speak — even offline.",
            accent: Color(red: 0.42, green: 0.36, blue: 0.98)
        ),
        OnboardingPage(
            id: 1,
            eyebrow: "Understand",
            title: "Rambling in.\nClarity out.",
            subtitle: "AI turns messy voice memos into clean summaries, key points, and action items you can actually use.",
            accent: Color(red: 0.98, green: 0.45, blue: 0.36)
        ),
        OnboardingPage(
            id: 2,
            eyebrow: "Recall",
            title: "Ask your notes\nanything.",
            subtitle: "“What did Priya say about the launch date?” Get answers from everything you’ve ever recorded.",
            accent: Color(red: 0.16, green: 0.72, blue: 0.58)
        )
    ]

    static let transcriptLines: [String] = [
        "Okay so for the Q3 launch, I think we",
        "should move the beta to August 12th and",
        "loop in Marcus on the pricing page…"
    ]

    static let summaryPoints: [(icon: String, text: String)] = [
        ("calendar", "Beta moves to Aug 12"),
        ("person.2", "Loop in Marcus on pricing"),
        ("checkmark.circle", "Draft launch email by Fri")
    ]

    static let recentNotes: [(title: String, meta: String)] = [
        ("Product sync — launch plan", "Tue · 14 min"),
        ("1:1 with Priya", "Mon · 22 min"),
        ("Gift ideas for Mom", "Sun · 1 min")
    ]
}

// MARK: - Root screen

struct S_onboarding: View {
    @State private var page: Int = 0
    @State private var showPermissionSheet = false
    @State private var finished = false

    init() {}

    private var pages: [OnboardingPage] { SampleData.pages }
    private var current: OnboardingPage { pages[page] }
    private var isLast: Bool { page == pages.count - 1 }

    var body: some View {
        ZStack {
            BackgroundGlow(color: current.accent)
                .animation(.easeInOut(duration: 0.6), value: page)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                TabView(selection: $page) {
                    ForEach(pages) { p in
                        PageView(page: p, isActive: p.id == page)
                            .tag(p.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                footer
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
            }
        }
        .sheet(isPresented: $showPermissionSheet) {
            MicPermissionSheet(accent: current.accent) {
                showPermissionSheet = false
                finished = true
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .overlay {
            if finished {
                FinishedOverlay(accent: current.accent) {
                    withAnimation(.spring) { finished = false; page = 0 }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: finished)
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(current.accent.gradient)
                        .frame(width: 30, height: 30)
                    Image(systemName: "waveform")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text("Echo")
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Echo")

            Spacer()

            if !isLast {
                Button("Skip") {
                    withAnimation(.snappy) { page = pages.count - 1 }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(minHeight: 44)
            }
        }
        .frame(height: 44)
    }

    private var footer: some View {
        VStack(spacing: 18) {
            PageDots(count: pages.count, index: page, accent: current.accent)

            Button {
                if isLast {
                    showPermissionSheet = true
                } else {
                    withAnimation(.snappy) { page += 1 }
                }
            } label: {
                HStack(spacing: 8) {
                    if isLast {
                        Image(systemName: "mic.fill")
                    }
                    Text(isLast ? "Start recording" : "Continue")
                    if !isLast {
                        Image(systemName: "arrow.right")
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(current.accent.gradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: current.accent.opacity(0.35), radius: 16, y: 8)
            }
            .buttonStyle(PressableStyle())
            .sensoryFeedback(.impact(weight: .light), trigger: page)

            Text(isLast ? "Free for 30 min of transcription a month. No account needed." : "Already have an account? **Sign in**")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(minHeight: 20)
        }
    }
}

// MARK: - Page

fileprivate struct PageView: View {
    let page: OnboardingPage
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 12)

            Group {
                switch page.id {
                case 0: CaptureIllustration(accent: page.accent, animate: isActive)
                case 1: SummaryIllustration(accent: page.accent)
                default: RecallIllustration(accent: page.accent)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)

            Spacer(minLength: 24)

            Text(page.eyebrow.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.6)
                .foregroundStyle(page.accent)
                .padding(.bottom, 10)

            Text(page.title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 12)

            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 16)
        }
        .padding(.horizontal, 24)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Illustrations

fileprivate struct CaptureIllustration: View {
    let accent: Color
    let animate: Bool

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                PulseRings(color: accent, active: animate)
                Circle()
                    .fill(accent.gradient)
                    .frame(width: 92, height: 92)
                    .shadow(color: accent.opacity(0.45), radius: 20, y: 10)
                Image(systemName: "mic.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(height: 150)

            LiveWaveform(color: accent, active: animate)
                .frame(height: 36)
                .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle().fill(.red).frame(width: 7, height: 7)
                    Text("REC  00:42")
                        .font(.caption2.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                ForEach(Array(SampleData.transcriptLines.enumerated()), id: \.offset) { i, line in
                    Text(line)
                        .font(.footnote)
                        .foregroundStyle(i == SampleData.transcriptLines.count - 1 ? .primary : .secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .accessibilityHidden(true)
    }
}

fileprivate struct SummaryIllustration: View {
    let accent: Color

    var body: some View {
        ZStack {
            // Back card: raw memo
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "waveform").foregroundStyle(.secondary)
                    Text("Voice memo · 3:12").font(.caption).foregroundStyle(.secondary)
                }
                ForEach(0..<4, id: \.self) { i in
                    Capsule().fill(Color.secondary.opacity(0.2))
                        .frame(width: [220, 180, 240, 140][i], height: 8)
                }
            }
            .padding(16)
            .frame(width: 280, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .rotationEffect(.degrees(-6))
            .offset(x: -18, y: -70)

            // Front card: AI summary
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(accent)
                    Text("Summary")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("Product sync")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Divider()
                ForEach(SampleData.summaryPoints, id: \.text) { item in
                    HStack(spacing: 10) {
                        Image(systemName: item.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(accent)
                            .frame(width: 26, height: 26)
                            .background(accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                        Text(item.text)
                            .font(.subheadline)
                    }
                }
            }
            .padding(18)
            .frame(width: 290, alignment: .leading)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 24, y: 12)
            .offset(y: 40)
        }
        .accessibilityHidden(true)
    }
}

fileprivate struct RecallIllustration: View {
    let accent: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer(minLength: 48)
                Text("What did Priya say about the launch date?")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(accent, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles").foregroundStyle(accent)
                    Text("From “1:1 with Priya”, Monday")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text("She’s fine with August 12 as long as the onboarding copy is final by the 5th.")
                    .font(.subheadline)
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundStyle(accent)
                    StaticWaveform(color: accent)
                        .frame(height: 18)
                    Text("8:14")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.trailing, 32)

            VStack(spacing: 0) {
                ForEach(Array(SampleData.recentNotes.enumerated()), id: \.offset) { i, note in
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.secondary)
                        Text(note.title).font(.footnote.weight(.medium))
                        Spacer()
                        Text(note.meta).font(.caption2).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    if i < SampleData.recentNotes.count - 1 { Divider() }
                }
            }
            .padding(.horizontal, 14)
            .background(Color(.secondarySystemBackground).opacity(0.7), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(0.85)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Waveforms & effects

fileprivate struct LiveWaveform: View {
    let color: Color
    let active: Bool
    private let barCount = 32

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !active)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<barCount, id: \.self) { i in
                    let d = Double(i)
                    let v = abs(sin(t * 3.1 + d * 0.55)) * 0.6 + abs(sin(t * 1.7 + d * 1.3)) * 0.4
                    Capsule()
                        .fill(color.opacity(0.35 + 0.65 * v))
                        .frame(maxWidth: .infinity)
                        .frame(height: max(4, 36 * v))
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

fileprivate struct StaticWaveform: View {
    let color: Color
    private let heights: [CGFloat] = [0.3, 0.6, 0.9, 0.5, 0.7, 1.0, 0.4, 0.8, 0.55, 0.35, 0.75, 0.5, 0.9, 0.3, 0.6, 0.45, 0.8, 0.4]

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(heights.indices, id: \.self) { i in
                    Capsule()
                        .fill(i < 7 ? color : color.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height * heights[i])
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

fileprivate struct PulseRings: View {
    let color: Color
    let active: Bool
    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(color.opacity(0.25), lineWidth: 1.5)
                    .frame(width: 92, height: 92)
                    .scaleEffect(pulse ? 1.0 + CGFloat(i + 1) * 0.28 : 1.0)
                    .opacity(pulse ? 0.0 : 0.9)
                    .animation(
                        reduceMotion ? nil :
                            .easeOut(duration: 2.2).repeatForever(autoreverses: false).delay(Double(i) * 0.5),
                        value: pulse
                    )
            }
        }
        .onAppear { if active && !reduceMotion { pulse = true } }
    }
}

fileprivate struct BackgroundGlow: View {
    let color: Color

    var body: some View {
        ZStack {
            Color(.systemBackground)
            Circle()
                .fill(color.opacity(0.22))
                .frame(width: 420, height: 420)
                .blur(radius: 90)
                .offset(x: 120, y: -260)
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -140, y: 60)
        }
        .ignoresSafeArea()
    }
}

fileprivate struct PageDots: View {
    let count: Int
    let index: Int
    let accent: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == index ? accent : Color.secondary.opacity(0.25))
                    .frame(width: i == index ? 22 : 7, height: 7)
            }
        }
        .animation(.snappy, value: index)
        .accessibilityElement()
        .accessibilityLabel("Page \(index + 1) of \(count)")
    }
}

fileprivate struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Permission sheet

fileprivate struct MicPermissionSheet: View {
    let accent: Color
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "mic.badge.plus")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(accent)
                .padding(.top, 28)

            Text("Echo needs your microphone")
                .font(.title3.weight(.bold))

            VStack(alignment: .leading, spacing: 12) {
                PermissionRow(icon: "lock.fill", text: "Audio is processed on-device whenever possible.", accent: accent)
                PermissionRow(icon: "hand.raised.fill", text: "We never record unless you tap the mic.", accent: accent)
                PermissionRow(icon: "trash.fill", text: "Delete any note — and its audio — anytime.", accent: accent)
            }
            .padding(.horizontal, 8)

            Spacer(minLength: 0)

            Button(action: onContinue) {
                Text("Allow microphone")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PressableStyle())

            Button("Not now", action: onContinue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(minHeight: 44)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

fileprivate struct PermissionRow: View {
    let icon: String
    let text: String
    let accent: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(accent)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

fileprivate struct FinishedOverlay: View {
    let accent: Color
    let onReset: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(accent)
                    .symbolEffect(.bounce, value: true)
                Text("You’re all set")
                    .font(.title.weight(.bold))
                Text("Tap the mic anytime to capture your first note.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Replay onboarding", action: onReset)
                    .font(.subheadline.weight(.semibold))
                    .tint(accent)
                    .padding(.top, 8)
            }
            .padding(32)
        }
    }
}
