import SwiftUI

/// AUTH 05 — Forgot Password.
struct ForgotPasswordView: View {
    private enum Field: Hashable {
        case email
    }

    @State private var viewModel: ForgotPasswordViewModel
    @FocusState private var focusedField: Field?

    private let onResetLinkSent: (String) -> Void
    private let onBackToSignIn: () -> Void

    init(
        viewModel: ForgotPasswordViewModel,
        onResetLinkSent: @escaping (String) -> Void,
        onBackToSignIn: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onResetLinkSent = onResetLinkSent
        self.onBackToSignIn = onBackToSignIn
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, RMSpacing.sm)

                form
                    .padding(.top, RMSpacing.xl)
            }
            .padding(.horizontal, RMSpacing.readingInset)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollBounceBehavior(.basedOnSize)
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
            Text("Reset your password")
                .font(RMTypography.titleLarge)
                .foregroundStyle(RMColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Enter the email associated with your RecallMind account.")
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
            .submitLabel(.send)
            .onSubmit(submit)

            if let banner = viewModel.banner {
                AuthBannerView(banner: banner, retry: submit)
            }

            RMPrimaryButton(
                "Send Reset Link",
                loadingTitle: "Sending email…",
                isLoading: viewModel.isSubmitting,
                action: submit
            )
            .disabled(!viewModel.canSubmit)

            RMTextButton("Back to Sign In", action: onBackToSignIn)
        }
    }

    private func submit() {
        focusedField = nil
        Task {
            if case .resetLinkSent(let email) = await viewModel.sendResetLink() {
                onResetLinkSent(email)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView(
            viewModel: ForgotPasswordViewModel(repository: MockAuthRepository()),
            onResetLinkSent: { _ in },
            onBackToSignIn: {}
        )
    }
    .tint(RMColors.textPrimary)
    .preferredColorScheme(.dark)
}
