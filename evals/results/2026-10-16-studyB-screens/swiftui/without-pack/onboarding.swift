import SwiftUI

struct S_onboarding: View {
    private var pageStorage = SwiftUI.State<Int>(initialValue: 0)
    private var readyStorage = SwiftUI.State<Bool>(initialValue: false)

    private var page: Int {
        get { pageStorage.wrappedValue }
        nonmutating set { pageStorage.wrappedValue = newValue }
    }

    private var isReady: Bool {
        get { readyStorage.wrappedValue }
        nonmutating set { readyStorage.wrappedValue = newValue }
    }

    init() {}

    private let ink = Color(red: 0.17, green: 0.22, blue: 0.18)
    private let green = Color(red: 0.28, green: 0.39, blue: 0.24)

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header
                    .padding(.top, 15)

                Spacer(minLength: 12)

                illustration
                    .frame(height: min(geometry.size.height * 0.43, 345))

                Spacer(minLength: 18)

                VStack(spacing: 17) {
                    Text(isReady ? "A little space for\nyour next big idea." : titles[page])
                        .font(.system(size: 43, weight: .regular, design: .serif))
                        .tracking(-1.8)
                        .lineSpacing(-1)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(ink)

                    Text(isReady ? "Your notebook is ready. Start with a thought,\na question, or whatever’s on your mind." : subtitles[page])
                        .font(.system(size: 16))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(ink.opacity(0.61))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 24)

                HStack(spacing: 7) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(page == index ? green : ink.opacity(0.14))
                            .frame(width: page == index ? 23 : 6, height: 6)
                    }
                }
                .padding(.bottom, 25)

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if page < 2 { page += 1 } else { isReady = true }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(isReady ? "Ready to capture" : page == 2 ? "Get started" : "Find your flow")
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                    }
                    .overlay(alignment: .trailing) {
                        Image(systemName: isReady ? "checkmark" : "arrow.right")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.trailing, 22)
                    }
                    .foregroundStyle(.white)
                    .frame(height: 60)
                    .background(green, in: RoundedRectangle(cornerRadius: 20))
                }
                .disabled(isReady)
                .padding(.horizontal, 25)

                HStack(spacing: 5) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 11))
                    Text("Your thoughts stay yours. Always.")
                        .font(.system(size: 11))
                }
                .foregroundStyle(ink.opacity(0.46))
                .padding(.top, 17)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.93).ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private var titles: [String] {
        ["Your mind moves.\nLet it.", "Less organizing.\nMore imagining.", "Good ideas deserve\nto be remembered."]
    }

    private var subtitles: [String] {
        ["Speak freely. Let AI turn your voice into\nclear notes, fresh ideas, and next steps.",
         "From a rambling thought to a clear summary.\nWe’ll find the important parts for you.",
         "Keep your thoughts close and your next\nsteps clear. All in one quiet little space."]
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "waveform")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(green)
            Text("murmur")
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .tracking(-1.2)
                .foregroundStyle(ink)
            Spacer()
            Button("Skip") {
                withAnimation { page = 2 }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(ink.opacity(0.55))
            .opacity(page == 2 ? 0 : 1)
            .disabled(page == 2)
        }
        .padding(.horizontal, 27)
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.89, green: 0.90, blue: 0.82))
                .frame(width: 273, height: 273)
            Circle()
                .stroke(green.opacity(0.11), lineWidth: 1)
                .frame(width: 310, height: 310)
            Circle()
                .stroke(green.opacity(0.07), style: StrokeStyle(lineWidth: 1, dash: [3, 7]))
                .frame(width: 342, height: 342)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundStyle(green)
                    Text("A thought worth keeping")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Text("0:24")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 3) {
                    ForEach(Array(waveHeights.enumerated()), id: \.offset) { index, height in
                        Capsule()
                            .fill(index < 24 ? green : green.opacity(0.2))
                            .frame(width: 3, height: height)
                    }
                }
                .frame(height: 38)

                Text("“What if we made more space\nfor the things that inspire us?”")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .lineSpacing(5)
                    .foregroundStyle(ink.opacity(0.8))
            }
            .padding(20)
            .frame(width: 284)
            .background(.white, in: RoundedRectangle(cornerRadius: 21))
            .overlay(RoundedRectangle(cornerRadius: 21).stroke(ink.opacity(0.05)))
            .shadow(color: ink.opacity(0.07), radius: 20, x: 0, y: 12)
            .rotationEffect(.degrees(-6))
            .offset(x: -6, y: -36)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundStyle(green)
                    .frame(width: 34, height: 34)
                    .background(green.opacity(0.09), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 8) {
                    Text("A little clarity, instantly.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ink)
                    Text("Make room for what matters.")
                        .font(.system(size: 12))
                        .foregroundStyle(ink.opacity(0.6))
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("One thought. A clear next step.")
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(green)
                    .padding(.top, 3)
                }
            }
            .padding(17)
            .frame(width: 279, alignment: .leading)
            .background(Color(red: 0.99, green: 0.99, blue: 0.97), in: RoundedRectangle(cornerRadius: 19))
            .overlay(RoundedRectangle(cornerRadius: 19).stroke(green.opacity(0.13)))
            .shadow(color: ink.opacity(0.06), radius: 16, x: 0, y: 10)
            .rotationEffect(.degrees(4))
            .offset(x: 15, y: 88)

            Image(systemName: "sparkle")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(green.opacity(0.8))
                .offset(x: 143, y: -118)
            Image(systemName: "sparkle")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(green.opacity(0.6))
                .offset(x: -146, y: 76)
        }
        .accessibilityElement(children: .combine)
    }

    private var waveHeights: [CGFloat] {
        [8, 14, 10, 22, 16, 30, 20, 36, 27, 17, 25, 38, 23, 14, 29, 19, 34, 24, 15, 29, 36, 22, 12, 20, 29, 18, 32, 24, 13, 20, 15, 26, 18, 10, 16, 9, 14, 7]
    }
}
