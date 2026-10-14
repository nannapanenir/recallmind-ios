import SwiftUI

/// AUTH 03 — Create Account.
struct CreateAccountView: View {
    private enum Field: Hashable {
        case email
        case password
        case confirmPassword
    }

    @State private var viewModel: CreateAccountViewModel
    @FocusState private var focusedField: Field?

    private let onVerificationRequired: (String) -> Void
    private let onSignIn: () -> Void
    private let onShowTerms: () -> Void
    private let onShowPrivacy: () -> Void

    init(
        viewModel: CreateAccountViewModel,
        onVerificationRequired: @escaping (String) -> Void,
        onSignIn: @escaping () -> Void,
        onShowTerms: @escaping () -> Void,
        onShowPrivacy: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onVerificationRequired = onVerificationRequired
        self.onSignIn = onSignIn
        self.onShowTerms = onShowTerms
        self.onShowPrivacy = onShowPrivacy
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.top, RMSpacing.sm)

                    form
                        .padding(.top, RMSpacing.xl)

                    signInPrompt
                        .padding(.top, RMSpacing.xxs)

                    Spacer(minLength: RMSpacing.xl)

                    RMLegalFooter("By creating an account, you agree to our", onShowTerms: onShowTerms, onShowPrivacy: onShowPrivacy)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, RMSpacing.xs)
                }
                .padding(.horizontal, RMSpacing.readingInset)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(RMColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbarBackground(RMColors.background, for: .navigationBar)
        .onChange(of: focusedField) { oldValue, _ in
            switch oldValue {
            case .email: viewModel.validateEmail()
            case .password: viewModel.validatePassword()
            case .confirmPassword: viewModel.validateConfirmPassword()
            case nil: break
            }
        }
        .announcesAuthBanner(viewModel.banner)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RMSpacing.xs) {
            Text("Create your account")
                .font(RMTypography.titleLarge)
                .foregroundStyle(RMColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Start capturing what you learn.")
                .font(RMTypography.body)
                .foregroundStyle(RMColors.textSecondary)
        }
    }

    private var form: some View {
        VStack(spacing: RMSpacing.md) {
            RMTextField(
                label: "Email address",
                placeholder: "you@example.com",
                text: $viewModel.email,
                errorMessage: viewModel.emailError?.message,
                focus: $focusedField,
                field: .email
            )
            .keyboardType(.emailAddress)
            .textContentType(.username)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            VStack(alignment: .leading, spacing: RMSpacing.xs) {
                RMPasswordField(
                    label: "Password",
                    placeholder: "",
                    text: $viewModel.password,
                    isRevealed: $viewModel.isPasswordVisible,
                    errorMessage: viewModel.passwordError?.message,
                    contentType: .newPassword,
                    focus: $focusedField,
                    field: .password
                )
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }

                // The rule error replaces the hint (AUTH 08).
                if viewModel.passwordError == nil {
                    RMFieldHint("At least 8 characters", isMet: viewModel.meetsPasswordLength)
                }
            }

            RMPasswordField(
                label: "Confirm password",
                placeholder: "Re-enter your password",
                text: $viewModel.confirmPassword,
                isRevealed: $viewModel.isConfirmPasswordVisible,
                errorMessage: viewModel.confirmPasswordError?.message,
                contentType: .newPassword,
                focus: $focusedField,
                field: .confirmPassword
            )
            .submitLabel(.go)
            .onSubmit(submit)

            if let banner = viewModel.banner {
                AuthBannerView(banner: banner, retry: submit)
            }

            RMPrimaryButton(
                "Create Account",
                loadingTitle: "Creating your account…",
                isLoading: viewModel.isSubmitting,
                action: submit
            )
            .disabled(!viewModel.canSubmit)
            .padding(.top, RMSpacing.xs)
        }
    }

    private var signInPrompt: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: RMSpacing.xxs) { signInPromptContent }
            VStack(spacing: 0) { signInPromptContent }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var signInPromptContent: some View {
        Text("Already have an account?")
            .font(RMTypography.body)
            .foregroundStyle(RMColors.textSecondary)
        RMTextButton("Sign in", action: onSignIn)
    }

    private func submit() {
        focusedField = nil
        Task {
            if case .verificationRequired(let email) = await viewModel.createAccount() {
                onVerificationRequired(email)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView(
            viewModel: CreateAccountViewModel(repository: MockAuthRepository()),
            onVerificationRequired: { _ in },
            onSignIn: {},
            onShowTerms: {},
            onShowPrivacy: {}
        )
    }
    .tint(RMColors.textPrimary)
    .preferredColorScheme(.dark)
}
