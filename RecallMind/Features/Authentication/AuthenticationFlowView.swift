import SwiftUI

/// Root of the signed-out flow. Owns the routing decisions for the auth screens.
struct AuthenticationFlowView: View {
    private enum Route: Hashable {
        case emailSignIn
        case createAccount
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
            onRequiresEmailVerification: { _ in
                // Pending AUTH 04 — Verify Email.
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
            onVerificationRequired: { _ in
                // Pending AUTH 04 — Verify Email.
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
