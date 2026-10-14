import SwiftUI

/// AUTH 02 — Email Sign In.
struct EmailSignInView: View {
    private enum Field: Hashable {
        case email
        case password
    }

    @State private var viewModel: EmailSignInViewModel
    @FocusState private var focusedField: Field?

    private let onSignedIn: (User) -> Void
    private let onRequiresEmailVerification: (String) -> Void
    private let onForgotPassword: () -> Void
    private let onCreateAccount: () -> Void

    init(
        viewModel: EmailSignInViewModel,
        onSignedIn: @escaping (User) -> Void,
        onRequiresEmailVerification: @escaping (String) -> Void,
        onForgotPassword: @escaping () -> Void,
        onCreateAccount: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onSignedIn = onSignedIn
        self.onRequiresEmailVerification = onRequiresEmailVerification
        self.onForgotPassword = onForgotPassword
        self.onCreateAccount = onCreateAccount
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.top, RMSpacing.sm)

                    form
                        .padding(.top, RMSpacing.xl)

                    Spacer(minLength: RMSpacing.xl)

                    footer
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
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue == .email, newValue != .email {
                viewModel.validateEmail()
            }
        }
        .announcesAuthBanner(viewModel.banner)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RMSpacing.xs) {
            Text("Welcome back")
                .font(RMTypography.titleLarge)
                .foregroundStyle(RMColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Sign in to continue to RecallMind.")
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

            VStack(alignment: .trailing, spacing: RMSpacing.xs) {
                RMPasswordField(
                    label: "Password",
                    placeholder: "Enter your password",
                    text: $viewModel.password,
                    isRevealed: $viewModel.isPasswordVisible,
                    focus: $focusedField,
                    field: .password
                )
                .submitLabel(.go)
                .onSubmit(submit)

                RMTextButton("Forgot password?", action: onForgotPassword)
            }

            if let banner = viewModel.banner {
                AuthBannerView(banner: banner, retry: submit)
            }

            RMPrimaryButton("Sign In", loadingTitle: "Signing you in…", isLoading: viewModel.isSubmitting, action: submit)
                .disabled(!viewModel.canSubmit)
        }
    }

    private var footer: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: RMSpacing.xxs) { footerContent }
            VStack(spacing: 0) { footerContent }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var footerContent: some View {
        Text("Don’t have an account?")
            .font(RMTypography.body)
            .foregroundStyle(RMColors.textSecondary)
        RMTextButton("Create account", action: onCreateAccount)
    }

    private func submit() {
        focusedField = nil
        Task {
            switch await viewModel.signIn() {
            case .signedIn(let user):
                onSignedIn(user)
            case .requiresEmailVerification(let email):
                onRequiresEmailVerification(email)
            case nil:
                break
            }
        }
    }
}

#Preview {
    NavigationStack {
        EmailSignInView(
            viewModel: EmailSignInViewModel(repository: MockAuthRepository()),
            onSignedIn: { _ in },
            onRequiresEmailVerification: { _ in },
            onForgotPassword: {},
            onCreateAccount: {}
        )
    }
    .tint(RMColors.textPrimary)
    .preferredColorScheme(.dark)
}
