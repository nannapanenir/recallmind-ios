import SwiftUI

/// AUTH 07 — Reset Password, opened from a password reset link. No back button, as designed.
struct ResetPasswordView: View {
    private enum Field: Hashable {
        case newPassword
        case confirmPassword
    }

    @State private var viewModel: ResetPasswordViewModel
    @FocusState private var focusedField: Field?

    private let onPasswordUpdated: (User) -> Void
    private let onRequestNewLink: () -> Void

    init(
        viewModel: ResetPasswordViewModel,
        onPasswordUpdated: @escaping (User) -> Void,
        onRequestNewLink: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onPasswordUpdated = onPasswordUpdated
        self.onRequestNewLink = onRequestNewLink
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
        .navigationBarBackButtonHidden()
        .toolbarBackground(RMColors.background, for: .navigationBar)
        .onChange(of: focusedField) { oldValue, _ in
            switch oldValue {
            case .newPassword: viewModel.validateNewPassword()
            case .confirmPassword: viewModel.validateConfirmPassword()
            case nil: break
            }
        }
        .announcesAuthBanner(viewModel.banner)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RMSpacing.xs) {
            Text("Create a new password")
                .font(RMTypography.titleLarge)
                .foregroundStyle(RMColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            (Text("For ")
                + Text(verbatim: viewModel.context.email)
                    .font(RMTypography.bodyEmphasis)
                    .foregroundStyle(RMColors.textPrimary))
                .font(RMTypography.body)
                .foregroundStyle(RMColors.textSecondary)
        }
    }

    private var form: some View {
        VStack(spacing: RMSpacing.md) {
            VStack(alignment: .leading, spacing: RMSpacing.xs) {
                RMPasswordField(
                    label: "New password",
                    placeholder: "",
                    text: $viewModel.newPassword,
                    isRevealed: $viewModel.isNewPasswordVisible,
                    errorMessage: viewModel.newPasswordError?.message,
                    contentType: .newPassword,
                    focus: $focusedField,
                    field: .newPassword
                )
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }

                // The rule error replaces the hint (AUTH 08).
                if viewModel.newPasswordError == nil {
                    RMFieldHint("At least 8 characters", isMet: viewModel.meetsPasswordLength)
                }
            }

            RMPasswordField(
                label: "Confirm new password",
                placeholder: "",
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
                AuthBannerView(banner: banner, action: bannerAction)
            }

            RMPrimaryButton(
                "Update Password",
                loadingTitle: "Updating password…",
                isLoading: viewModel.isSubmitting,
                action: submit
            )
            .disabled(!viewModel.canSubmit)
            .padding(.top, RMSpacing.xs)
        }
    }

    private func submit() {
        focusedField = nil
        Task {
            if let user = await viewModel.updatePassword() {
                onPasswordUpdated(user)
            }
        }
    }

    private func bannerAction() {
        if viewModel.banner == .resetLinkExpired {
            onRequestNewLink()
        } else {
            submit()
        }
    }
}

#Preview {
    NavigationStack {
        ResetPasswordView(
            viewModel: ResetPasswordViewModel(
                context: PasswordResetContext(email: "ramgopal@example.com", token: "preview"),
                repository: MockAuthRepository()
            ),
            onPasswordUpdated: { _ in },
            onRequestNewLink: {}
        )
    }
    .preferredColorScheme(.dark)
}
