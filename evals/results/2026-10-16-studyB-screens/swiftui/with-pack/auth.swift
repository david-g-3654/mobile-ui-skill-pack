import SwiftUI
import AuthenticationServices

struct S_auth: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var activeSheet: AuthSheet?
    @State private var providerMessage: String?

    init() {}

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: QSpace.xxl) {
                        HStack(spacing: QSpace.xs) {
                            Image(systemName: "book.closed.fill")
                                .foregroundStyle(QPalette.accent)
                                .accessibilityHidden(true)
                            Text("Margin")
                        }
                        .font(.dsHeadline)

                        Spacer(minLength: QSpace.xxxl)

                        VStack(alignment: .leading, spacing: QSpace.md) {
                            Text("Your next\nchapter.")
                                .font(.dsLargeTitle)
                                .accessibilityAddTraits(.isHeader)
                            Text("A home for your books,\nnotes and discoveries.")
                                .font(.dsBody)
                                .foregroundStyle(QPalette.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: QSpace.xxxl)

                        if let providerMessage {
                            Text(providerMessage)
                                .font(.dsFootnote)
                                .foregroundStyle(QPalette.negative)
                                .accessibilityLabel("Sign-in unavailable. \(providerMessage)")
                        }

                        QLargeTextFooter {
                            alternativeMethods
                            legalFooter
                        }
                    }
                    .padding(.horizontal, QSpace.margin)
                    .padding(.top, QSpace.xxl)
                    .padding(.bottom, QSpace.xxl)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .leading)
                }
                .scrollIndicators(.hidden)
            }
            .qCanvasBackground()
            .qBottomActionBar {
                appleButton
            } footer: {
                VStack(spacing: QSpace.xl) {
                    alternativeMethods
                    legalFooter
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .email:
                    AuthEmailView()
                        .presentationDetents([.large])
                        .presentationCornerRadius(QRadius.xl)
                case .terms, .privacy:
                    AuthLegalView(isPrivacy: sheet == .privacy)
                        .presentationDetents([.medium, .large])
                        .presentationCornerRadius(QRadius.xl)
                }
            }
        }
        .foregroundStyle(QPalette.ink)
        .tint(QPalette.ink)
    }

    private var appleButton: some View {
        SignInWithAppleButton(.continue) { request in
            providerMessage = nil
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            switch result {
            case .success:
                providerMessage = "Apple authorization completed. Account sign-in needs a connected authentication service."
            case .failure(let error):
                if (error as? ASAuthorizationError)?.code != .canceled {
                    providerMessage = "Apple sign-in couldn’t finish. Please try again or use email."
                }
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: QMetrics.buttonHeight)
        .accessibilityLabel("Continue with Apple")
    }

    private var alternativeMethods: some View {
        VStack(spacing: QSpace.sm) {
            Button {
                providerMessage = "Google sign-in isn’t connected in this preview. You can explore the email option instead."
            } label: {
                HStack(spacing: QSpace.sm) {
                    if let image = AuthBrandAssets.googleImage {
                        Image(uiImage: image)
                            .resizable()
                            .interpolation(.high)
                            .frame(width: QSpace.lg, height: QSpace.lg)
                            .accessibilityHidden(true)
                    }
                    Text("Continue with Google")
                }
            }
            .buttonStyle(.qSecondary)

            Button {
                providerMessage = nil
                activeSheet = .email
            } label: {
                Label("Continue with email", systemImage: "envelope")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.qSecondary)
        }
    }

    private var legalFooter: some View {
        VStack(spacing: QSpace.xxs) {
            Text("By continuing, you agree to our")
                .foregroundStyle(QPalette.ink2)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: QSpace.sm) {
                    legalButton("Terms of Service", sheet: .terms)
                    Text("and").foregroundStyle(QPalette.ink2)
                    legalButton("Privacy Policy", sheet: .privacy)
                }
                VStack(spacing: QSpace.xs) {
                    legalButton("Terms of Service", sheet: .terms)
                    legalButton("Privacy Policy", sheet: .privacy)
                }
            }
        }
        .font(.dsFootnote)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private func legalButton(_ title: String, sheet: AuthSheet) -> some View {
        Button { activeSheet = sheet } label: {
            Text(title)
                .underline()
                .frame(minHeight: QMetrics.minTap)
        }
        .buttonStyle(.plain)
    }
}

fileprivate enum AuthSheet: String, Identifiable {
    case email, terms, privacy
    var id: String { rawValue }
}

fileprivate struct AuthEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var errorMessage: String?
    @FocusState private var emailFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xxl) {
                    VStack(alignment: .leading, spacing: QSpace.sm) {
                        Text("Keep your place.")
                            .font(.dsLargeTitle)
                            .accessibilityAddTraits(.isHeader)
                        Text("Use your email to sign in or create a Margin account. No password to remember.")
                            .font(.dsBody)
                            .foregroundStyle(QPalette.ink2)
                    }

                    VStack(alignment: .leading, spacing: QSpace.xs) {
                        Text("Email address")
                            .font(.dsHeadline)
                        TextField("", text: $email, prompt: Text("alex@icloud.com").foregroundStyle(QPalette.ink3))
                            .font(.dsBody)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.go)
                            .focused($emailFocused)
                            .onSubmit(continueWithEmail)
                            .padding(.horizontal, QSpace.md)
                            .frame(minHeight: QMetrics.fieldHeight)
                            .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.m, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: QRadius.m, style: .continuous)
                                    .strokeBorder(errorMessage == nil ? QPalette.hairline : QPalette.negative)
                            }
                            .accessibilityLabel("Email address")
                            .onChange(of: email) { _, _ in errorMessage = nil }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.dsFootnote)
                                .foregroundStyle(QPalette.negative)
                        }
                    }
                }
                .padding(.horizontal, QSpace.margin)
                .padding(.vertical, QSpace.xxl)
            }
            .scrollDismissesKeyboard(.interactively)
            .qCanvasBackground()
            .qBottomActionBar {
                Button("Send sign-in link", action: continueWithEmail)
                    .buttonStyle(.qPrimary)
            }
            .navigationTitle("Continue with email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .foregroundStyle(QPalette.ink)
        .tint(QPalette.ink)
    }

    private func continueWithEmail() {
        let address = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = address.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty,
              parts[1].contains("."), !parts[1].hasPrefix("."), !parts[1].hasSuffix("."),
              !address.contains(where: \.isWhitespace) else {
            errorMessage = "Enter a complete email address, like alex@icloud.com."
            emailFocused = true
            return
        }
        emailFocused = false
        errorMessage = "Email delivery isn’t connected in this preview. No sign-in link has been sent."
    }
}

fileprivate struct AuthLegalView: View {
    @Environment(\.dismiss) private var dismiss
    let isPrivacy: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xl) {
                    Text("About this preview")
                        .font(.dsTitle)
                        .accessibilityAddTraits(.isHeader)
                    Text(isPrivacy
                         ? "This screen does not save your email or send it to a server. Apple authorization is handled by the system; this preview does not create an account."
                         : "Margin is a sign-in interface preview. Accounts, reading sync and email delivery are not connected. No subscription or purchase is required to explore this screen.")
                        .font(.dsBody)
                    Text(isPrivacy
                         ? "A production app must provide its full privacy policy before collecting account information."
                         : "A production app must provide its full terms of service before accepting account registrations.")
                        .font(.dsBody)
                        .foregroundStyle(QPalette.ink2)
                }
                .padding(QSpace.margin)
            }
            .qCanvasBackground()
            .navigationTitle(isPrivacy ? "Privacy Policy" : "Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .foregroundStyle(QPalette.ink)
        .tint(QPalette.ink)
    }
}

fileprivate enum AuthBrandAssets {
    static let googleImage: UIImage? = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAABoklEQVR42u2ZO07DQBCGvSPcISQaLsAFKKBIG1KnoaHjHIg64hx0NLlB4AJQcAEuEEWKhNK5MA2PtZF357W7E+GpUsTe//tndmdsV9UYZcNp33B9edFi/nfy9OJMAGAFp4JxJYVrgDgLwiUgYE08dR2wJp66HlgUT1kXrIrH7gXYZ/HBU6iUeOpRepBbRMgYtT7AcZ+zuL8OtxtDKfH+daqjRLOq2+39WZY5Rn2Ya1Z1x/0YSGnx0WP0+PbNtHhUIwtBmHug6ZdQP75Lyor7HYCYeB+CAjBd7JI0xOe7Q0cep625zwKwFiPACDAC/DcAbL/IFT8PNPWscTFxk83869eS3HBSNT50Bn7FV9X541WSLGDF+6YAVfxe7YHJZj4oXjsL3JmpA1DPGkdxXQuCIr6/p0BaMhKI6WLXSqfVPwB+FlJDfJzesEZo1IstibOv10tHAT56f7AFwI0QyFA/Aa6LKWKopELNECSlkAMi1slBWs+pILAbHDQ2Ze6SYn/ky7mxsaZBipvmEi/6TpwiGxyDxI5qgEgyq14SWKBSB4O5+ATjLsoFCQ2uXQAAAABJRU5ErkJggg==").flatMap { UIImage(data: $0) }
}

#Preview("Light") {
    S_auth().preferredColorScheme(.light)
}

#Preview("Dark") {
    S_auth().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_auth().environment(\.dynamicTypeSize, .accessibility2)
}
