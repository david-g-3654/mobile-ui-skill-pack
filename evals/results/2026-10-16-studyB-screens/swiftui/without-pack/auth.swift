import SwiftUI

fileprivate typealias AuthState<Value> = SwiftUI.State<Value>

struct S_auth: View {
    @AuthState private var email = ""
    @AuthState private var showsEmail = false
    @AuthState private var notice: String? = nil
    @FocusState private var emailFocused: Bool

    init() {}

    private let ink = Color(red: 0.17, green: 0.22, blue: 0.18)
    private let cream = Color(red: 0.96, green: 0.95, blue: 0.91)

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 7) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("bloom")
                            .font(.system(size: 25, weight: .semibold, design: .rounded))
                            .tracking(-1)
                        Spacer()
                        Text("A LITTLE SPACE FOR YOU")
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(1.4)
                    }
                    .padding(.top, 21)

                    illustration
                        .frame(height: geometry.size.height < 740 ? 240 : 290)
                        .padding(.top, 22)

                    VStack(spacing: 13) {
                        Text("Good things\nstart with you.")
                            .font(.system(size: 45, weight: .regular, design: .serif))
                            .tracking(-1.9)
                            .lineSpacing(-2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Make room for a calmer, more intentional day.")
                            .font(.system(size: 14))
                            .foregroundStyle(ink.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.bottom, 29)

                    VStack(spacing: 11) {
                        Button {
                            notice = "Apple sign-in will be available when your account service is connected."
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 21))
                                Text("Continue with Apple")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .foregroundStyle(.white)
                            .background(ink, in: RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            notice = "Google sign-in will be available when your account service is connected."
                        } label: {
                            HStack(spacing: 11) {
                                GoogleMark()
                                    .frame(width: 18, height: 18)
                                Text("Continue with Google")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(ink.opacity(0.14)))
                        }

                        if showsEmail {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundStyle(ink.opacity(0.5))
                                TextField("you@example.com", text: $email)
                                    .font(.system(size: 15))
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .focused($emailFocused)
                                    .submitLabel(.go)
                                    .onSubmit(submitEmail)
                                Button(action: submitEmail) {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(width: 34, height: 34)
                                        .background(ink, in: Circle())
                                        .foregroundStyle(.white)
                                }
                                .accessibilityLabel("Continue with email")
                            }
                            .padding(.horizontal, 15)
                            .frame(height: 54)
                            .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(ink.opacity(0.2)))
                        } else {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { showsEmail = true }
                                emailFocused = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 17))
                                    Text("Continue with email")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 49)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 24)

                    Text("By continuing, you agree to our")
                        .font(.system(size: 11))
                        .foregroundStyle(ink.opacity(0.5))
                    HStack(spacing: 4) {
                        Button("Terms of Service") {
                            notice = "Bloom is a personal wellbeing space. Account features require a connected service."
                        }
                        Text("and")
                            .foregroundStyle(ink.opacity(0.5))
                        Button("Privacy Policy") {
                            notice = "This demo does not send or store your personal information."
                        }
                    }
                    .font(.system(size: 11))
                    .buttonStyle(.plain)
                    .underline()
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 28)
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: 460)
                .frame(maxWidth: .infinity)
            }
            .background(cream.ignoresSafeArea())
            .foregroundStyle(ink)
            .scrollDismissesKeyboard(.interactively)
            .alert("A little heads-up", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
                Button("Got it", role: .cancel) { notice = nil }
            } message: {
                Text(notice ?? "")
            }
        }
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.89, green: 0.88, blue: 0.80))
                .frame(width: 230, height: 230)
            Circle()
                .fill(Color(red: 0.96, green: 0.76, blue: 0.45))
                .frame(width: 65, height: 65)
                .offset(x: 72, y: -69)
            Ellipse()
                .fill(ink.opacity(0.08))
                .frame(width: 172, height: 17)
                .offset(y: 94)
            Path { path in
                path.move(to: CGPoint(x: 120, y: 202))
                path.addCurve(to: CGPoint(x: 132, y: 45), control1: CGPoint(x: 103, y: 135), control2: CGPoint(x: 150, y: 109))
            }
            .stroke(ink, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 250, height: 250)
            BloomLeaf()
                .fill(Color(red: 0.37, green: 0.45, blue: 0.30))
                .frame(width: 65, height: 102)
                .rotationEffect(.degrees(-51))
                .offset(x: -31, y: -7)
            BloomLeaf()
                .fill(Color(red: 0.51, green: 0.59, blue: 0.39))
                .frame(width: 53, height: 87)
                .rotationEffect(.degrees(42))
                .offset(x: 29, y: -43)
            BloomLeaf()
                .fill(Color(red: 0.27, green: 0.36, blue: 0.24))
                .frame(width: 45, height: 77)
                .rotationEffect(.degrees(-21))
                .offset(x: 0, y: -82)
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(red: 0.74, green: 0.41, blue: 0.29))
                .frame(width: 80, height: 61)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 28, bottomTrailingRadius: 28))
                .offset(y: 66)
            Capsule()
                .fill(Color(red: 0.81, green: 0.49, blue: 0.35))
                .frame(width: 90, height: 13)
                .offset(y: 35)
            Image(systemName: "sparkle")
                .font(.system(size: 23, weight: .light))
                .offset(x: -103, y: -71)
            Image(systemName: "sparkle")
                .font(.system(size: 14, weight: .light))
                .offset(x: 104, y: 45)
        }
        .accessibilityHidden(true)
    }

    private func submitEmail() {
        let address = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard address.contains("@"), let domain = address.split(separator: "@").last, domain.contains(".") else {
            notice = "Please enter a valid email address to continue."
            return
        }
        emailFocused = false
        notice = "You're ready to continue as \(address). Email sign-in requires a connected account service."
    }
}

fileprivate struct BloomLeaf: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: -rect.width * 0.3, y: rect.height * 0.65), control2: CGPoint(x: rect.width * 0.1, y: rect.height * 0.15))
            path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control1: CGPoint(x: rect.width * 1.2, y: rect.height * 0.27), control2: CGPoint(x: rect.width * 1.1, y: rect.height * 0.8))
        }
    }
}

fileprivate struct GoogleMark: View {
    var body: some View {
        ZStack {
            Circle().trim(from: 0.05, to: 0.25).stroke(Color.green, lineWidth: 3.4)
            Circle().trim(from: 0.25, to: 0.45).stroke(Color.yellow, lineWidth: 3.4)
            Circle().trim(from: 0.45, to: 0.73).stroke(Color.red, lineWidth: 3.4)
            Circle().trim(from: 0.73, to: 0.87).stroke(Color.blue, lineWidth: 3.4)
            Path { path in
                path.move(to: CGPoint(x: 10, y: 9))
                path.addLine(to: CGPoint(x: 17, y: 9))
                path.addQuadCurve(to: CGPoint(x: 13.5, y: 16), control: CGPoint(x: 18, y: 14))
            }
            .stroke(Color.blue, lineWidth: 3.4)
        }
        .padding(1)
        .accessibilityHidden(true)
    }
}
