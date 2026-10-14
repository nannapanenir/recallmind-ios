import SwiftUI

/// Root of the signed-out flow. Owns the routing decisions for the auth screens.
struct AuthenticationFlowView: View {
    private enum Route: Hashable {
        case emailSignIn
        case createAccount
        case verifyEmail(email: String, context: VerifyEmailViewModel.Context)
    }

    @Environment(AppState.self) private var appState
    @Environment(\.appEnvironment) private var environment
    @State private var path: [Route] = []

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
                // Pending AUTH 05 — Forgot Password.
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
}

#Preview {
    AuthenticationFlowView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
