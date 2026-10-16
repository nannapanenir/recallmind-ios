import SwiftUI

/// Root of the signed-out flow. Owns the routing decisions for the auth screens.
struct AuthenticationFlowView: View {
    private enum Route: Hashable {
        case emailSignIn
        case createAccount
        case verifyEmail(email: String, context: VerifyEmailViewModel.Context)
        case forgotPassword
        case checkYourEmail(email: String)
        case resetPassword(PasswordResetContext)
        case passwordUpdated(User)
    }

    @Environment(AppState.self) private var appState
    @Environment(\.appEnvironment) private var environment
    @State private var path: [Route] = Self.initialPath

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(
                onContinueWithApple: {
                    // Pending: Sign in with Apple authorization is not implemented yet.
                },
                onContinueWithEmail: {
                    path.append(.emailSignIn)
                },
                onShowTerms: {
                    // Pending: Terms of Service destination not defined yet.
                },
                onShowPrivacy: {
                    // Pending: Privacy Policy destination not defined yet.
                }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .emailSignIn:
                    emailSignIn
                case .createAccount:
                    createAccount
                case .verifyEmail(let email, let context):
                    verifyEmail(email: email, context: context)
                case .forgotPassword:
                    forgotPassword
                case .checkYourEmail(let email):
                    checkYourEmail(email: email)
                case .resetPassword(let context):
                    resetPassword(context: context)
                case .passwordUpdated(let user):
                    PasswordUpdatedView {
                        // AUTH 07B "Continue to RecallMind" goes to Home, signed in, as designed.
                        appState.completeSignIn(with: user)
                    }
                }
            }
        }
        // Back chevron color on pushed auth screens.
        .tint(RMColors.textPrimary)
    }

    private var emailSignIn: some View {
        EmailSignInView(
            viewModel: EmailSignInViewModel(repository: environment.authRepository),
            onSignedIn: { user in
                appState.completeSignIn(with: user)
            },
            onRequiresEmailVerification: { email in
                path.append(.verifyEmail(email: email, context: .signInUnverified))
            },
            onForgotPassword: {
                path.append(.forgotPassword)
            },
            onCreateAccount: {
                path.append(.createAccount)
            }
        )
    }

    private var createAccount: some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(repository: environment.authRepository),
            onVerificationRequired: { email in
                path.append(.verifyEmail(email: email, context: .accountCreated))
            },
            onSignIn: popToSignIn,
            onShowTerms: {
                // Pending: Terms of Service destination not defined yet.
            },
            onShowPrivacy: {
                // Pending: Privacy Policy destination not defined yet.
            }
        )
    }

    private func verifyEmail(email: String, context: VerifyEmailViewModel.Context) -> some View {
        VerifyEmailView(
            viewModel: VerifyEmailViewModel(email: email, context: context, repository: environment.authRepository),
            onVerified: { user in
                // AUTH 04 continues to 69 Quick Setup in the design; until it exists, go to Home.
                appState.completeSignIn(with: user)
            },
            onUseDifferentEmail: showCreateAccount,
            onSignIn: popToSignIn
        )
    }

    private var forgotPassword: some View {
        ForgotPasswordView(
            viewModel: ForgotPasswordViewModel(repository: environment.authRepository),
            onResetLinkSent: { email in
                path.append(.checkYourEmail(email: email))
            },
            onBackToSignIn: popToSignIn
        )
    }

    private func checkYourEmail(email: String) -> some View {
        CheckYourEmailView(
            viewModel: CheckYourEmailViewModel(email: email, repository: environment.authRepository),
            onBackToSignIn: popToSignIn
        )
    }

    private func resetPassword(context: PasswordResetContext) -> some View {
        ResetPasswordView(
            viewModel: ResetPasswordViewModel(context: context, repository: environment.authRepository),
            onPasswordUpdated: { user in
                // The reset link is spent: AUTH 07 is replaced by AUTH 07B.
                path.removeLast()
                path.append(.passwordUpdated(user))
            },
            onRequestNewLink: {
                // Expired link: AUTH 07 is replaced by AUTH 05.
                path.removeLast()
                path.append(.forgotPassword)
            }
        )
    }

    /// Back to AUTH 03 when it is the previous screen; otherwise AUTH 04 is replaced by AUTH 03.
    private func showCreateAccount() {
        path.removeLast()
        if path.last != .createAccount {
            path.append(.createAccount)
        }
    }

    /// Returns to AUTH 02, keeping the screens below it.
    private func popToSignIn() {
        if let index = path.lastIndex(of: .emailSignIn) {
            path.removeSubrange(path.index(after: index)...)
        } else {
            path = [.emailSignIn]
        }
    }

    /// Debug builds only: launching with `-RMResetPasswordPreview <token>` opens AUTH 07 with a mock
    /// reset link, standing in for the reset-link deep link (not built yet). `expired` gives the
    /// expired-link state with `MockAuthRepository`.
    private static var initialPath: [Route] {
        #if DEBUG
        if let token = UserDefaults.standard.string(forKey: "RMResetPasswordPreview") {
            return [.emailSignIn, .resetPassword(PasswordResetContext(email: "ramgopal@example.com", token: token))]
        }
        #endif
        return []
    }
}

#Preview {
    AuthenticationFlowView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
