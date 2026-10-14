import SwiftUI
import UIKit

/// AUTH 04 — Verify Email. No back button: the ways out are Sign in and Use a different email.
struct VerifyEmailView: View {
    @State private var viewModel: VerifyEmailViewModel
    @Environment(\.openURL) private var openURL

    private let onVerified: (User) -> Void
    private let onUseDifferentEmail: () -> Void
    private let onSignIn: () -> Void

    init(
        viewModel: VerifyEmailViewModel,
        onVerified: @escaping (User) -> Void,
        onUseDifferentEmail: @escaping () -> Void,
        onSignIn: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onVerified = onVerified
        self.onUseDifferentEmail = onUseDifferentEmail
        self.onSignIn = onSignIn
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
        .navigationBarBackButtonHidden()
        .toolbarBackground(RMColors.background, for: .navigationBar)
        .task(id: viewModel.cooldownCycle) {
            await viewModel.runResendCountdown()
        }
        .announcesAuthBanner(viewModel.banner)
        .onChange(of: viewModel.notice) { _, notice in
            if let notice {
                UIAccessibility.post(notification: .announcement, argument: notice.title)
            }
        }
    }

    private var message: some View {
        VStack(spacing: RMSpacing.md) {
            RMHeroIcon(systemImage: "envelope")

            Text("Verify your email")
                .font(RMTypography.titleLarge)
                .foregroundStyle(RMColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, RMSpacing.xxs)

            (Text("We sent a verification link to")
                + Text("\n")
                + Text(verbatim: viewModel.email)
                    .font(RMTypography.bodyEmphasis)
                    .foregroundStyle(RMColors.textPrimary))
                .font(RMTypography.body)
                .foregroundStyle(RMColors.textSecondary)

            Text("Open the link in your email to finish creating your RecallMind account.")
                .font(RMTypography.body)
                .foregroundStyle(RMColors.textSecondary)

            if viewModel.isEmailSentVisible {
                RMSuccessChip("Email sent")
            }

            signInPrompt
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var actions: some View {
        VStack(spacing: RMSpacing.sm) {
            if let notice = viewModel.notice {
                RMNotice(systemImage: "envelope", title: notice.title, message: notice.message)
            }

            if let banner = viewModel.banner {
                AuthBannerView(banner: banner, retry: retry)
            }

            RMPrimaryButton("Open Mail", action: openMail)

            RMSecondaryButton(
                resendTitle,
                loadingTitle: "Sending email…",
                isLoading: viewModel.isResending,
                action: resend
            )
            .disabled(!viewModel.canResend)

            ViewThatFits(in: .horizontal) {
                HStack {
                    verifiedButton
                    Spacer(minLength: RMSpacing.xs)
                    differentEmailButton
                }
                VStack(spacing: 0) {
                    verifiedButton
                    differentEmailButton
                }
            }
        }
    }

    private var resendTitle: String {
        viewModel.canResend ? "Resend Email" : "Resend available in \(viewModel.resendSecondsRemaining)s"
    }

    private var verifiedButton: some View {
        RMTextButton("I’ve verified my email", action: checkVerification)
            .disabled(viewModel.isCheckingVerification)
    }

    private var differentEmailButton: some View {
        RMTextButton("Use a different email", style: .secondary, action: onUseDifferentEmail)
    }

    private var signInPrompt: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: RMSpacing.xxs) { signInPromptContent }
            VStack(spacing: 0) { signInPromptContent }
        }
    }

    @ViewBuilder
    private var signInPromptContent: some View {
        Text("Already have an account?")
            .font(RMTypography.body)
            .foregroundStyle(RMColors.textSecondary)
        RMTextButton("Sign in", action: onSignIn)
    }

    private func openMail() {
        if let url = URL(string: "message://") {
            openURL(url)
        }
    }

    private func resend() {
        Task { await viewModel.resend() }
    }

    private func checkVerification() {
        Task {
            if let user = await viewModel.checkVerification() {
                onVerified(user)
            }
        }
    }

    private func retry() {
        switch viewModel.failedAction {
        case .resend: resend()
        case .checkVerification: checkVerification()
        case nil: break
        }
    }
}

#Preview {
    NavigationStack {
        VerifyEmailView(
            viewModel: VerifyEmailViewModel(
                email: "ramgopal@example.com",
                context: .accountCreated,
                repository: MockAuthRepository()
            ),
            onVerified: { _ in },
            onUseDifferentEmail: {},
            onSignIn: {}
        )
    }
    .preferredColorScheme(.dark)
}
