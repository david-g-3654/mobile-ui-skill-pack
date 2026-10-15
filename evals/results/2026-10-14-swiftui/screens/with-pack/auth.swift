// Screen.swift — Auth archetype (mobile-ui/references/screen-auth.md), default "Quiet" skin.
// Job: get the user in with minimum typing. Focal: app mark + title. Primary: Sign in with Apple.
// Email is one field per step: Email → 6-digit code. Cutting: passwords, "Forgot?", extra providers.

import SwiftUI
import AuthenticationServices

// MARK: - Sample data

fileprivate enum AuthSample {
    static let appName = "Larder"
    static let headline = "Cook with what's\nalready in your fridge"
    static let subhead = "Recipes matched to your pantry, plus a shopping list that writes itself."
    static let googleAccount = "amara.okafor@gmail.com"
    static let appleAccount = "Amara Okafor"
    static let rejectedCode = "000000"
    static let resendSeconds = 24
}

fileprivate enum AuthRoute: Hashable {
    case email
    case code(email: String)
}

// MARK: - Screen

struct S_auth: View {
    @State private var path: [AuthRoute] = []
    @State private var toastMessage: String?

    init() {}

    var body: some View {
        NavigationStack(path: $path) {
            AuthEntryView(
                onEmail: { path.append(.email) },
                onSignedIn: showSignedIn
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .email:
                    AuthEmailStep { email in path.append(.code(email: email)) }
                case .code(let email):
                    AuthCodeStep(email: email) {
                        path.removeAll()
                        showSignedIn("Signed in as \(email)")
                    }
                }
            }
        }
        .tint(Palette.ink)
        .toast(toastMessage)
    }

    private func showSignedIn(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            toastMessage = nil
        }
    }
}

// MARK: - Entry

fileprivate struct AuthEntryView: View {
    let onEmail: () -> Void
    let onSignedIn: (String) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isGoogleLoading = false
    @State private var providerError: String?
    @State private var signInCount = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                AuthAppMark()
                    .padding(.top, Space.xxxl)

                VStack(alignment: .leading, spacing: Space.sm) {
                    Text(AuthSample.headline)
                        .font(.dsLargeTitle)
                        .foregroundStyle(Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text(AuthSample.subhead)
                        .font(.dsBody)
                        .foregroundStyle(Palette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Space.margin)
            .padding(.bottom, Space.xl)
        }
        .canvasBackground()
        .toolbar(.hidden, for: .navigationBar)
        .bottomActionBar {
            VStack(spacing: Space.sm) {
                SignInWithAppleButton(.continue) { request in
                    providerError = nil
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleApple(result)
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: Metrics.buttonHeight)
                .clipShape(Capsule())

                Button(action: continueWithGoogle) {
                    AuthProviderLabel(title: "Continue with Google", isLoading: isGoogleLoading) {
                        Text("G")
                            .font(.dsTitle)
                            .foregroundStyle(Palette.ink)
                    }
                }
                .buttonStyle(.secondary)
                .disabled(isGoogleLoading)
                .accessibilityLabel(isGoogleLoading ? "Continue with Google, loading" : "Continue with Google")

                Button(action: onEmail) {
                    AuthProviderLabel(title: "Continue with email") {
                        Image(systemName: "envelope")
                            .foregroundStyle(Palette.ink)
                    }
                }
                .buttonStyle(.secondary)
            }

            if let providerError {
                Label(providerError, systemImage: "exclamationmark.circle")
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.negative)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

            Text("By continuing you agree to the [Terms of Service](https://larder.example/terms) and [Privacy Policy](https://larder.example/privacy).")
                .font(.dsFootnote)
                .foregroundStyle(Palette.ink2)
                .tint(Palette.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Space.xxs)
        }
        .animation(Motion.snappy, value: providerError)
        .sensoryFeedback(.success, trigger: signInCount)
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success:
            signInCount += 1
            onSignedIn("Signed in as \(AuthSample.appleAccount)")
        case .failure(let error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled { return }
            providerError = "Couldn't reach Apple. Try again or continue with email."
        }
    }

    private func continueWithGoogle() {
        providerError = nil
        isGoogleLoading = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            isGoogleLoading = false
            signInCount += 1
            onSignedIn("Signed in as \(AuthSample.googleAccount)")
        }
    }
}

fileprivate struct AuthAppMark: View {
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 72

    var body: some View {
        Image(systemName: "frying.pan")
            .font(.largeTitle)
            .foregroundStyle(Palette.accent)
            .frame(width: size, height: size)
            .background(Palette.accentSoft, in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
            .accessibilityLabel(AuthSample.appName)
    }
}

/// Provider label: leading mark + title, centered like the system Apple button.
fileprivate struct AuthProviderLabel<Mark: View>: View {
    let title: String
    var isLoading = false
    @ViewBuilder var mark: Mark

    var body: some View {
        ZStack {
            HStack(spacing: Space.xs) {
                mark.accessibilityHidden(true)
                Text(title)
            }
            .opacity(isLoading ? 0 : 1)
            if isLoading { ProgressView().tint(Palette.ink) }
        }
    }
}

// MARK: - Email step (one field)

fileprivate struct AuthEmailStep: View {
    let onSend: (String) -> Void

    @State private var email = ""
    @State private var error: String?
    @State private var isSending = false
    @FocusState private var isFocused: Bool

    private var trimmed: String { email.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text("What's your email?")
                        .font(.dsTitle)
                        .foregroundStyle(Palette.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("We'll send a 6-digit code. New to \(AuthSample.appName)? We'll set up your account after you confirm.")
                        .font(.dsBody)
                        .foregroundStyle(Palette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                AuthField(label: "Email", error: error, isFocused: isFocused) {
                    TextField("", text: $email, prompt: Text("name@example.com").foregroundStyle(Palette.ink3))
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .focused($isFocused)
                        .onSubmit(send)
                        .onChange(of: email) { error = nil }
                }
            }
            .padding(.horizontal, Space.margin)
            .padding(.top, Space.md)
        }
        .scrollDismissesKeyboard(.interactively)
        .canvasBackground()
        .navigationTitle("Continue with email")
        .navigationBarTitleDisplayMode(.inline)
        .bottomActionBar {
            PrimaryButton(title: "Send code", isLoading: isSending, action: send)
        }
        .onAppear { isFocused = true }
        .sensoryFeedback(.error, trigger: error) { _, new in new != nil }
    }

    private func send() {
        let parts = trimmed.split(separator: "@")
        guard parts.count == 2, parts[1].contains("."), !parts[0].isEmpty else {
            error = trimmed.isEmpty
                ? "Enter your email to get a sign-in code."
                : "That doesn't look like an email. Try name@example.com."
            return
        }
        isSending = true
        Task {
            try? await Task.sleep(for: .seconds(0.8))
            isSending = false
            onSend(trimmed.lowercased())
        }
    }
}

// MARK: - Code step (single field, letter-spaced, auto-submit)

fileprivate struct AuthCodeStep: View {
    let email: String
    let onVerified: () -> Void

    @State private var code = ""
    @State private var error: String?
    @State private var isVerifying = false
    @State private var secondsLeft = AuthSample.resendSeconds
    @State private var resendCount = 0
    @FocusState private var isFocused: Bool

    private let length = 6

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text("Check your inbox")
                        .font(.dsTitle)
                        .foregroundStyle(Palette.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("Enter the 6-digit code we sent to \(email). It expires in 10 minutes.")
                        .font(.dsBody)
                        .foregroundStyle(Palette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: Space.xxs) {
                    AuthField(label: "Sign-in code", error: error, isFocused: isFocused) {
                        TextField("", text: $code, prompt: Text("000000").foregroundStyle(Palette.ink3))
                            .font(.dsTitle.monospacedDigit())
                            .tracking(Space.xs)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .focused($isFocused)
                            .onChange(of: code) { _, new in handleInput(new) }
                    }

                    if secondsLeft > 0 {
                        Text("Resend code in 0:\(String(format: "%02d", secondsLeft))")
                            .font(.dsSubhead)
                            .monospacedDigit()
                            .foregroundStyle(Palette.ink2)
                            .frame(minHeight: Metrics.minTap)
                            .contentTransition(.numericText())
                    } else {
                        Button("Resend code") {
                            error = nil
                            code = ""
                            secondsLeft = AuthSample.resendSeconds
                            resendCount += 1
                        }
                        .buttonStyle(.tertiary)
                        .padding(.leading, -Space.xs)
                    }
                }
            }
            .padding(.horizontal, Space.margin)
            .padding(.top, Space.md)
        }
        .scrollDismissesKeyboard(.interactively)
        .canvasBackground()
        .navigationTitle("Verify email")
        .navigationBarTitleDisplayMode(.inline)
        .bottomActionBar {
            PrimaryButton(title: "Sign in", isLoading: isVerifying) { verify() }
                .disabled(code.count < length)
        }
        .onAppear { isFocused = true }
        .task(id: resendCount) {
            while secondsLeft > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                withAnimation(Motion.snappy) { secondsLeft -= 1 }
            }
        }
        .sensoryFeedback(.error, trigger: error) { _, new in new != nil }
    }

    private func handleInput(_ new: String) {
        let digits = String(new.filter(\.isNumber).prefix(length))
        if digits != new { code = digits; return }
        error = nil
        if digits.count == length { verify() }   // auto-submit, including pasted codes
    }

    private func verify() {
        guard code.count == length, !isVerifying else { return }
        isVerifying = true
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            isVerifying = false
            if code == AuthSample.rejectedCode {
                error = "That code didn't match. Check the latest email from \(AuthSample.appName)."
                code = ""
            } else {
                onVerified()
            }
        }
    }
}

// MARK: - Labeled field (label above, inline error)

fileprivate struct AuthField<Field: View>: View {
    let label: String
    let error: String?
    let isFocused: Bool
    @ViewBuilder var field: Field

    private var borderColor: Color {
        if error != nil { return Palette.negative }
        return isFocused ? Palette.ink : Palette.hairline
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(label).font(.dsSubhead).foregroundStyle(Palette.ink2)
            field
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, Space.md)
                .frame(minHeight: Metrics.fieldHeight)
                .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.m, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: isFocused || error != nil ? 1.5 : 1)
                }
                .accessibilityLabel(label)
            if let error {
                Text(error)
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.negative)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .animation(Motion.snappy, value: error)
        .animation(Motion.snappy, value: isFocused)
    }
}

// MARK: - Previews

#Preview("Light") { S_auth() }
#Preview("Dark") { S_auth().preferredColorScheme(.dark) }
#Preview("Large text") { S_auth().dynamicTypeSize(.accessibility2) }
