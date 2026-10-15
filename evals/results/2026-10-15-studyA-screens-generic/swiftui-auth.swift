import SwiftUI
import AuthenticationServices

// MARK: - Sample data

fileprivate struct RecentAccount: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let provider: AuthProvider
    let initials: String
    let tint: Color
}

fileprivate enum AuthProvider: String {
    case apple = "Apple"
    case google = "Google"
    case email = "Email"

    var symbol: String {
        switch self {
        case .apple: return "apple.logo"
        case .google: return "g.circle.fill"
        case .email: return "envelope.fill"
        }
    }
}

fileprivate enum SampleData {
    static let appName = "Trailhead"
    static let tagline = "Plan hikes, track trails, and share the view with friends."
    static let recent = RecentAccount(
        name: "Maya Chen",
        email: "maya.chen@icloud.com",
        provider: .apple,
        initials: "MC",
        tint: .teal
    )
    // Demo credentials accepted by the mock sign-in.
    static let demoEmail = "alex.rivera@gmail.com"
    static let demoPassword = "trailhead2024"
}

fileprivate enum Field: Hashable {
    case email, password
}

fileprivate enum SignInState: Equatable {
    case idle
    case loading(AuthProvider)
    case success(String)
    case failure(String)
}

// MARK: - Root screen

struct S_auth: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @State private var state: SignInState = .idle
    @State private var showForgot = false
    @State private var showSignUp = false
    @State private var showRecent = true
    @FocusState private var focused: Field?

    @ScaledMetric(relativeTo: .body) private var buttonHeight: CGFloat = 52
    @ScaledMetric(relativeTo: .largeTitle) private var logoSize: CGFloat = 76

    init() {}

    private var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    private var emailLooksValid: Bool {
        let parts = email.split(separator: "@")
        return parts.count == 2 && parts[1].contains(".") && !parts[0].isEmpty
    }

    private var canSubmit: Bool {
        emailLooksValid && password.count >= 8 && !isLoading
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    if showRecent {
                        RecentAccountCard(account: SampleData.recent, height: buttonHeight) {
                            signIn(with: .apple, name: SampleData.recent.name)
                        } onDismiss: {
                            withAnimation(.snappy) { showRecent = false }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    socialButtons
                    OrDivider()
                    emailForm
                    statusBanner
                    footer
                }
                .padding(.horizontal, 24)
                .padding(.top, dynamicTypeSize.isAccessibilitySize ? 12 : 32)
                .padding(.bottom, 24)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(backgroundView.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") {
                        state = .success("Browsing as guest")
                    }
                    .disabled(isLoading)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = nil }
                }
            }
            .sheet(isPresented: $showForgot) {
                ForgotPasswordSheet(prefill: email)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showSignUp) {
                CreateAccountSheet()
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: Sections

    private var backgroundView: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground)
            LinearGradient(
                colors: [Color.teal.opacity(colorScheme == .dark ? 0.25 : 0.18), .clear],
                startPoint: .top,
                endPoint: .center
            )
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: logoSize * 0.26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.teal, Color.green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: logoSize, height: logoSize)
                    .shadow(color: .teal.opacity(0.35), radius: 14, y: 8)
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: logoSize * 0.44, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text("Welcome to \(SampleData.appName)")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(SampleData.tagline)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var socialButtons: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success:
                    state = .success("Signed in with Apple")
                case .failure(let error):
                    if let err = error as? ASAuthorizationError, err.code == .canceled { return }
                    state = .failure("Apple sign-in didn’t complete. Please try again.")
                }
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: buttonHeight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(isLoading)

            ProviderButton(
                title: "Continue with Google",
                minHeight: buttonHeight,
                isLoading: state == .loading(.google)
            ) {
                GoogleMark()
            } action: {
                signIn(with: .google, name: SampleData.demoEmail)
            }
            .disabled(isLoading)
        }
    }

    private var emailForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            LabeledInput(label: "Email", systemImage: "envelope", isFocused: focused == .email) {
                TextField("you@example.com", text: $email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focused, equals: .email)
                    .onSubmit { focused = .password }
            }

            LabeledInput(label: "Password", systemImage: "lock", isFocused: focused == .password) {
                HStack(spacing: 8) {
                    Group {
                        if showPassword {
                            TextField("At least 8 characters", text: $password)
                        } else {
                            SecureField("At least 8 characters", text: $password)
                        }
                    }
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.go)
                    .focused($focused, equals: .password)
                    .onSubmit { if canSubmit { submitEmail() } }

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(showPassword ? "Hide password" : "Show password")
                }
            }

            HStack {
                Spacer(minLength: 0)
                Button("Forgot password?") { showForgot = true }
                    .font(.subheadline.weight(.medium))
                    .tint(.teal)
            }

            Button(action: submitEmail) {
                ZStack {
                    if state == .loading(.email) {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign In")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: buttonHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 14))
            .tint(.teal)
            .disabled(!canSubmit)

            if password.isEmpty && email.isEmpty {
                Button {
                    email = SampleData.demoEmail
                    password = SampleData.demoPassword
                } label: {
                    Label("Fill demo account", systemImage: "wand.and.stars")
                        .font(.footnote)
                }
                .tint(.secondary)
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch state {
        case .success(let message):
            StatusBanner(text: message, systemImage: "checkmark.circle.fill", tint: .green)
        case .failure(let message):
            StatusBanner(text: message, systemImage: "exclamationmark.triangle.fill", tint: .orange)
        default:
            EmptyView()
        }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 4) {
                    Text("New to \(SampleData.appName)?").foregroundStyle(.secondary)
                    Button("Create an account") { showSignUp = true }
                        .fontWeight(.semibold)
                        .tint(.teal)
                }
                VStack(spacing: 4) {
                    Text("New to \(SampleData.appName)?").foregroundStyle(.secondary)
                    Button("Create an account") { showSignUp = true }
                        .fontWeight(.semibold)
                        .tint(.teal)
                }
            }
            .font(.subheadline)

            Text("By continuing, you agree to our [Terms of Service](https://example.com/terms) and [Privacy Policy](https://example.com/privacy).")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .tint(.teal)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }

    // MARK: Actions

    private func submitEmail() {
        focused = nil
        guard canSubmit else { return }
        let entered = email.lowercased()
        let pass = password
        state = .loading(.email)
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.snappy) {
                if entered == SampleData.demoEmail && pass == SampleData.demoPassword {
                    state = .success("Welcome back, Alex!")
                } else {
                    state = .failure("That email and password don’t match. Check them and try again.")
                }
            }
        }
    }

    private func signIn(with provider: AuthProvider, name: String) {
        focused = nil
        state = .loading(provider)
        Task {
            try? await Task.sleep(for: .seconds(1.0))
            withAnimation(.snappy) {
                state = .success("Signed in with \(provider.rawValue) as \(name)")
            }
        }
    }
}

// MARK: - Components

fileprivate struct ProviderButton<Icon: View>: View {
    let title: String
    let minHeight: CGFloat
    var isLoading: Bool = false
    @ViewBuilder let icon: () -> Icon
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                } else {
                    icon()
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color(.separator), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(isEnabled ? 1 : 0.6)
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel(title)
    }
}

fileprivate struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

/// A simple multicolor "G" drawn with shapes (no image assets).
fileprivate struct GoogleMark: View {
    @ScaledMetric(relativeTo: .headline) private var size: CGFloat = 20

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.25)
                .stroke(Color(red: 0.92, green: 0.26, blue: 0.21), style: StrokeStyle(lineWidth: size * 0.2))
                .rotationEffect(.degrees(-135))
            Circle()
                .trim(from: 0.25, to: 0.5)
                .stroke(Color(red: 0.98, green: 0.74, blue: 0.02), style: StrokeStyle(lineWidth: size * 0.2))
                .rotationEffect(.degrees(-135))
            Circle()
                .trim(from: 0.5, to: 0.75)
                .stroke(Color(red: 0.20, green: 0.66, blue: 0.33), style: StrokeStyle(lineWidth: size * 0.2))
                .rotationEffect(.degrees(-135))
            Circle()
                .trim(from: 0.75, to: 0.88)
                .stroke(Color(red: 0.26, green: 0.52, blue: 0.96), style: StrokeStyle(lineWidth: size * 0.2))
                .rotationEffect(.degrees(-135))
            Rectangle()
                .fill(Color(red: 0.26, green: 0.52, blue: 0.96))
                .frame(width: size * 0.45, height: size * 0.2)
                .offset(x: size * 0.2)
        }
        .frame(width: size * 0.8, height: size * 0.8)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

fileprivate struct OrDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color(.separator)).frame(height: 1)
            Text("or sign in with email")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .layoutPriority(1)
            Rectangle().fill(Color(.separator)).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct LabeledInput<Content: View>: View {
    let label: String
    let systemImage: String
    let isFocused: Bool
    @ViewBuilder let content: () -> Content

    @ScaledMetric(relativeTo: .body) private var fieldHeight: CGFloat = 50

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(isFocused ? Color.teal : Color.secondary)
                    .accessibilityHidden(true)
                content()
                    .font(.body)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: fieldHeight)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isFocused ? Color.teal : Color(.separator), lineWidth: isFocused ? 2 : 1)
            )
            .animation(.easeOut(duration: 0.15), value: isFocused)
        }
    }
}

fileprivate struct RecentAccountCard: View {
    let account: RecentAccount
    let height: CGFloat
    let onContinue: () -> Void
    let onDismiss: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .headline) private var avatar: CGFloat = 44

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onContinue) {
                let layout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                    : AnyLayout(HStackLayout(spacing: 12))
                layout {
                    Text(account.initials)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: avatar, height: avatar)
                        .background(Circle().fill(account.tint.gradient))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Continue as \(account.name)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Label(account.email, systemImage: account.provider.symbol)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 1)
                    }
                    .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableStyle())
            .accessibilityHint("Signs in with your last used \(account.provider.rawValue) account")

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Use a different account")
        }
        .padding(.leading, 14)
        .padding(.trailing, 4)
        .padding(.vertical, 10)
        .frame(minHeight: height)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        )
    }
}

fileprivate struct StatusBanner: View {
    let text: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.14))
        )
        .accessibilityElement(children: .combine)
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }
}

// MARK: - Sheets

fileprivate struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var prefill: String
    @State private var sent = false

    init(prefill: String) {
        _prefill = State(initialValue: prefill)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("you@example.com", text: $prefill)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Email")
                } footer: {
                    Text(sent
                         ? "If an account exists for \(prefill), you’ll get a reset link within a few minutes."
                         : "We’ll email you a link to reset your password.")
                }
                Section {
                    Button(sent ? "Resend Link" : "Send Reset Link") {
                        withAnimation { sent = true }
                    }
                    .disabled(!prefill.contains("@"))
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

fileprivate struct CreateAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var newsletter = true

    private var strength: (label: String, color: Color, value: Double) {
        switch password.count {
        case 0: return ("", .clear, 0)
        case 1..<8: return ("Too short", .red, 0.25)
        case 8..<12: return ("Okay", .orange, 0.6)
        default: return ("Strong", .green, 1)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your details") {
                    TextField("Full name", text: $name)
                        .textContentType(.name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section {
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                    if !password.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ProgressView(value: strength.value)
                                .tint(strength.color)
                            Text(strength.label)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Password")
                } footer: {
                    Text("Use 8 or more characters with a mix of letters and numbers.")
                }
                Section {
                    Toggle("Send me weekly trail picks", isOn: $newsletter)
                        .tint(.teal)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { dismiss() }
                        .disabled(name.isEmpty || !email.contains("@") || password.count < 8)
                }
            }
        }
    }
}

#Preview {
    S_auth()
}
