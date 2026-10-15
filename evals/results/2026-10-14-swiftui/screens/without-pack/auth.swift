import SwiftUI
import AuthenticationServices

// MARK: - Sample data

fileprivate enum AuthProvider: String {
    case apple = "Apple"
    case google = "Google"
    case email = "Email"
}

fileprivate struct RecentAccount {
    let name: String
    let email: String
    let provider: AuthProvider
}

fileprivate enum SampleData {
    static let appName = "Trailmark"
    static let tagline = "Plan hikes, track routes, share the view."
    static let recent = RecentAccount(name: "Maya Chen", email: "maya.chen@gmail.com", provider: .google)
    static let registeredEmails: Set<String> = ["maya.chen@gmail.com", "jon.alvarez@icloud.com"]
}

fileprivate enum AuthMode: String, CaseIterable, Identifiable {
    case signIn = "Sign In"
    case signUp = "Create Account"
    var id: String { rawValue }
}

fileprivate enum Field: Hashable {
    case email, password
}

// MARK: - Screen

struct S_auth: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var mode: AuthMode = .signIn
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @State private var isLoading: AuthProvider? = nil
    @State private var errorMessage: String? = nil
    @State private var signedInAs: String? = nil
    @State private var showResetSheet = false
    @State private var useRecent = true
    @FocusState private var focused: Field?

    init() {}

    private var emailIsValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard let at = trimmed.firstIndex(of: "@") else { return false }
        let domain = trimmed[trimmed.index(after: at)...]
        return trimmed.distance(from: trimmed.startIndex, to: at) > 0 && domain.contains(".") && !domain.hasSuffix(".")
    }

    private var passwordIsValid: Bool {
        mode == .signIn ? !password.isEmpty : password.count >= 8
    }

    private var canSubmit: Bool { emailIsValid && passwordIsValid && isLoading == nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    if useRecent && mode == .signIn {
                        recentAccountCard
                    }
                    providerButtons
                    OrDivider()
                    emailForm
                    footer
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") { signedInAs = "Guest" }
                        .foregroundStyle(.secondary)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = nil }
                }
            }
            .sheet(isPresented: $showResetSheet) {
                ResetPasswordSheet(prefilledEmail: email)
                    .presentationDetents([.medium])
            }
            .alert("Signed in", isPresented: Binding(get: { signedInAs != nil }, set: { if !$0 { signedInAs = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Welcome to \(SampleData.appName), \(signedInAs ?? "")!")
            }
        }
    }

    // MARK: Sections

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.13, green: 0.55, blue: 0.42), Color(red: 0.07, green: 0.33, blue: 0.45)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 76, height: 76)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text(mode == .signIn ? "Welcome back" : "Join \(SampleData.appName)")
                    .font(.largeTitle.bold())
                    .contentTransition(.opacity)
                Text(SampleData.tagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Picker("Mode", selection: $mode.animation(.snappy)) {
                ForEach(AuthMode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.top, 4)
            .onChange(of: mode) { _, _ in errorMessage = nil }
        }
    }

    private var recentAccountCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.orange.gradient)
                Text(initials(SampleData.recent.name))
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("Continue as \(SampleData.recent.name.components(separatedBy: " ").first ?? "")")
                    .font(.subheadline.weight(.semibold))
                Text("\(SampleData.recent.email) · \(SampleData.recent.provider.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Button {
                withAnimation(.snappy) { useRecent = false }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color(.tertiarySystemFill)))
            }
            .accessibilityLabel("Use a different account")
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
        .contentShape(Rectangle())
        .onTapGesture { simulate(.google, name: SampleData.recent.name) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var providerButtons: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(mode == .signIn ? .signIn : .signUp) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let auth):
                    if let cred = auth.credential as? ASAuthorizationAppleIDCredential {
                        let given = cred.fullName?.givenName ?? "Apple user"
                        signedInAs = given
                    } else {
                        signedInAs = "Apple user"
                    }
                case .failure(let error):
                    if (error as? ASAuthorizationError)?.code != .canceled {
                        errorMessage = "Apple sign in failed. Please try again."
                    }
                }
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .disabled(isLoading != nil)

            Button {
                simulate(.google, name: "Maya")
            } label: {
                HStack(spacing: 10) {
                    if isLoading == .google {
                        ProgressView()
                    } else {
                        GoogleMark().frame(width: 20, height: 20)
                    }
                    Text(mode == .signIn ? "Sign in with Google" : "Sign up with Google")
                        .font(.system(size: 19, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(Color.primary)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color(.separator), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isLoading != nil)
        }
    }

    private var emailForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            InputField(icon: "envelope",
                       placeholder: "Email address",
                       text: $email,
                       isError: !email.isEmpty && !emailIsValid && focused != .email) {
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focused, equals: .email)
                    .onSubmit { focused = .password }
            }

            InputField(icon: "lock",
                       placeholder: "Password",
                       text: $password,
                       isError: false) {
                HStack {
                    Group {
                        if showPassword {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                    }
                    .textContentType(mode == .signIn ? .password : .newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.go)
                    .focused($focused, equals: .password)
                    .onSubmit(submitEmail)

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel(showPassword ? "Hide password" : "Show password")
                }
            }

            if mode == .signUp {
                PasswordStrength(password: password)
                    .transition(.opacity)
            } else {
                HStack {
                    Spacer()
                    Button("Forgot password?") { showResetSheet = true }
                        .font(.footnote.weight(.semibold))
                }
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .transition(.opacity)
            }

            Button(action: submitEmail) {
                ZStack {
                    if isLoading == .email {
                        ProgressView().tint(.white)
                    } else {
                        Text(mode == .signIn ? "Sign In" : "Create Account")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(canSubmit || isLoading == .email ? Color.accentColor : Color.accentColor.opacity(0.4))
                )
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
            .padding(.top, 4)
        }
    }

    private var footer: some View {
        VStack(spacing: 14) {
            HStack(spacing: 4) {
                Text(mode == .signIn ? "New to \(SampleData.appName)?" : "Already have an account?")
                    .foregroundStyle(.secondary)
                Button(mode == .signIn ? "Create an account" : "Sign in") {
                    withAnimation(.snappy) { mode = mode == .signIn ? .signUp : .signIn }
                }
                .fontWeight(.semibold)
            }
            .font(.footnote)

            Text("By continuing, you agree to our [Terms of Service](https://example.com/terms) and [Privacy Policy](https://example.com/privacy).")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: Actions

    private func submitEmail() {
        guard canSubmit else {
            if !emailIsValid { errorMessage = "Enter a valid email address." }
            else if mode == .signUp { errorMessage = "Password must be at least 8 characters." }
            return
        }
        focused = nil
        errorMessage = nil
        isLoading = .email
        let normalized = email.trimmingCharacters(in: .whitespaces).lowercased()
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            await MainActor.run {
                withAnimation {
                    isLoading = nil
                    if mode == .signIn && !SampleData.registeredEmails.contains(normalized) {
                        errorMessage = "No account found for \(normalized). Try creating one."
                    } else if mode == .signUp && SampleData.registeredEmails.contains(normalized) {
                        errorMessage = "An account with this email already exists."
                    } else {
                        signedInAs = normalized
                    }
                }
            }
        }
    }

    private func simulate(_ provider: AuthProvider, name: String) {
        errorMessage = nil
        isLoading = provider
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                isLoading = nil
                signedInAs = name
            }
        }
    }

    private func initials(_ name: String) -> String {
        name.split(separator: " ").compactMap { $0.first }.prefix(2).map(String.init).joined()
    }
}

// MARK: - Components

fileprivate struct InputField<Content: View>: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isError: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            content()
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isError ? Color.red : Color(.separator).opacity(0.6), lineWidth: 1)
        )
    }
}

fileprivate struct OrDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color(.separator)).frame(height: 1)
            Text("or continue with email")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize()
            Rectangle().fill(Color(.separator)).frame(height: 1)
        }
    }
}

fileprivate struct GoogleMark: View {
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            let lw = s * 0.22
            ZStack {
                Circle().trim(from: 0.0, to: 0.13)
                    .stroke(Color(red: 0.26, green: 0.52, blue: 0.96), style: StrokeStyle(lineWidth: lw))
                Circle().trim(from: 0.13, to: 0.38)
                    .stroke(Color(red: 0.20, green: 0.66, blue: 0.33), style: StrokeStyle(lineWidth: lw))
                Circle().trim(from: 0.38, to: 0.58)
                    .stroke(Color(red: 0.98, green: 0.74, blue: 0.02), style: StrokeStyle(lineWidth: lw))
                Circle().trim(from: 0.58, to: 0.88)
                    .stroke(Color(red: 0.92, green: 0.26, blue: 0.21), style: StrokeStyle(lineWidth: lw))
                Rectangle()
                    .fill(Color(red: 0.26, green: 0.52, blue: 0.96))
                    .frame(width: s * 0.5, height: lw)
                    .offset(x: s * 0.22)
            }
            .padding(lw / 2)
            .frame(width: s, height: s)
        }
        .accessibilityHidden(true)
    }
}

fileprivate struct PasswordStrength: View {
    let password: String

    private var score: Int {
        var s = 0
        if password.count >= 8 { s += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { s += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { s += 1 }
        if password.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil { s += 1 }
        return password.isEmpty ? 0 : s
    }

    private var label: String {
        switch score {
        case 0: return "At least 8 characters"
        case 1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        default: return "Strong"
        }
    }

    private var color: Color {
        switch score {
        case 0, 1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i < score ? color : Color(.tertiarySystemFill))
                        .frame(height: 4)
                }
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(score == 0 ? .secondary : color)
        }
        .animation(.snappy, value: score)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Password strength: \(label)")
    }
}

fileprivate struct ResetPasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var email: String
    @State private var sent = false

    init(prefilledEmail: String) {
        _email = State(initialValue: prefilledEmail)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if sent {
                    ContentUnavailableView("Check your inbox",
                                           systemImage: "envelope.badge",
                                           description: Text("We sent a reset link to \(email). It expires in 30 minutes."))
                } else {
                    Text("Enter the email linked to your account and we'll send you a reset link.")
                        .foregroundStyle(.secondary)
                    TextField("Email address", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    Button {
                        withAnimation { sent = true }
                    } label: {
                        Text("Send Reset Link")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!email.contains("@"))
                    Spacer()
                }
            }
            .padding(24)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(sent ? "Done" : "Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    S_auth()
}
