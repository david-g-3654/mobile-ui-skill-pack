// Screen.swift — Auth entry for "Margin", a reading-highlights app.
//
// Archetype: Auth. Job: get the reader in with minimum typing.
// Focal: the brand line + Sign in with Apple. Primary: Sign in with Apple (system button).
// Secondary: Google, email. Email is one field per step: email → 6-digit code (one flow for
// sign in and sign up; the copy branches once the email is known).
// Cutting: password fields, "Forgot password?", a separate sign-up screen, extra providers.

import SwiftUI
import AuthenticationServices

// MARK: - Root

struct S_auth: View {
    init() {}

    @State private var path: [AuthStep] = []

    var body: some View {
        NavigationStack(path: $path) {
            AuthEntryView(onEmail: { path.append(.email) })
                .navigationDestination(for: AuthStep.self) { step in
                    switch step {
                    case .email:
                        EmailStepView { email in path.append(.code(email)) }
                    case .code(let email):
                        CodeStepView(email: email) { path.append(.done(email)) }
                    case .done(let email):
                        SignedInView(email: email) { path.removeAll() }
                    }
                }
        }
        .tint(QPalette.ink)
    }
}

// MARK: - Sample data

fileprivate enum AuthStep: Hashable {
    case email
    case code(String)
    case done(String)
}

fileprivate enum SampleAccounts {
    /// Emails that already have a Margin library.
    static let known: [String: String] = [
        "maya.okafor@fastmail.com": "Maya",
        "j.lindqvist@icloud.com": "Johan",
    ]
    /// The code in the most recent sign-in email (stands in for the server).
    static let latestCode = "318204"
    static let resendSeconds = 30

    static func firstName(for email: String) -> String? {
        known[email.lowercased()]
    }
}

// MARK: - Entry

fileprivate struct AuthEntryView: View {
    let onEmail: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var isGoogleLoading = false
    @State private var providerError: String?

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    brand
                    Spacer(minLength: QSpace.xxl)
                    methods
                    terms
                        .padding(.top, QSpace.lg)
                }
                .padding(.horizontal, QSpace.margin)
                .padding(.top, QSpace.xxxl)
                .padding(.bottom, QSpace.md)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .qCanvasBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    // Brand moment: app mark + outcome line.
    private var brand: some View {
        VStack(alignment: .leading, spacing: QSpace.xl) {
            AppMark()
            VStack(alignment: .leading, spacing: QSpace.sm) {
                Text("Every highlight you've saved, in one place")
                    .font(.dsLargeTitle)
                    .foregroundStyle(QPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text("Kindle, Apple Books and the margins of paperbacks — searchable and synced.")
                    .font(.dsBody)
                    .foregroundStyle(QPalette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // ≤3 methods. Apple is primary (system-styled); Google and email are secondary.
    private var methods: some View {
        VStack(spacing: QSpace.sm) {
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleApple(result)
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: QMetrics.buttonHeight)
            .clipShape(Capsule())
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)

            Button {
                continueWithGoogle()
            } label: {
                HStack(spacing: QSpace.sm) {
                    if isGoogleLoading {
                        ProgressView().tint(QPalette.ink)
                    } else {
                        GoogleMark()
                            .frame(width: 18, height: 18)
                            .accessibilityHidden(true)
                    }
                    Text("Continue with Google")
                }
            }
            .buttonStyle(.qSecondary)
            .disabled(isGoogleLoading)
            .accessibilityLabel(isGoogleLoading ? "Continue with Google, loading" : "Continue with Google")

            Button(action: onEmail) {
                HStack(spacing: QSpace.sm) {
                    Image(systemName: "envelope")
                        .accessibilityHidden(true)
                    Text("Continue with email")
                }
            }
            .buttonStyle(.qSecondary)

            if let providerError {
                InlineError(message: providerError)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
        }
        .animation(QMotion.snappy, value: providerError)
    }

    private var terms: some View {
        Text("By continuing you agree to Margin's [Terms](https://example.com/terms) and [Privacy Policy](https://example.com/privacy).")
            .font(.dsFootnote)
            .foregroundStyle(QPalette.ink2)
            .tint(QPalette.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success:
            providerError = nil
        case .failure(let error):
            // Cancelling the Apple sheet isn't an error worth showing.
            if (error as? ASAuthorizationError)?.code == .canceled { return }
            providerError = "Apple sign-in didn't finish. Try again, or use Google or email."
        }
    }

    private func continueWithGoogle() {
        providerError = nil
        isGoogleLoading = true
        Task {
            try? await Task.sleep(for: .seconds(1.4))
            isGoogleLoading = false
            providerError = "Google didn't respond. Check your connection and try again."
        }
    }
}

// MARK: - Email step (one field)

fileprivate struct EmailStepView: View {
    let onContinue: (String) -> Void

    @State private var email = ""
    @State private var error: String?
    @State private var isSending = false
    @FocusState private var focused: Bool

    private var trimmed: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xl) {
                Text("What's your email?")
                    .font(.dsTitle)
                    .foregroundStyle(QPalette.ink)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, QSpace.md)

                FieldBlock(label: "Email", error: error) {
                    TextField("", text: $email, prompt: Text("name@example.com").foregroundStyle(QPalette.ink3))
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .focused($focused)
                        .onSubmit(submit)
                        .onChange(of: email) { error = nil }
                }

                Text("We'll email you a 6-digit code. New to Margin? The same code creates your library.")
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, QSpace.margin)
        }
        .scrollDismissesKeyboard(.interactively)
        .qCanvasBackground()
        .navigationTitle("Continue with email")
        .navigationBarTitleDisplayMode(.inline)
        .qBottomActionBar {
            QPrimaryButton(title: "Email me a code", isLoading: isSending, action: submit)
                .disabled(trimmed.isEmpty)
        }
        .onAppear { focused = true }
        .sensoryFeedback(.error, trigger: error) { _, new in new != nil }
    }

    private func submit() {
        guard isValid(trimmed) else {
            error = trimmed.contains("@")
                ? "That email looks incomplete. Check the part after the @."
                : "Enter an email address, like name@example.com."
            return
        }
        isSending = true
        Task {
            try? await Task.sleep(for: .seconds(0.8))
            isSending = false
            onContinue(trimmed.lowercased())
        }
    }

    private func isValid(_ value: String) -> Bool {
        let parts = value.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        let domain = parts[1]
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }
}

// MARK: - Code step (one field, auto-submit)

fileprivate struct CodeStepView: View {
    let email: String
    let onVerified: () -> Void

    @State private var code = ""
    @State private var error: String?
    @State private var isVerifying = false
    @State private var secondsLeft = SampleAccounts.resendSeconds
    @State private var resentNotice: String?
    @FocusState private var focused: Bool

    private var firstName: String? { SampleAccounts.firstName(for: email) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xl) {
                VStack(alignment: .leading, spacing: QSpace.xs) {
                    Text(firstName.map { "Welcome back, \($0)" } ?? "Check your inbox")
                        .font(.dsTitle)
                        .foregroundStyle(QPalette.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("Enter the 6-digit code we sent to \(email).")
                        .font(.dsBody)
                        .foregroundStyle(QPalette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, QSpace.md)

                FieldBlock(label: "Code", error: error) {
                    TextField("", text: $code, prompt: Text("000000").foregroundStyle(QPalette.ink3))
                        .textContentType(.oneTimeCode)
                        .keyboardType(.numberPad)
                        .font(.dsTitle.monospacedDigit())
                        .tracking(6)
                        .focused($focused)
                        .onChange(of: code) { _, new in
                            let digits = String(new.filter(\.isNumber).prefix(6))
                            if digits != new { code = digits; return }
                            error = nil
                            if digits.count == 6 { verify() }
                        }
                }

                resendRow
            }
            .padding(.horizontal, QSpace.margin)
        }
        .scrollDismissesKeyboard(.interactively)
        .qCanvasBackground()
        .navigationTitle(firstName == nil ? "Create your library" : "Sign in")
        .navigationBarTitleDisplayMode(.inline)
        .qBottomActionBar {
            QPrimaryButton(title: firstName == nil ? "Create library" : "Sign in", isLoading: isVerifying, action: verify)
                .disabled(code.count < 6)
        }
        .onAppear { focused = true }
        .task(id: secondsLeft == SampleAccounts.resendSeconds) { await countdown() }
        .sensoryFeedback(.error, trigger: error) { _, new in new != nil }
    }

    @ViewBuilder
    private var resendRow: some View {
        VStack(alignment: .leading, spacing: QSpace.xxs) {
            if secondsLeft > 0 {
                Text("Resend code in \(Self.clock(secondsLeft))")
                    .font(.dsFootnote)
                    .monospacedDigit()
                    .foregroundStyle(QPalette.ink2)
                    .contentTransition(.numericText())
                    .frame(minHeight: QMetrics.minTap, alignment: .leading)
            } else {
                Button("Resend code") { resend() }
                    .buttonStyle(.qTertiary)
                    .padding(.leading, -QSpace.xs)
            }
            if let resentNotice {
                Text(resentNotice)
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
            }
        }
    }

    private func verify() {
        guard code.count == 6, !isVerifying else { return }
        isVerifying = true
        Task {
            try? await Task.sleep(for: .seconds(0.7))
            isVerifying = false
            if code == SampleAccounts.latestCode {
                onVerified()
            } else {
                error = "That code didn't match. Use the newest email from Margin."
                code = ""
            }
        }
    }

    private func resend() {
        code = ""
        error = nil
        resentNotice = "New code sent to \(email)."
        secondsLeft = SampleAccounts.resendSeconds
    }

    private func countdown() async {
        while secondsLeft > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            withAnimation(QMotion.snappy) { secondsLeft -= 1 }
        }
    }

    private static func clock(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Signed in (ceremonial, centered)

fileprivate struct SignedInView: View {
    let email: String
    let onSignOut: () -> Void

    var body: some View {
        QEmptyState(
            title: SampleAccounts.firstName(for: email).map { "You're in, \($0)" } ?? "Your library is ready",
            message: SampleAccounts.firstName(for: email) == nil
                ? "Connect Kindle or Apple Books to bring in your first highlights."
                : "1,284 highlights from 63 books are syncing now.",
            systemImage: "checkmark.circle"
        ) {
            Button("Use a different account", action: onSignOut)
                .buttonStyle(.qTertiary)
        }
        .qCanvasBackground()
        .navigationBarBackButtonHidden()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: email)
    }
}

// MARK: - Pieces

/// Label above the field (never placeholder-as-label), inline error below.
fileprivate struct FieldBlock<Field: View>: View {
    let label: String
    let error: String?
    @ViewBuilder var field: Field

    var body: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            Text(label)
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
            field
                .font(.dsBody)
                .foregroundStyle(QPalette.ink)
                .padding(.horizontal, QSpace.md)
                .frame(minHeight: QMetrics.fieldHeight)
                .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.m, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: QRadius.m, style: .continuous)
                        .strokeBorder(error == nil ? QPalette.hairline : QPalette.negative, lineWidth: 1)
                }
                .accessibilityLabel(label)
            if let error {
                InlineError(message: error)
            }
        }
        .animation(QMotion.snappy, value: error)
    }
}

fileprivate struct InlineError: View {
    let message: String

    var body: some View {
        Label {
            Text(message).fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "exclamationmark.circle")
        }
        .font(.dsFootnote)
        .foregroundStyle(QPalette.negative)
        .accessibilityLabel("Error: \(message)")
    }
}

/// Margin's app mark: an ink tile with a bookmark glyph.
fileprivate struct AppMark: View {
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 72

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
            .fill(QPalette.primaryFill)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(QPalette.accent)
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Google "G" mark
// The official multicolor mark from Google's sign-in branding kit, drawn from its unmodified
// 48×48 SVG paths (no asset catalog or SDK in this target). Brand colors are content, not UI roles.

fileprivate struct GoogleMark: View {
    var body: some View {
        ZStack {
            SVGPathShape(d: "M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z")
                .fill(Color(red: 0xEA / 255, green: 0x43 / 255, blue: 0x35 / 255)) // mobile-ui: content-color
            SVGPathShape(d: "M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z")
                .fill(Color(red: 0x42 / 255, green: 0x85 / 255, blue: 0xF4 / 255)) // mobile-ui: content-color
            SVGPathShape(d: "M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z")
                .fill(Color(red: 0xFB / 255, green: 0xBC / 255, blue: 0x05 / 255)) // mobile-ui: content-color
            SVGPathShape(d: "M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z")
                .fill(Color(red: 0x34 / 255, green: 0xA8 / 255, blue: 0x53 / 255)) // mobile-ui: content-color
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// Minimal SVG path-data renderer (M/L/H/V/C/S/Z, absolute + relative) for a 48×48 viewBox.
fileprivate struct SVGPathShape: Shape {
    let d: String
    var viewBox: CGFloat = 48

    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / viewBox
        return Self.parse(d).applying(
            CGAffineTransform(translationX: rect.minX, y: rect.minY).scaledBy(x: scale, y: scale)
        )
    }

    private enum Token { case command(Character), number(CGFloat) }

    private static func tokenize(_ s: String) -> [Token] {
        let chars = Array(s)
        var tokens: [Token] = []
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c.isLetter {
                tokens.append(.command(c)); i += 1
            } else if c.isNumber || c == "." || c == "-" {
                var j = i
                if chars[j] == "-" { j += 1 }
                var seenDot = false
                while j < chars.count, chars[j].isNumber || (chars[j] == "." && !seenDot) {
                    if chars[j] == "." { seenDot = true }
                    j += 1
                }
                tokens.append(.number(CGFloat(Double(String(chars[i..<j])) ?? 0)))
                i = j
            } else {
                i += 1
            }
        }
        return tokens
    }

    private static func parse(_ d: String) -> Path {
        var path = Path()
        let tokens = tokenize(d)
        var idx = 0
        var cmd: Character = "M"
        var current = CGPoint.zero
        var start = CGPoint.zero
        var lastControl: CGPoint?

        func next() -> CGFloat {
            guard idx < tokens.count, case .number(let v) = tokens[idx] else { return 0 }
            idx += 1
            return v
        }
        func hasNumber() -> Bool {
            if idx < tokens.count, case .number = tokens[idx] { return true }
            return false
        }

        while idx < tokens.count {
            if case .command(let c) = tokens[idx] {
                cmd = c; idx += 1
                if c == "z" || c == "Z" {
                    path.closeSubpath(); current = start; lastControl = nil
                    continue
                }
            } else if !hasNumber() {
                idx += 1; continue
            }
            let rel = cmd.isLowercase
            let base = rel ? current : .zero
            switch cmd.uppercased() {
            case "M":
                let p = CGPoint(x: base.x + next(), y: base.y + next())
                path.move(to: p); current = p; start = p; lastControl = nil
                cmd = rel ? "l" : "L"
            case "L":
                let p = CGPoint(x: base.x + next(), y: base.y + next())
                path.addLine(to: p); current = p; lastControl = nil
            case "H":
                let p = CGPoint(x: (rel ? current.x : 0) + next(), y: current.y)
                path.addLine(to: p); current = p; lastControl = nil
            case "V":
                let p = CGPoint(x: current.x, y: (rel ? current.y : 0) + next())
                path.addLine(to: p); current = p; lastControl = nil
            case "C":
                let c1 = CGPoint(x: base.x + next(), y: base.y + next())
                let c2 = CGPoint(x: base.x + next(), y: base.y + next())
                let p = CGPoint(x: base.x + next(), y: base.y + next())
                path.addCurve(to: p, control1: c1, control2: c2); current = p; lastControl = c2
            case "S":
                let c1 = lastControl.map { CGPoint(x: 2 * current.x - $0.x, y: 2 * current.y - $0.y) } ?? current
                let c2 = CGPoint(x: base.x + next(), y: base.y + next())
                let p = CGPoint(x: base.x + next(), y: base.y + next())
                path.addCurve(to: p, control1: c1, control2: c2); current = p; lastControl = c2
            default:
                idx += 1
            }
        }
        return path
    }
}

// MARK: - Previews

#Preview("Light") {
    S_auth()
}

#Preview("Dark") {
    S_auth()
        .preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_auth()
        .dynamicTypeSize(.accessibility2)
}
