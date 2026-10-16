import SwiftUI

/// AUTH 06 — Check Your Email, after a password reset request.
/// Never says whether an account exists for the email.
struct CheckYourEmailView: View {
    @State private var viewModel: CheckYourEmailViewModel
    @Environment(\.openURL) private var openURL

    private let onBackToSignIn: () -> Void

    init(viewModel: CheckYourEmailViewModel, onBackToSignIn: @escaping () -> Void) {
        self._viewModel = State(initialValue: viewModel)
        self.onBackToSignIn = onBackToSignIn
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    message
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, RMSpacing.xl)

                    actions
                }
                .padding(.horizontal, RMSpacing.readingInset)
                .padding(.bottom, RMSpacing.xs)
                .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(RMColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbarBackground(RMColors.background, for: .navigationBar)
        .task(id: viewModel.cooldown.cycle) {
            await viewModel.cooldown.run()
        }
        .announcesAuthBanner(viewModel.banner)
    }

    private var message: some View {
        VStack(spacing: RMSpacing.md) {
            RMHeroIcon(systemImage: "envelope")

            Text("Check your email")
                .font(RMTypography.titleLarge)
                .foregroundStyle(RMColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, RMSpacing.xxs)

            (Text("If a RecallMind account uses this email, we sent a password reset link to")
                + Text("\n")
                + Text(verbatim: viewModel.email)
                    .font(RMTypography.bodyEmphasis)
                    .foregroundStyle(RMColors.textPrimary))
                .font(RMTypography.body)
                .foregroundStyle(RMColors.textSecondary)

            Text("Didn’t get it? Check your spam folder.")
                .font(RMTypography.callout)
                .foregroundStyle(RMColors.textSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var actions: some View {
        VStack(spacing: RMSpacing.sm) {
            if let banner = viewModel.banner {
                AuthBannerView(banner: banner, action: resend)
            }

            RMPrimaryButton("Open Mail") { openURL.openMail() }

            RMSecondaryButton(
                viewModel.cooldown.buttonTitle,
                loadingTitle: "Sending email…",
                isLoading: viewModel.isResending,
                action: resend
            )
            .disabled(!viewModel.canResend)

            RMTextButton("Back to Sign In", action: onBackToSignIn)
        }
    }

    private func resend() {
        Task { await viewModel.resend() }
    }
}

#Preview {
    NavigationStack {
        CheckYourEmailView(
            viewModel: CheckYourEmailViewModel(email: "ramgopal@example.com", repository: MockAuthRepository()),
            onBackToSignIn: {}
        )
    }
    .tint(RMColors.textPrimary)
    .preferredColorScheme(.dark)
}
