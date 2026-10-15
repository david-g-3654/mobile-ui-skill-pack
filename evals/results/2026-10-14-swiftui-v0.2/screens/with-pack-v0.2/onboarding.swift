// Screen.swift — Onboarding archetype (mobile-ui/references/screen-onboarding.md), default "Quiet" skin.
// Job: get a new user to their first recording. Focal: the outcome headline.
// Primary: "Record your first note" (pinned). Cut: carousel, feature list beyond 3, permission prompt at launch
// (microphone is asked in context, via a pre-prompt sheet, only after the user taps the primary action).

import SwiftUI

// MARK: - Sample content

fileprivate struct ValueProp: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let subtitle: String
}

fileprivate enum OnboardingContent {
    static let appName = "Murmur"
    static let headline = "Say it once.\nFind it forever."
    static let subhead = "Murmur turns rambling voice memos into clean notes, summaries and to-dos."

    static let props: [ValueProp] = [
        ValueProp(systemImage: "mic",
                  title: "Talk the way you think",
                  subtitle: "Up to 2 hours per note, even offline"),
        ValueProp(systemImage: "text.badge.checkmark",
                  title: "Get the gist in seconds",
                  subtitle: "Summaries and action items, written for you"),
        ValueProp(systemImage: "magnifyingglass",
                  title: "Search what you said",
                  subtitle: "Find any word across every recording"),
    ]

    // A realistic transcribed note, shown as a preview object.
    static let sampleTitle = "Tuesday standup"
    static let sampleMeta = "4:12 · Today, 9:41"
    static let sampleTranscript = "…so let’s move the Lisbon launch to the 18th, and Priya owns the press kit."
    static let sampleActions = "2 action items found"
    static let waveform: [CGFloat] = [
        0.25, 0.4, 0.7, 0.55, 0.9, 0.6, 0.35, 0.5, 0.8, 1.0, 0.65, 0.45,
        0.3, 0.55, 0.75, 0.5, 0.35, 0.6, 0.85, 0.7, 0.4, 0.3, 0.5, 0.25,
    ]
}

// MARK: - Screen

struct S_onboarding: View {
    @State private var showMicPrompt = false
    @State private var micAllowed = false

    init() {}

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xxl) {
                    header
                    NotePreviewCard()
                    valueList
                    LargeTextFooter { footer }
                }
                .padding(.horizontal, Space.margin)
                .padding(.top, Space.xxl)
                .padding(.bottom, Space.xl)
            }
            .canvasBackground()
            .toolbar(.hidden, for: .navigationBar)
            .bottomActionBar {
                Button("Record your first note") { showMicPrompt = true }
                    .buttonStyle(.primary)
            } footer: {
                footer
            }
            .sheet(isPresented: $showMicPrompt) {
                MicPrePrompt(
                    onAllow: {
                        micAllowed = true
                        showMicPrompt = false
                    },
                    onLater: { showMicPrompt = false }
                )
                .presentationDetents([.medium])
                .presentationCornerRadius(Radius.xl)
                .presentationBackground(Palette.canvas)
            }
            .sensoryFeedback(.success, trigger: micAllowed)
        }
        .tint(Palette.ink)
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text(OnboardingContent.headline)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(OnboardingContent.subhead)
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var valueList: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            ForEach(OnboardingContent.props) { prop in
                ValuePropRow(prop: prop)
            }
        }
    }

    @ViewBuilder private var footer: some View {
        HStack(spacing: Space.xxs) {
            Text("Already have an account?")
                .font(.dsFootnote)
                .foregroundStyle(Palette.ink2)
            Button("Log in") {}
                .buttonStyle(TertiaryButtonStyle(tint: Palette.ink))
        }
        Text("By continuing you agree to the [Terms](https://example.com/terms) and [Privacy Policy](https://example.com/privacy).")
            .font(.dsFootnote)
            .foregroundStyle(Palette.ink2)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Components

fileprivate struct ValuePropRow: View {
    let prop: ValueProp

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.md) {
            Image(systemName: prop.systemImage)
                .font(.body)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Palette.ink)
                .frame(width: Space.xl)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(prop.title)
                    .font(.dsHeadline)
                    .foregroundStyle(Palette.ink)
                Text(prop.subtitle)
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

/// A finished note as the user will see it — the product's value, shown instead of described.
fileprivate struct NotePreviewCard: View {
    var body: some View {
        ObjectCard {
            VStack(alignment: .leading, spacing: Space.sm) {
                HStack(alignment: .firstTextBaseline) {
                    Text(OnboardingContent.sampleTitle)
                        .font(.dsHeadline)
                        .foregroundStyle(Palette.ink)
                    Spacer(minLength: Space.xs)
                    Text(OnboardingContent.sampleMeta)
                        .font(.dsFootnote)
                        .monospacedDigit()
                        .foregroundStyle(Palette.ink2)
                }
                Waveform(levels: OnboardingContent.waveform)
                    .frame(height: Space.xxl)
                    .accessibilityHidden(true)
                Text(OnboardingContent.sampleTranscript)
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Label(OnboardingContent.sampleActions, systemImage: "checklist")
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.ink2)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Example note: \(OnboardingContent.sampleTitle), \(OnboardingContent.sampleTranscript) \(OnboardingContent.sampleActions)")
    }
}

fileprivate struct Waveform: View {
    let levels: [CGFloat]

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: Space.xxs) {
                ForEach(levels.indices, id: \.self) { i in
                    Capsule()
                        .fill(Palette.accent)
                        .frame(height: max(Space.xxs, proxy.size.height * levels[i]))
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

/// In-context pre-prompt: benefit first, one permission, an honest way out.
fileprivate struct MicPrePrompt: View {
    let onAllow: () -> Void
    let onLater: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.sm) {
                Text("Let Murmur hear you")
                    .font(.dsTitle)
                    .foregroundStyle(Palette.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("Microphone access is only used while you record. Audio is transcribed and you can delete it anytime.")
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            VStack(spacing: Space.xs) {
                Button("Allow microphone", action: onAllow)
                    .buttonStyle(.primary)
                Button("Not now", action: onLater)
                    .buttonStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Space.margin)
        .padding(.top, Space.xxl)
        .padding(.bottom, Space.md)
    }
}

// MARK: - Previews

#Preview("Light") { S_onboarding() }
#Preview("Dark") { S_onboarding().preferredColorScheme(.dark) }
#Preview("Large text") { S_onboarding().dynamicTypeSize(.accessibility2) }
