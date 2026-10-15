// Screen.swift — Auth entry for "Larder", a weekly meal-planning app.
// Archetype: Auth. Job: get the user in with minimum typing.
// Focal: the brand line + Sign in with Apple. Primary: Sign in with Apple.
// Cutting: username/password on the entry screen (email is one field per step, behind a push).

import SwiftUI
import AuthenticationServices

// MARK: - Sample data

fileprivate enum SampleAccounts {
    /// Emails the backend already knows -> branch to "sign in" instead of "create account".
    static let known: [String: String] = [
        "maya.lindqvist@fastmail.com": "Maya",
        "dev.okafor@icloud.com": "Dev",
    ]
}

fileprivate enum AuthRoute: Hashable {
    case email
    case password(email: String)
}

fileprivate enum Provider: String {
    case apple = "Apple", google = "Google"
}

// MARK: - Root

struct S_auth: View {
    @State private var path: [AuthRoute] = []
    @State private var signedInMessage: String?

    init() {}

    var body: some View {
        NavigationStack(path: $path) {
            AuthEntryView(
                onEmail: { path.append(.email) },
                onSignedIn: finish
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .email:
                    EmailStepView { email in path.append(.password(email: email)) }
                case .password(let email):
                    PasswordStepView(email: email, onSignedIn: finish)
                }
            }
        }
        .tint(Palette.ink)
        .toast(signedInMessage)
    }

    private func finish(_ message: String) {
        path.removeAll()
        signedInMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            signedInMessage = nil
        }
    }
}

// MARK: - Entry

fileprivate struct AuthEntryView: View {
    let onEmail: () -> Void
    let onSignedIn: (String) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var loadingProvider: Provider?
    @State private var errorMessage: String?
    @State private var errorCount = 0

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    brand
                        .padding(.top, Space.xxxl)

                    Spacer(minLength: Space.xxl)

                    methods

                    terms
                        .padding(.top, Space.xl)
                        .padding(.bottom, Space.md)
                }
                .padding(.horizontal, Space.margin)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .canvasBackground()
        .toolbar(.hidden, for: .navigationBar)
        .sensoryFeedback(.error, trigger: errorCount)
    }

    // Brand moment: mark + outcome line. Left-aligned, title is the focal text.
    private var brand: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            Image(systemName: "fork.knife")
                .font(.dsTitle)
                .foregroundStyle(Palette.accent)
                .frame(width: 64, height: 64)
                .background(Palette.accentSoft, in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Space.sm) {
                Text("Dinner for the week, planned by Sunday night")
                    .font(.dsLargeTitle)
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text("Sign in to sync your meal plan and shopping list with everyone in your household.")
                    .font(.dsBody)
                    .foregroundStyle(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // ≤3 methods: Apple (primary, official button), Google + email (secondary).
    private var methods: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
                errorMessage = nil
            } onCompletion: { result in
                switch result {
                case .success:
                    onSignedIn("Signed in with Apple")
                case .failure(let error):
                    if (error as? ASAuthorizationError)?.code == .canceled { return }
                    showError("Couldn't reach Apple. Check your connection and try again.")
                }
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: Metrics.buttonHeight)
            .clipShape(Capsule())
            .disabled(loadingProvider != nil)

            Button(action: signInWithGoogle) {
                ZStack {
                    // TODO: replace the neutral glyph with Google's official "G" mark (GoogleSignIn SDK asset).
                    Label("Continue with Google", systemImage: "person.crop.circle")
                        .opacity(loadingProvider == .google ? 0 : 1)
                    if loadingProvider == .google { ProgressView().tint(Palette.ink) }
                }
            }
            .buttonStyle(.secondary)
            .disabled(loadingProvider != nil)
            .accessibilityLabel(loadingProvider == .google ? "Continue with Google, loading" : "Continue with Google")

            Button(action: onEmail) {
                Label("Continue with email", systemImage: "envelope")
            }
            .buttonStyle(.secondary)
            .disabled(loadingProvider != nil)

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle")
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.negative)
                    .padding(.top, Space.xxs)
                    .transition(.opacity)
            }
        }
        .animation(Motion.snappy, value: errorMessage)
    }

    private var terms: some View {
        Text("By continuing you agree to Larder's [Terms](https://larder.app/terms) and [Privacy Policy](https://larder.app/privacy).")
            .font(.dsFootnote)
            .foregroundStyle(Palette.ink2)
            .tint(Palette.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func signInWithGoogle() {
        errorMessage = nil
        loadingProvider = .google
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            loadingProvider = nil
            onSignedIn("Signed in as maya.lindqvist@gmail.com")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        errorCount += 1
    }
}

// MARK: - Email step (one field)

fileprivate struct EmailStepView: View {
    let onContinue: (String) -> Void

    @State private var email = ""
    @State private var error: String?
    @State private var errorCount = 0
    @FocusState private var focused: Bool

    private var trimmed: String { email.trimmingCharacters(in: .whitespaces).lowercased() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text("What's your email?")
                        .font(.dsTitle)
                        .foregroundStyle(Palette.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("We'll sign you in, or set up a new account if you're new to Larder.")
                        .font(.dsSubhead)
                        .foregroundStyle(Palette.ink2)
                }

                AuthField(label: "Email", error: error, isFocused: focused) {
                    TextField("", text: $email, prompt: Text("name@example.com").foregroundStyle(Palette.ink3))
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.continue)
                        .focused($focused)
                        .onSubmit(submit)
                        .onChange(of: email) { _, _ in error = nil }
                }
            }
            .padding(.horizontal, Space.margin)
            .padding(.top, Space.md)
        }
        .scrollDismissesKeyboard(.interactively)
        .canvasBackground()
        .navigationBarTitleDisplayMode(.inline)
        .bottomActionBar {
            Button("Continue", action: submit)
                .buttonStyle(.primary)
                .disabled(trimmed.isEmpty)
        }
        .sensoryFeedback(.error, trigger: errorCount)
        .onAppear { focused = true }
    }

    private func submit() {
        let parts = trimmed.split(separator: "@")
        guard parts.count == 2, parts[1].contains("."), !parts[0].isEmpty else {
            error = "That doesn't look like an email. Check for a missing @ or dot."
            errorCount += 1
            return
        }
        onContinue(trimmed)
    }
}

// MARK: - Password step (branches: sign in vs create)

fileprivate struct PasswordStepView: View {
    let email: String
    let onSignedIn: (String) -> Void

    @State private var password = ""
    @State private var isRevealed = false
    @State private var isLoading = false
    @State private var error: String?
    @State private var errorCount = 0
    @State private var resetSent = false
    @FocusState private var focused: Bool

    private var firstName: String? { SampleAccounts.known[email] }
    private var isNewAccount: Bool { firstName == nil }

    private var requirements: [(String, Bool)] {
        [
            ("At least 8 characters", password.count >= 8),
            ("Includes a number", password.contains(where: \.isNumber)),
            ("Different from your email", !password.isEmpty && password.lowercased() != email),
        ]
    }

    private var canSubmit: Bool {
        isNewAccount ? requirements.allSatisfy(\.1) : !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text(isNewAccount ? "Create a password" : "Welcome back, \(firstName ?? "")")
                        .font(.dsTitle)
                        .foregroundStyle(Palette.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text(email)
                        .font(.dsSubhead)
                        .foregroundStyle(Palette.ink2)
                }

                AuthField(label: "Password", error: error, isFocused: focused) {
                    HStack(spacing: Space.xs) {
                        Group {
                            if isRevealed {
                                TextField("", text: $password)
                            } else {
                                SecureField("", text: $password)
                            }
                        }
                        .textContentType(isNewAccount ? .newPassword : .password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .focused($focused)
                        .onSubmit(submit)
                        .onChange(of: password) { _, _ in error = nil }

                        Button {
                            isRevealed.toggle()
                        } label: {
                            Image(systemName: isRevealed ? "eye.slash" : "eye")
                                .font(.dsBody)
                                .foregroundStyle(Palette.ink2)
                                .frame(width: Metrics.minTap, height: Metrics.minTap)
                        }
                        .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
                    }
                }

                if isNewAccount {
                    VStack(alignment: .leading, spacing: Space.xs) {
                        ForEach(requirements, id: \.0) { item in
                            Label(item.0, systemImage: item.1 ? "checkmark.circle.fill" : "circle")
                                .font(.dsSubhead)
                                .foregroundStyle(item.1 ? Palette.positive : Palette.ink2)
                                .accessibilityValue(item.1 ? "Met" : "Not met")
                        }
                    }
                    .animation(Motion.snappy, value: password)
                } else {
                    Button(resetSent ? "Reset link sent to \(email)" : "Forgot password?") {
                        resetSent = true
                    }
                    .buttonStyle(.tertiary)
                    .disabled(resetSent)
                    .padding(.leading, -Space.xs)
                }
            }
            .padding(.horizontal, Space.margin)
            .padding(.top, Space.md)
        }
        .scrollDismissesKeyboard(.interactively)
        .canvasBackground()
        .navigationBarTitleDisplayMode(.inline)
        .bottomActionBar {
            PrimaryButton(title: isNewAccount ? "Create account" : "Sign in", isLoading: isLoading, action: submit)
                .disabled(!canSubmit)
        }
        .sensoryFeedback(.error, trigger: errorCount)
        .onAppear { focused = true }
    }

    private func submit() {
        guard canSubmit, !isLoading else { return }
        isLoading = true
        Task {
            try? await Task.sleep(for: .seconds(1.1))
            isLoading = false
            // Demo: a known account rejects passwords shorter than 8 characters.
            if !isNewAccount && password.count < 8 {
                error = "That password doesn't match. Try again or reset it."
                errorCount += 1
                return
            }
            onSignedIn(isNewAccount ? "Account created for \(email)" : "Signed in as \(email)")
        }
    }
}

// MARK: - Field (label above, inline error below)

fileprivate struct AuthField<Input: View>: View {
    let label: String
    let error: String?
    let isFocused: Bool
    @ViewBuilder var input: Input

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(label)
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink2)
            input
                .font(.dsBody)
                .padding(.leading, Space.md)
                .padding(.trailing, Space.xxs)
                .frame(minHeight: Metrics.fieldHeight)
                .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.m, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                        .strokeBorder(
                            error != nil ? Palette.negative : (isFocused ? Palette.ink : Palette.hairline),
                            lineWidth: isFocused || error != nil ? 1.5 : 1
                        )
                }
            if let error {
                Text(error)
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.negative)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .animation(Motion.snappy, value: error)
    }
}

// MARK: - Previews

#Preview("Light") { S_auth() }
#Preview("Dark") { S_auth().preferredColorScheme(.dark) }
#Preview("Large text") { S_auth().dynamicTypeSize(.accessibility2) }
